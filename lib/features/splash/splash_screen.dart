import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../gen/fonts.gen.dart';
import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final isLoggedIn = Injector.instance<AppDB>().userModel != null;
    if (isLoggedIn) {
      context.goNamed(AppRoutes.home);
    } else {
      context.goNamed(AppRoutes.onboarding1);
    }
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
                  .image(width: 210.w, height: 210.w)
                  .animate()
                  .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.55, 0.55),
                    end: const Offset(1, 1),
                    duration: 900.ms,
                    curve: Curves.easeOutBack,
                  )
                  .blurXY(begin: 14, end: 0, duration: 700.ms, curve: Curves.easeOutCubic)
                  .then(delay: 200.ms)
                  .shimmer(duration: 1400.ms, color: Colors.white.withValues(alpha: 0.6)),
              SizedBox(height: AppSize.h16),
              Text(
                'Rewardo',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2359),
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
        ],
      ),
    );
  }
}
