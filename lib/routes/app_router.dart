import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../db/app_db.dart';
import '../di/injector.dart';
import '../features/language_screen/language_screen.dart';
import '../features/bottom_nav/bottom_nav_page.dart';
import '../features/quiz_master/quiz_master_screen.dart';
import '../features/scratch_card/scratch_card_screen.dart';
import '../features/web_visits/web_visits_screen.dart';
import '../features/game_zone/game_zone_screen.dart';
import '../features/achievements/achievement_screen.dart';
import '../features/support/support_screen.dart';
import '../widgets/in_app_webview_page.dart';
import 'package:ad_manager/models/ad_data.dart';
import '../features/refer_and_earn/refer_and_earn_screen.dart';
import '../features/spin_wheel/spin_wheel_screen.dart';
import '../features/withdraw/withdraw_screen.dart';
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
      pageBuilder: (context, state) {
        final fromSettings = state.extra == true;
        return MaterialPage(
          key: state.pageKey,
          child: LanguageScreen(fromSettings: fromSettings),
        );
      },
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
          MaterialPage(key: state.pageKey, child: const BottomNavPage()),
    ),
    GoRoute(
      path: '/${AppRoutes.spinWheel}',
      name: AppRoutes.spinWheel,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SpinWheelScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.referAndEarn}',
      name: AppRoutes.referAndEarn,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ReferAndEarnScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.withdraw}',
      name: AppRoutes.withdraw,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const WithdrawScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.quiz}',
      name: AppRoutes.quiz,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const QuizMasterScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.scratchCard}',
      name: AppRoutes.scratchCard,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ScratchCardScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.webVisits}',
      name: AppRoutes.webVisits,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const WebVisitsScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.gameZone}',
      name: AppRoutes.gameZone,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const GameZoneScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.achievements}',
      name: AppRoutes.achievements,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const AchievementScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.contactUs}',
      name: AppRoutes.contactUs,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SupportScreen()),
    ),
    GoRoute(
      path: '/${AppRoutes.inAppWebView}',
      name: AppRoutes.inAppWebView,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return MaterialPage(
          key: state.pageKey,
          child: InAppWebViewPage(
            url: extra['url'] as String,
            title: extra['title'] as String,
            durationSeconds: extra['durationSeconds'] as int,
            coins: extra['coins'] as int,
            adData: extra['adData'] as AdData,
            onRewardClaimed: extra['onRewardClaimed'] as VoidCallback?,
          ),
        );
      },
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
