import 'package:flutter/material.dart';

import '../../../extension/ext_context.dart';
import '../../../utils/app_size.dart';

const _primaryBlue = Color(0xFF1A1AE8);
const _primaryBlueShadow = Color(0xFF0E0F66);

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
          color: _primaryBlue,
          borderRadius: BorderRadius.circular(AppSize.r20),
          boxShadow: const [
            BoxShadow(
              color: _primaryBlueShadow,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: AppSize.sp22),
            SizedBox(height: AppSize.h2),
            Text(
              label,
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
