import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';

/// Shared layout used by every onboarding screen.
///
/// [nativeAd] is displayed in [Scaffold.bottomNavigationBar] — shimmer while
/// loading, real widget once loaded, nothing when disabled/failed.
///
/// [onNext] is async so the screen can await the ad sequence (wait → show
/// interstitial → navigate) before this callback returns.
///
/// [isLoading] drives the button spinner while the provider's [wait] call runs.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onNext,
    required this.onSkip,
    this.nativeAd,
    this.isLoading = false,
  });

  final AssetGenImage image;
  final String title;
  final String subtitle;
  final String buttonText;
  final Future<void> Function() onNext;
  final VoidCallback onSkip;
  final NativeAdManager? nativeAd;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      bottomNavigationBar: _NativeAdBar(nativeAd: nativeAd),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Skip ─────────────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onSkip,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: AppSize.w20,
                    top: AppSize.h12,
                    bottom: AppSize.h8,
                    left: AppSize.w40,
                  ),
                  child: Text(
                    'Skip',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontSize: AppSize.sp16,
                      color: context.themeColors.navyColor,
                    ),
                  ),
                ),
              ),
            ),

            // ── Illustration ─────────────────────────────────────────────────
            // Expanded → auto-shrinks when the bottom nav bar gets a real ad.
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
                child: image
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

            // ── Title ─────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                title,
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

            // ── Subtitle ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                subtitle,
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

            SizedBox(height: AppSize.h28),

            // ── Button ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: AppButton(
                text: buttonText,
                isLoading: isLoading,
                buttonColor: context.themeColors.buttonColor,
                shadowColor: context.themeColors.buttonBorderColor,
                foregroundColor: context.themeColors.whiteColor,
                trailingIcon: Icon(
                  Icons.arrow_forward_rounded,
                  color: context.themeColors.whiteColor,
                  size: 20,
                ),
                borderRadius: AppSize.r29,
                onPressed: () => onNext(),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 450.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.25,
                    end: 0,
                    delay: 300.ms,
                    duration: 450.ms,
                    curve: Curves.easeOut,
                  ),
            ),

            SizedBox(height: AppSize.h16),
          ],
        ),
      ),
    );
  }
}

// ── Bottom native ad bar ──────────────────────────────────────────────────────

class _NativeAdBar extends StatelessWidget {
  const _NativeAdBar({this.nativeAd});

  final NativeAdManager? nativeAd;

  @override
  Widget build(BuildContext context) {
    final ad = nativeAd;

    if (ad == null) return const SizedBox.shrink();
    if (!ad.adData.enabled && ad.adData.adType != AdType.custom) {
      return const SizedBox.shrink();
    }

    final isCustom = ad.adData.adType == AdType.custom;
    final placeholderHeight =
        ad.adData.templateType == TemplateType.medium ? AppSize.h360 : AppSize.h100;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: AppSize.h5),
        child: Container(
          color: context.theme.cardColor,
          child: isCustom
              ? ad.adWidget()
              : ad.isLoaded
                  ? SizedBox(height: placeholderHeight, child: ad.adWidget())
                  : ad.isFailed
                      ? const SizedBox.shrink()
                      : Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: placeholderHeight,
                            color: context.theme.cardColor,
                          ),
                        ),
        ),
      ),
    );
  }
}
