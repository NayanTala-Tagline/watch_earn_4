import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';
import 'active_nav_tab.dart';
import 'nav_tab.dart';

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

const _items = <_NavItem>[
  _NavItem(Icons.home_rounded, 'Home'),
  _NavItem(Icons.emoji_events_rounded, 'Rank'),
  _NavItem(Icons.card_giftcard_rounded, 'Rewards'),
  _NavItem(Icons.person_rounded, 'Profile'),
];

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.currentIndex,
    required this.onChanged,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h8,
        AppSize.w16,
        AppSize.h12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w10,
          vertical: AppSize.h10,
        ),
        decoration: BoxDecoration(
          color: context.themeColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r32),
          boxShadow: [
            BoxShadow(
              color: context.themeTextColors.textColor.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            if (i == currentIndex) {
              return ActiveNavTab(
                icon: item.icon,
                label: item.label,
                onTap: () => onChanged(i),
              );
            }
            return NavTab(
              icon: item.icon,
              label: item.label,
              onTap: () => onChanged(i),
            );
          }),
        ),
      ),
    );
  }
}
