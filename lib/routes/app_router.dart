import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/language_screen/language_screen.dart';
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


/// current route
String? currentRoute;

/// global GoRouter instance which has all page routes
final appRouter = GoRouter(
  navigatorKey: rootNavKey,
  debugLogDiagnostics: kDebugMode,
  //  observers: [AdNavigationObserver()],
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
