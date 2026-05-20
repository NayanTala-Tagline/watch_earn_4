import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../db/app_db.dart';
import '../di/injector.dart';
import '../features/home/home_screen.dart';
import '../features/language_screen/language_screen.dart';
import '../features/spin_wheel/spin_wheel_screen.dart';
import '../features/login/login_screen.dart';
import '../features/onboarding/onboarding1_screen.dart';
import '../features/onboarding/onboarding2_screen.dart';
import '../features/onboarding/onboarding3_screen.dart';
import '../features/splash/splash_screen.dart';

part 'app_routes.dart';
part 'bottom_nav_routes.dart';

/// root navigation key
final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Scaffold navigation key
final GlobalKey<ScaffoldMessengerState> sfMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'appScaffold');

final AppDB _db = Injector.instance<AppDB>();
final FirebaseAuth _auth = FirebaseAuth.instance;

/// Onboarding completed AND logged in → straight to home.
bool get _isNavigateStart =>
    _db.isOnboardingCompleted == true && _auth.currentUser != null;

/// Onboarding completed but NOT logged in → straight to login.
bool get _isNavigateAuth =>
    _db.isOnboardingCompleted == true && _auth.currentUser == null;

String _initialLocation() {
  if (_isNavigateStart) return '/${AppRoutes.home}';
  if (_isNavigateAuth) return '/${AppRoutes.login}';
  // Fresh install or onboarding not yet finished → show splash → onboarding.
  return '/${AppRoutes.splash}';
}

/// current route
String? currentRoute;

/// global GoRouter instance which has all page routes
final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  debugLogDiagnostics: kDebugMode,
  initialLocation: _initialLocation(),
  redirect: (context, state) {
    switch (state.fullPath) {
      case '/':
        return '/${AppRoutes.splash}';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const Scaffold()),
    ),
    GoRoute(
      path: '/${AppRoutes.splash}',
      name: AppRoutes.splash,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding1}',
      name: AppRoutes.onboarding1,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const Onboarding1Screen()),
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding2}',
      name: AppRoutes.onboarding2,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const Onboarding2Screen()),
    ),
    GoRoute(
      path: '/${AppRoutes.onboarding3}',
      name: AppRoutes.onboarding3,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const Onboarding3Screen()),
    ),
    GoRoute(
      path: '/${AppRoutes.language}',
      name: AppRoutes.language,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const LanguageScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.login}',
      name: AppRoutes.login,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.home}',
      name: AppRoutes.home,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const HomeScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.spinWheel}',
      name: AppRoutes.spinWheel,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SpinWheelScreen()),
    ),

    // Loan-finder flow — shared LoanFinderProvider (form) +
    // LoanFinderAdProvider (ads) across all 7 steps.

    // StatefulShellRoute.indexedStack(
    //   builder: (context, state, navigationShell) {
    //     return BottomNavPage(key: state.pageKey, child: navigationShell);
    //   },
    //   branches: _bottomNavBranches,
    // ),
  ],
);
