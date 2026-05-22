import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

class ActiveNavTab extends StatelessWidget {
  const ActiveNavTab({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSize.h4),
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w18,
          vertical: AppSize.h8,
        ),
        decoration: BoxDecoration(
          color: context.themeColors.buttonColor,
          borderRadius: BorderRadius.circular(AppSize.r20),
          boxShadow: [
            BoxShadow(
              color: context.themeColors.buttonBorderColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: context.themeColors.whiteColor, size: AppSize.sp22),
            SizedBox(height: AppSize.h2),
            Text(
              label,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w800,
                color: context.themeColors.whiteColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
