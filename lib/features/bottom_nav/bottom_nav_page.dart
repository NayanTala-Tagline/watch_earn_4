import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../provider/open_ad_provider.dart';
import '../../utils/navigation_helper.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../rank/rank_screen.dart';
import '../rewards/rewards_screen.dart';
import 'widgets/bottom_nav_bar.dart';

/// Drives the [BottomNavPage] tab selection so other screens
/// (e.g. home's "Rewards" button) can switch tabs without pushing routes.
class BottomNavController extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setIndex(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }
}

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  DateTime? _lastBackPressAt;

  static const _screens = <Widget>[
    HomeScreen(),
    RankScreen(),
    RewardsScreen(),
    ProfileScreen(),
  ];

  void _handlePop(BuildContext context, BottomNavController controller) {
    if (controller.index != 0) {
      controller.setIndex(0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      context.l10n.pressAgainToExit.showInfoAlert();
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OpenAdProvider()..startOpenAdListener(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => BottomNavController()),
      ],
      child: Consumer<BottomNavController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _handlePop(context, controller);
            },
            child: Scaffold(
              body: IndexedStack(index: controller.index, children: _screens),
              bottomNavigationBar: BottomNavBar(
                currentIndex: controller.index,
                onChanged: (i) => NavigationHelper().navigateWithAdCheck(
                  context,
                  () => controller.setIndex(i),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
