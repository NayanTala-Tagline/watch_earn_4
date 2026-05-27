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

List<_NavItem> _buildItems(BuildContext context) => [
      _NavItem(Icons.home_rounded, context.l10n.home),
      _NavItem(Icons.emoji_events_rounded, context.l10n.rank),
      _NavItem(Icons.card_giftcard_rounded, context.l10n.rewards),
      _NavItem(Icons.person_rounded, context.l10n.profile),
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
    final items = _buildItems(context);
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
          children: List.generate(items.length, (i) {
            final item = items[i];
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
