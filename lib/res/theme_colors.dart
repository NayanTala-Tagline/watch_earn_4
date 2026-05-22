// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

@immutable
class ThemeColors extends ThemeExtension<ThemeColors> {
  const ThemeColors({
    required this.backgroundColor,
    required this.backgroundColor2,
    required this.primary,
    required this.secondary,
    required this.whiteColor,
    required this.borderColor,
    required this.iconColor,
    required this.cardColor,
    required this.borderColor2,
    required this.redColor,
    required this.redColor2,
    required this.buttonColor,
    required this.buttonColor2,
    required this.buttonBorderColor,
    required this.buttonBorderColor2,
    required this.gradientColor,
    required this.gradientColor2,
    required this.secondary2,
    required this.navyColor,
    required this.successColor,
    required this.successShadowColor,
    required this.coinGoldColor,
    required this.coinAmberColor,
    required this.coinSurfaceColor,
    required this.coinTextColor,
    required this.daysPillSurfaceColor,
    required this.xpBadgeColor,
    required this.dailyRewardGradientStart,
    required this.dailyRewardGradientEnd,
    required this.fieldBgColor,
    required this.linkColor,
    required this.progressBgColor,
    required this.adPlaceholderBg,
    required this.adPlaceholderBorder,
    required this.adPlaceholderText,
    required this.dragHandleColor,
    required this.cardShadowColor,
    required this.toggleActiveColor,
    required this.toggleInactiveColor,
    required this.howCardBgStart,
    required this.howCardBgEnd,
    required this.howCardIconBg,
    required this.codePillShadowColor,
    required this.webviewNavColor,
  });

  final Color backgroundColor;
  final Color backgroundColor2;
  final Color primary;
  final Color secondary;
  final Color whiteColor;
  final Color borderColor;
  final Color iconColor;
  final Color cardColor;
  final Color borderColor2;
  final Color redColor;
  final Color redColor2;
  final Color buttonColor;
  final Color buttonColor2;
  final Color buttonBorderColor;
  final Color buttonBorderColor2;
  final Color gradientColor;
  final Color gradientColor2;
  final Color secondary2;
  final Color navyColor;
  final Color successColor;
  final Color successShadowColor;
  final Color coinGoldColor;
  final Color coinAmberColor;
  final Color coinSurfaceColor;
  final Color coinTextColor;
  final Color daysPillSurfaceColor;
  final Color xpBadgeColor;
  final Color dailyRewardGradientStart;
  final Color dailyRewardGradientEnd;
  final Color fieldBgColor;
  final Color linkColor;
  final Color progressBgColor;
  final Color adPlaceholderBg;
  final Color adPlaceholderBorder;
  final Color adPlaceholderText;
  final Color dragHandleColor;
  final Color cardShadowColor;
  final Color toggleActiveColor;
  final Color toggleInactiveColor;
  final Color howCardBgStart;
  final Color howCardBgEnd;
  final Color howCardIconBg;
  final Color codePillShadowColor;
  final Color webviewNavColor;

