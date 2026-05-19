import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import '../../gen/fonts.gen.dart';
import '../../utils/app_size.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                _buildHeadline(),
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

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.only(left: AppSize.w20, top: AppSize.h16),
      child: Assets.images.splash.splashLogo
          .image(width: 130.w, height: 130.w)
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

  Widget _buildHeadline() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start Earning\nRewards',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp38,
              fontWeight: FontWeight.w700,
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
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w400,
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

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        children: [
          _ThreeDButton(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.icGoogle.svg(width: 26.w, height: 26.w),
                SizedBox(width: AppSize.w12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C2359),
                  ),
                ),
              ],
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
          _ThreeDButton(
            onTap: () {},
            child: Text(
              'Continue as Guest',
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C2359),
              ),
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
        ],
      ),
    );
  }

  Widget _buildTerms(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp13,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Terms of Service',
              recognizer: TapGestureRecognizer()..onTap = () {},
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp13,
                color: const Color(0xFF4A6CF7),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF4A6CF7),
              ),
            ),
            TextSpan(
              text: ' and ',
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp13,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Privacy Policy',
              recognizer: TapGestureRecognizer()..onTap = () {},
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp13,
                color: const Color(0xFF4A6CF7),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF4A6CF7),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      )
          .animate()
          .fadeIn(delay: 550.ms, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}

// ── 3D pill button ─────────────────────────────────────────────────────────

class _ThreeDButton extends StatefulWidget {
  const _ThreeDButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<_ThreeDButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) {
          // When pressed: button shifts down by 4px, bottom wall shrinks to 0
          final pressOffset = _pressAnim.value * 4.0;
          final wallHeight = (1 - _pressAnim.value) * 5.0;
          final shadowOpacity = (1 - _pressAnim.value) * 0.18;

          return Transform.translate(
            offset: Offset(0, pressOffset),
            child: Container(
              width: double.infinity,
              height: 58.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(29.r),
                boxShadow: [
                  // Bottom "wall" — solid offset gives 3D depth
                  BoxShadow(
                    color: const Color(0xFFB0BDD6),
                    offset: Offset(0, wallHeight),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  // Ambient drop shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
