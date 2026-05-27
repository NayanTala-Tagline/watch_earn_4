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
  static const _minSplashDuration = Duration(milliseconds: 3000);
  static const _adLoadTimeout = Duration(seconds: 6);
  static const _maxSplashDuration = Duration(seconds: 12);
  static const _bannerLoadTimeout = Duration(seconds: 6);

  InlineAdManager? _banner;
  FullScreenAdManager? _fullScreen;
  Future<void>? _bannerLoadFuture;

  /// Pre-loaded native ad for onboarding 1 — only started when the routing
  /// decision confirms the user will land on the onboarding flow.
  InlineAdManager? _onboarding1NativeAd;
  bool _onboarding1NativeAdTransferred = false;

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
    if (!_onboarding1NativeAdTransferred) {
      unawaited(_onboarding1NativeAd?.dispose());
    }
    super.dispose();
  }

  void _startAdFlow() {
    _startedAt = DateTime.now();

    // Determine routing early so we can pre-load the onboarding 1 native ad
    // while the splash animations and full-screen ad are running.
    final db = Injector.instance<AppDB>();
    final isLoggedIn =
        FirebaseAuth.instance.currentUser != null || db.userModel != null;
    if (!isLoggedIn && !_shouldSkipOnboarding()) {
      final data = RemoteConfigService.instance.onboardingNative1;
      _onboarding1NativeAd = InlineAdManager(adData: data);
      unawaited(_onboarding1NativeAd!.load());
    }

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
      await _fullScreen!.future().timeout(
            _adLoadTimeout,
            onTimeout: () => AdStatus.failed,
          );

      await _waitForMinSplash();
      if (!mounted) return;

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
      _onboarding1NativeAdTransferred = true;
      context.goNamed(AppRoutes.onboarding1, extra: _onboarding1NativeAd);
    }
  }

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
                context.l10n.splashAppName,
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
                      backgroundColor: context.themeColors.borderColor2,
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
