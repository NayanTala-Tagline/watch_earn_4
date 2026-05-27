import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/ad_repository.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/logger.dart';
import '../../utils/remote_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Floor on splash duration so the logo animation has room to play even when
  /// ads resolve instantly (disabled / cached / failed).
  static const _minSplashDuration = Duration(milliseconds: 3000);

  /// Per-ad load timeout — protects against SDKs that never resolve.
  static const _adLoadTimeout = Duration(seconds: 6);

  /// Wall-clock ceiling. No matter what happens (RC stalls, callback never
  /// fires, native code hangs), the user navigates away after this.
  static const _maxSplashDuration = Duration(seconds: 12);

  /// Hard cap on the banner-load wait.
  static const _bannerLoadTimeout = Duration(seconds: 6);

  InlineAdManager? _banner;
  FullScreenAdManager? _fullScreen;

  /// Cached banner fill future so the navigation flow can wait for the
  /// banner to actually appear on screen before tearing the splash down.
  Future<void>? _bannerLoadFuture;

  Timer? _safetyTimer;
  bool _navigated = false;
  DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'splash',
      screenClass: 'SplashScreen',
    );
    AdRepository.showConsentUMP();
    _startAdFlow();
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    unawaited(_banner?.dispose());
    unawaited(_fullScreen?.dispose());
    super.dispose();
  }

  void _startAdFlow() {
    _startedAt = DateTime.now();
    _safetyTimer = Timer(_maxSplashDuration, () {
      '⚠️ splash safety timer fired — forcing navigate'.logD;
      unawaited(_goNext());
    });
    _initBanner();
    unawaited(_runFullScreenFlow());
  }

  void _initBanner() {
    final data = RemoteConfigService.instance.splashBanner;
    if (!data.enabled || data.adId.isEmpty) return;

    _banner = InlineAdManager(adData: data);
    unawaited(_banner!.load());
    _bannerLoadFuture = _banner!.future().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _runFullScreenFlow() async {
    try {
      final data = RemoteConfigService.instance.splashAppOpen;

      // Slot disabled or no ad id → skip the ad, just honor the floor.
      if (!data.enabled || data.adId.isEmpty) {
        await _waitForMinSplash();
        unawaited(_goNext());
        return;
      }

      _fullScreen = FullScreenAdManager(
        adData: data,
        openAppCallback: FullScreenContentCallback<AppOpenAd>(
          onAdDismissedFullScreenContent: (_) => unawaited(_goNext()),
          onAdFailedToShowFullScreenContent: (_, _) => unawaited(_goNext()),
        ),
        interstitialCallback: FullScreenContentCallback<InterstitialAd>(
          onAdDismissedFullScreenContent: (_) => unawaited(_goNext()),
          onAdFailedToShowFullScreenContent: (_, _) => unawaited(_goNext()),
        ),
      );

      unawaited(_fullScreen!.load());
      // Best-effort wait — even if this times out as failed, the SDK can
      // still fill a moment later, so we re-check `isLoaded` below.
      await _fullScreen!.future().timeout(
            _adLoadTimeout,
            onTimeout: () => AdStatus.failed,
          );

      await _waitForMinSplash();
      if (!mounted) return;

      // Polling grace — give the SDK up to 3 s more if `future()` already
      // resolved as `failed` but the ad is still in-flight. Capped well
      // under [_maxSplashDuration].
      if (!(_fullScreen?.isLoaded ?? false)) {
        for (var i = 0; i < 6; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          if (_fullScreen?.isLoaded ?? false) break;
        }
      }

      if (_fullScreen?.isLoaded ?? false) {
        final shown = await _fullScreen!.show();
        if (!shown) unawaited(_goNext());
        // shown == true → dismiss / fail callback drives navigation.
      } else {
        unawaited(_goNext());
      }
    } catch (e, s) {
      '❌ splash ad flow failed: $e'.logD;
      s.toString().logD;
      unawaited(_goNext());
    }
  }

  Future<void> _waitForMinSplash() async {
    final elapsed = DateTime.now().difference(_startedAt);
    final remaining = _minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    // Also wait for the splash banner to actually fill so it's visible
    // before navigation — capped by [_bannerLoadTimeout] and overall by
    // the [_safetyTimer].
    final loadFuture = _bannerLoadFuture;
    if (loadFuture != null && _banner != null && !_banner!.isLoaded) {
      await loadFuture.timeout(_bannerLoadTimeout, onTimeout: () {});
    }
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    _safetyTimer?.cancel();

    final db = Injector.instance<AppDB>();
    final isLoggedIn =
        FirebaseAuth.instance.currentUser != null || db.userModel != null;

    if (_shouldSkipOnboarding()) {
      if (isLoggedIn) {
        'Splash: onboarding skipped, logged in → home'.logD;
        context.goNamed(AppRoutes.home);
      } else {
        'Splash: onboarding skipped, not logged in → login'.logD;
        context.goNamed(AppRoutes.login);
      }
      return;
    }

    if (isLoggedIn) {
      context.goNamed(AppRoutes.home);
    } else {
      'Splash: routing to onboarding'.logD;
      context.goNamed(AppRoutes.onboarding1);
    }
  }

  /// Routing decision after the splash flow:
  ///   • `skip_onboarding` (RC) → true (always skip, regardless of state).
  ///   • `show_multiple_onboarding` (RC) → false (force onboarding even if
  ///     the user has completed it before — useful for QA / feature gates).
  ///   • Otherwise → true if onboarding has been completed before, else
  ///     false (first-launch users see onboarding).
  ///
  /// The Firebase-login gate is applied separately in [_goNext], so
  /// "skip onboarding" doesn't bypass auth.
  bool _shouldSkipOnboarding() {
    final rc = RemoteConfigService.instance;
    if (rc.skipOnBoarding) return true;
    if (rc.showMultipleOnboarding) return false;
    return Injector.instance<AppDB>().isOnboardingCompleted == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.splash.splashBg.image(fit: BoxFit.cover),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.images.splash.splashLogo
                  .image(width: AppSize.w210, height: AppSize.w210)
                  .animate()
                  .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.55, 0.55),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.easeOutBack,
                  )
                  .blurXY(
                    begin: 14,
                    end: 0,
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .then(delay: 200.ms)
                  .shimmer(
                    duration: 1400.ms,
                    color: context.themeColors.whiteColor.withValues(alpha: 0.6),
                  ),
              SizedBox(height: AppSize.h16),
              Text(
                'Rewardo',
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp32,
                  color: context.themeColors.navyColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    delay: 400.ms,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: AppSize.h3,
                    child: LinearProgressIndicator(
                      minHeight: AppSize.h3,
                      backgroundColor:
                          context.themeColors.borderColor2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.themeColors.buttonColor,
                      ),
                    ),
                  ),
                  if (_banner != null && _banner!.isLoaded)
                    SizedBox(
                      width: double.infinity,
                      child: _banner!.adWidget(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
