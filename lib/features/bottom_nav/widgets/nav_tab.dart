import 'package:flutter/material.dart';

import '../../../gen/fonts.gen.dart';
import '../../../utils/app_size.dart';

const _bodyColor = Color(0xFF8A8FA8);

class NavTab extends StatelessWidget {
  const NavTab({
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
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(AppSize.r12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w14,
          vertical: AppSize.h6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _bodyColor, size: AppSize.sp22),
            SizedBox(height: AppSize.h4),
            Text(
              label,
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w600,
                color: _bodyColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
