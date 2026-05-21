import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_earn_4/extension/ext_context.dart';

import '../../gen/assets.gen.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';

/// Shared layout used by every onboarding screen.
///
/// The illustration sits inside [Expanded] so it automatically gives up
/// vertical space when the ad slot below is filled with a real banner widget.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onNext,
    required this.onSkip,
  });

  final AssetGenImage image;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEEFA),
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
                      color: const Color(0xFF1C2359),
                    ),
                  ),
                ),
              ),
            ),

            // ── Illustration ─────────────────────────────────────────────────
            // Expanded → auto-shrinks when the ad slot below gets a real widget.
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
                  color: const Color(0xFF1C2359),
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
                  color: const Color(0xFF4A4E6B),
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
                buttonColor: context.themeColors.buttonColor,
                shadowColor: context.themeColors.buttonBorderColor,
                foregroundColor: Colors.white,
                trailingIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                borderRadius: AppSize.r29,
                onPressed: onNext,
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

            SizedBox(height: AppSize.h24),
          ],
        ),
      ),
    );
  }
}
