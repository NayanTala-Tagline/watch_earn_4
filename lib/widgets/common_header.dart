import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/navigation_helper.dart';

/// Common page header with a circular back button on the left, a centered
/// title, and an optional circular action button on the right.
class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool showLeading;
  final Color backgroundColor;
  final Color titleColor;
  final Color buttonColor;
  final Color iconColor;
  final double horizontalPadding;
  final double verticalPadding;

  static const _defaultBackground = Color(0xFFEAEFFC);
  static const _defaultTitleColor = Color(0xFF0B0E2C);

  const CommonHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.trailingIcon,
    this.onTrailingTap,
    this.showLeading = true,
    this.backgroundColor = _defaultBackground,
    this.titleColor = _defaultTitleColor,
    this.buttonColor = Colors.white,
    this.iconColor = _defaultTitleColor,
    this.horizontalPadding = 16,
    this.verticalPadding = 12,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.w,
            vertical: verticalPadding.h,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppSize.w40,
                height: AppSize.w40,
                child: showLeading
                    ? _CircleButton(
                        color: buttonColor,
                        iconColor: iconColor,
                        icon: Icons.arrow_back,
                        onTap: onBackPressed ??
                            () => NavigationHelper().handleBackPress(context),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp18,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
              ),
              SizedBox(
                width: AppSize.w42,
                height: AppSize.w42,
                child: trailingIcon != null
                    ? _CircleButton(
                        color: buttonColor,
                        iconColor: iconColor,
                        customChild: trailingIcon,
                        onTap: onTrailingTap,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.color,
    required this.iconColor,
    this.icon,
    this.customChild,
    this.onTap,
  });

  final Color color;
  final Color iconColor;
  final IconData? icon;
  final Widget? customChild;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: customChild ??
              Icon(
                icon,
                size: AppSize.sp20,
                color: iconColor,
              ),
        ),
      ),
    );
  }
}
