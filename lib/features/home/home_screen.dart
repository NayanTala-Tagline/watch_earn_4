import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../gen/fonts.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../login/provider/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final user = Injector.instance<AppDB>().userModel;

    return Scaffold(
      backgroundColor: const Color(0xFFECEEFA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSize.h32),

              // Greeting
              Text(
                'Welcome, ${user?.name ?? 'User'}!',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2359),
                ),
              ),
              SizedBox(height: AppSize.h8),
              Text(
                user?.isGuest == true ? 'Playing as Guest' : user?.email ?? '',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  color: const Color(0xFF4A4E6B),
                ),
              ),

              SizedBox(height: AppSize.h32),

              // Coin balance card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSize.w20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.r16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB0BDD6).withValues(alpha: 0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded,
                        color: Color(0xFFFFBB00), size: 40),
                    SizedBox(width: AppSize.w16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coins',
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp13,
                            color: const Color(0xFF4A4E6B),
                          ),
                        ),
                        Text(
                          user?.coin.toStringAsFixed(0) ?? '0',
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C2359),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Sign-out
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Center(
                  child: TextButton(
                    onPressed: auth.isGoogleLoading
                        ? null
                        : () => _signOut(context, auth),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp15,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSize.h24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, AuthProvider auth) async {
    await auth.signOut();
    if (context.mounted) context.goNamed(AppRoutes.login);
  }
}
