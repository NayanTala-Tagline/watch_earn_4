// import 'package:clipboard/clipboard.dart';
import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

import '../routes/app_router.dart';
import '../utils/app_size.dart';
import 'ext_context.dart';

/// extension for [String] to show alerts
extension StringX on String {
  /// to show error alert
  void showErrorAlert({Duration? duration}) => rootNavKey.currentContext!.showFlash<void>(
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        behavior: FlashBehavior.floating,
        content: Text(this, style: rootNavKey.currentContext!.textTheme.bodyMedium?.copyWith(color: context.themeTextColors.secondaryTextColor)),
        backgroundColor: context.themeColors.primary,
        indicatorColor: context.themeColors.redColor,
        icon: Icon(Icons.error_outline, color: context.themeColors.redColor),
        shouldIconPulse: false,
        margin: EdgeInsets.symmetric(horizontal: AppSize.h16, vertical: AppSize.h16),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.h16)),
        forwardAnimationCurve: Curves.bounceOut,
        // reverseAnimationCurve: Curves.bounceOut,
      );
    },
    duration: duration ?? const Duration(seconds: 3),
  );

  /// to show success alert
  void showSuccessAlert({Duration? duration}) => rootNavKey.currentContext!.showFlash<void>(
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        behavior: FlashBehavior.floating,
        content: Text(this, style: rootNavKey.currentContext!.textTheme.bodyMedium?.copyWith(color: context.themeTextColors.secondaryTextColor)),
        backgroundColor: context.themeColors.primary,
        indicatorColor: context.themeColors.successColor,
        icon: Icon(Icons.check_circle_outline, color: context.themeColors.successColor),
        shouldIconPulse: false,
        margin: EdgeInsets.symmetric(horizontal: AppSize.h16, vertical: AppSize.h16),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.h16)),
        forwardAnimationCurve: Curves.bounceOut,
        // reverseAnimationCurve: Curves.bounceOut,
      );
    },
    duration: duration ?? const Duration(seconds: 3),
  );

  /// to show info alert
  void showInfoAlert({Duration? duration}) => rootNavKey.currentContext!.showFlash<void>(
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        behavior: FlashBehavior.floating,
        content: Text(this, style: rootNavKey.currentContext!.textTheme.bodyMedium?.copyWith(color: context.themeTextColors.secondaryTextColor)),
        backgroundColor: context.themeColors.primary,
        indicatorColor: context.themeColors.linkColor,
        icon: Icon(Icons.info_outline, color: context.themeColors.linkColor),
        shouldIconPulse: false,
        margin: EdgeInsets.symmetric(horizontal: AppSize.h16, vertical: AppSize.h16),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.h16)),
        forwardAnimationCurve: Curves.bounceOut,
        // reverseAnimationCurve: Curves.bounceOut,
      );
    },
    duration: duration ?? const Duration(seconds: 2),
  );

  /// function to copy string to clipboard
  // void copyToClipboard({String? alert}) {
  //   FlutterClipboard.copy(this);
  //   // As discussed with QA team : changing showInfoAlert to showSuccessAlert
  //   (alert ?? rootNavKey.currentContext?.l10n.copied)?.showSuccessAlert();
  //   HapticFeedback.mediumImpact();
  // }
}
