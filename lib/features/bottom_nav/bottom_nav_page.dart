import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/open_ad_provider.dart';
import '../../utils/navigation_helper.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../rank/rank_screen.dart';
import '../rewards/rewards_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    RankScreen(),
    RewardsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OpenAdProvider()..startOpenAdListener(),
      lazy: false,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _index,
          onChanged: (i) => NavigationHelper().navigateWithAdCheck(context, () => setState(() => _index = i)),
        ),
      ),
    );
  }
}