  @override
  ThemeColors copyWith({
    Color? backgroundColor,
    Color? backgroundColor2,
    Color? primary,
    Color? secondary,
    Color? whiteColor,
    Color? borderColor,
    Color? iconColor,
    Color? cardColor,
    Color? borderColor2,
    Color? redColor,
    Color? redColor2,
    Color? buttonColor,
    Color? buttonColor2,
    Color? buttonBorderColor,
    Color? buttonBorderColor2,
    Color? gradientColor,
    Color? gradientColor2,
    Color? secondary2,
    Color? navyColor,
    Color? successColor,
    Color? successShadowColor,
    Color? coinGoldColor,
    Color? coinAmberColor,
    Color? coinSurfaceColor,
    Color? coinTextColor,
    Color? daysPillSurfaceColor,
    Color? xpBadgeColor,
    Color? dailyRewardGradientStart,
    Color? dailyRewardGradientEnd,
    Color? fieldBgColor,
    Color? linkColor,
    Color? progressBgColor,
    Color? adPlaceholderBg,
    Color? adPlaceholderBorder,
    Color? adPlaceholderText,
    Color? dragHandleColor,
    Color? cardShadowColor,
    Color? toggleActiveColor,
    Color? toggleInactiveColor,
    Color? howCardBgStart,
    Color? howCardBgEnd,
    Color? howCardIconBg,
    Color? codePillShadowColor,
    Color? webviewNavColor,
  }) {
    return ThemeColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundColor2: backgroundColor2 ?? this.backgroundColor2,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      whiteColor: whiteColor ?? this.whiteColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      cardColor: cardColor ?? this.cardColor,
      borderColor2: borderColor2 ?? this.borderColor2,
      redColor: redColor ?? this.redColor,
      redColor2: redColor2 ?? this.redColor2,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonColor2: buttonColor2 ?? this.buttonColor2,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderColor2: buttonBorderColor2 ?? this.buttonBorderColor2,
      gradientColor: gradientColor ?? this.gradientColor,
      gradientColor2: gradientColor2 ?? this.gradientColor2,
      secondary2: secondary2 ?? this.secondary2,
      navyColor: navyColor ?? this.navyColor,
      successColor: successColor ?? this.successColor,
      successShadowColor: successShadowColor ?? this.successShadowColor,
      coinGoldColor: coinGoldColor ?? this.coinGoldColor,
      coinAmberColor: coinAmberColor ?? this.coinAmberColor,
      coinSurfaceColor: coinSurfaceColor ?? this.coinSurfaceColor,
      coinTextColor: coinTextColor ?? this.coinTextColor,
      daysPillSurfaceColor: daysPillSurfaceColor ?? this.daysPillSurfaceColor,
      xpBadgeColor: xpBadgeColor ?? this.xpBadgeColor,
      dailyRewardGradientStart: dailyRewardGradientStart ?? this.dailyRewardGradientStart,
      dailyRewardGradientEnd: dailyRewardGradientEnd ?? this.dailyRewardGradientEnd,
      fieldBgColor: fieldBgColor ?? this.fieldBgColor,
      linkColor: linkColor ?? this.linkColor,
      progressBgColor: progressBgColor ?? this.progressBgColor,
      adPlaceholderBg: adPlaceholderBg ?? this.adPlaceholderBg,
      adPlaceholderBorder: adPlaceholderBorder ?? this.adPlaceholderBorder,
      adPlaceholderText: adPlaceholderText ?? this.adPlaceholderText,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      toggleActiveColor: toggleActiveColor ?? this.toggleActiveColor,
      toggleInactiveColor: toggleInactiveColor ?? this.toggleInactiveColor,
      howCardBgStart: howCardBgStart ?? this.howCardBgStart,
      howCardBgEnd: howCardBgEnd ?? this.howCardBgEnd,
      howCardIconBg: howCardIconBg ?? this.howCardIconBg,
      codePillShadowColor: codePillShadowColor ?? this.codePillShadowColor,
      webviewNavColor: webviewNavColor ?? this.webviewNavColor,
    );
  }

  @override
  ThemeExtension<ThemeColors> lerp(
    covariant ThemeExtension<ThemeColors>? other,
    double t,
  ) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      backgroundColor2: Color.lerp(backgroundColor2, other.backgroundColor2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor2: Color.lerp(borderColor2, other.borderColor2, t)!,
      redColor: Color.lerp(redColor, other.redColor, t)!,
      redColor2: Color.lerp(redColor2, other.redColor2, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      buttonColor2: Color.lerp(buttonColor2, other.buttonColor2, t)!,
      buttonBorderColor: Color.lerp(buttonBorderColor, other.buttonBorderColor, t)!,
      buttonBorderColor2: Color.lerp(buttonBorderColor2, other.buttonBorderColor2, t)!,
      gradientColor: Color.lerp(gradientColor, other.gradientColor, t)!,
      gradientColor2: Color.lerp(gradientColor2, other.gradientColor2, t)!,
      secondary2: Color.lerp(secondary2, other.secondary2, t)!,
      navyColor: Color.lerp(navyColor, other.navyColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      successShadowColor: Color.lerp(successShadowColor, other.successShadowColor, t)!,
      coinGoldColor: Color.lerp(coinGoldColor, other.coinGoldColor, t)!,
      coinAmberColor: Color.lerp(coinAmberColor, other.coinAmberColor, t)!,
      coinSurfaceColor: Color.lerp(coinSurfaceColor, other.coinSurfaceColor, t)!,
      coinTextColor: Color.lerp(coinTextColor, other.coinTextColor, t)!,
      daysPillSurfaceColor: Color.lerp(daysPillSurfaceColor, other.daysPillSurfaceColor, t)!,
      xpBadgeColor: Color.lerp(xpBadgeColor, other.xpBadgeColor, t)!,
      dailyRewardGradientStart: Color.lerp(dailyRewardGradientStart, other.dailyRewardGradientStart, t)!,
      dailyRewardGradientEnd: Color.lerp(dailyRewardGradientEnd, other.dailyRewardGradientEnd, t)!,
      fieldBgColor: Color.lerp(fieldBgColor, other.fieldBgColor, t)!,
      linkColor: Color.lerp(linkColor, other.linkColor, t)!,
      progressBgColor: Color.lerp(progressBgColor, other.progressBgColor, t)!,
      adPlaceholderBg: Color.lerp(adPlaceholderBg, other.adPlaceholderBg, t)!,
      adPlaceholderBorder: Color.lerp(adPlaceholderBorder, other.adPlaceholderBorder, t)!,
      adPlaceholderText: Color.lerp(adPlaceholderText, other.adPlaceholderText, t)!,
      dragHandleColor: Color.lerp(dragHandleColor, other.dragHandleColor, t)!,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t)!,
      toggleActiveColor: Color.lerp(toggleActiveColor, other.toggleActiveColor, t)!,
      toggleInactiveColor: Color.lerp(toggleInactiveColor, other.toggleInactiveColor, t)!,
      howCardBgStart: Color.lerp(howCardBgStart, other.howCardBgStart, t)!,
      howCardBgEnd: Color.lerp(howCardBgEnd, other.howCardBgEnd, t)!,
      howCardIconBg: Color.lerp(howCardIconBg, other.howCardIconBg, t)!,
      codePillShadowColor: Color.lerp(codePillShadowColor, other.codePillShadowColor, t)!,
      webviewNavColor: Color.lerp(webviewNavColor, other.webviewNavColor, t)!,
    );
  }
}
