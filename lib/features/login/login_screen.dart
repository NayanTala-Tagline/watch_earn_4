import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/extension/ext_context.dart';

import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import 'provider/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.splash.splashBg.image(fit: BoxFit.cover),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                SizedBox(height: AppSize.h30),
                _buildHeadline(context),
                const Spacer(),
                _buildButtons(context),
                SizedBox(height: AppSize.h16),
                _buildTerms(context),
                SizedBox(height: AppSize.h28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ─────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.only(left: AppSize.w20, top: AppSize.h16),
      child: Assets.images.splash.splashLogo
          .image(width: AppSize.w130, height: AppSize.w130)
          .animate()
          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1, 1),
            duration: 700.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  // ── Headline ─────────────────────────────────────────────────────────────

  Widget _buildHeadline(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start Earning\nRewards',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp38,
              color: const Color(0xFF1C2359),
              height: 1.15,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 600.ms, curve: Curves.easeOut)
              .slideX(
                begin: -0.15,
                end: 0,
                delay: 150.ms,
                duration: 600.ms,
                curve: Curves.easeOut,
              ),
          SizedBox(height: AppSize.h14),
          Text(
            'Complete tasks, play games, and earn coins that convert to real money!',
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: AppSize.sp16,
              color: const Color(0xFF3D4778),
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 600.ms, curve: Curves.easeOut)
              .slideX(
                begin: -0.15,
                end: 0,
                delay: 250.ms,
                duration: 600.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        children: [
          // Google sign-in
          Consumer<AuthProvider>(
            builder: (context, auth, _) => AppButton(
              text: 'Continue with Google',
              icon: Assets.icons.icGoogle.svg(width: AppSize.w26, height: AppSize.w26),
              isLoginButton: true,
              isLoading: auth.isGoogleLoading,
              isDisabled: auth.isGuestLoading,
              buttonColor: Colors.white,
              shadowColor: context.themeColors.borderColor,
              foregroundColor: const Color(0xFF1C2359),
              borderRadius: AppSize.r29,
              onPressed: () => _handleGoogle(context, auth),
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 500.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 350.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),

          SizedBox(height: AppSize.h16),

          // Guest
          Consumer<AuthProvider>(
            builder: (context, auth, _) => AppButton(
              text: 'Continue as Guest',
              isLoading: auth.isGuestLoading,
              isDisabled: auth.isGoogleLoading,
              buttonColor: Colors.white,
              shadowColor: context.themeColors.borderColor,
              foregroundColor: const Color(0xFF1C2359),
              borderRadius: AppSize.r29,
              onPressed: () => _handleGuest(context, auth),
            ),
          )
              .animate()
              .fadeIn(delay: 450.ms, duration: 500.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 450.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),

          // Error message
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.errorMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: AppSize.h12),
                child: Text(
                  auth.errorMessage!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: AppSize.sp13,
                    color: Colors.redAccent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Terms ─────────────────────────────────────────────────────────────────

  Widget _buildTerms(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: AppSize.sp13,
                color: const Color(0xFF6B7280),
              ),
            ),
            TextSpan(
              text: 'Terms of Service',
              recognizer: TapGestureRecognizer()..onTap = () {},
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: AppSize.sp13,
                color: const Color(0xFF4A6CF7),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF4A6CF7),
              ),
            ),
            TextSpan(
              text: ' and ',
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: AppSize.sp13,
                color: const Color(0xFF6B7280),
              ),
            ),
            TextSpan(
              text: 'Privacy Policy',
              recognizer: TapGestureRecognizer()..onTap = () {},
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: AppSize.sp13,
                color: const Color(0xFF4A6CF7),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF4A6CF7),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(delay: 550.ms, duration: 500.ms, curve: Curves.easeOut),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _handleGoogle(BuildContext context, AuthProvider auth) async {
    final ok = await auth.signInWithGoogle();
    if (ok && context.mounted) context.goNamed(AppRoutes.home);
  }

  Future<void> _handleGuest(BuildContext context, AuthProvider auth) async {
    final ok = await auth.continueAsGuest();
    if (ok && context.mounted) context.goNamed(AppRoutes.home);
  }
}
