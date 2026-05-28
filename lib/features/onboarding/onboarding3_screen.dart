import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../features/language_screen/language_screen.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import 'provider/onboarding_provider.dart';

class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key, this.preloadedNative});

  /// Native ad pre-loaded by onboarding 2.
  final InlineAdManager? preloadedNative;

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'onboarding_3',
      screenClass: 'Onboarding3Screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(
        preloadedNative: widget.preloadedNative,
        // No next inline native — language screen uses NativeAdManager directly.
        interAdData: RemoteConfigService.instance.onboardingInter3,
        preloadLanguageAds: true,
      ),
      child: Consumer<OnboardingProvider>(
        builder: (context, prov, _) {
          return Scaffold(
            backgroundColor: context.themeColors.backgroundColor,
            bottomNavigationBar: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdSlot(ad: prov.nativeAd, safeAreaBottom: false, safeAreaTop: false),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSize.w24,
                      AppSize.h12,
                      AppSize.w24,
                      AppSize.h16,
                    ),
                    child: AppButton(
                      text: context.l10n.startEarning,
                      isLoading: prov.isLoading,
                      buttonColor: context.themeColors.buttonColor,
                      shadowColor: context.themeColors.buttonBorderColor,
                      foregroundColor: context.themeColors.whiteColor,
                      trailingIcon: Icon(
                        Icons.arrow_forward_rounded,
                        color: context.themeColors.whiteColor,
                        size: 20,
                      ),
                      borderRadius: AppSize.r29,
                      onPressed: () async {
                        AnalyticsManager.instance.logEvent(name: 'onboarding_completed');
                        await prov.waitForNextAd();
                        await prov.interAd?.show();
                        if (context.mounted) {
                          final ads = prov.takeLanguageAds();
                          context.goNamed(
                            AppRoutes.language,
                            extra: LanguageScreenArgs(
                              nativeAd1: ads.ad1,
                              nativeAd2: ads.ad2,
                            ),
                          );
                        }
                      },
                    ).animate().fadeIn(delay: 300.ms, duration: 450.ms, curve: Curves.easeOut).slideY(
                          begin: 0.25,
                          end: 0,
                          delay: 300.ms,
                          duration: 450.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Illustration
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
                      child: Assets.images.onboarding.onboarding3
                          .image(
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.82, 0.82),
                            end: const Offset(1, 1),
                            duration: 550.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 400.ms, curve: Curves.easeOut),
                    ),
                  ),

                  SizedBox(height: AppSize.h20),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                    child: Text(
                      context.l10n.onboarding3Title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: AppSize.sp28,
                        color: context.themeColors.navyColor,
                        height: 1.2,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 450.ms, curve: Curves.easeOut)
                        .slideX(
                          begin: -0.1,
                          end: 0,
                          delay: 150.ms,
                          duration: 450.ms,
                          curve: Curves.easeOut,
                        ),
                  ),

                  SizedBox(height: AppSize.h10),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                    child: Text(
                      context.l10n.onboarding3Desc,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: AppSize.sp15,
                        color: context.themeTextColors.subtitleColor,
                        height: 1.55,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 220.ms, duration: 450.ms, curve: Curves.easeOut)
                        .slideX(
                          begin: -0.1,
                          end: 0,
                          delay: 220.ms,
                          duration: 450.ms,
                          curve: Curves.easeOut,
                        ),
                  ),

                  SizedBox(height: AppSize.h20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
