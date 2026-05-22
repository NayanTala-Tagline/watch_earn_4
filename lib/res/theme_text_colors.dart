// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

@immutable
class ThemeTextColors extends ThemeExtension<ThemeTextColors> {
  const ThemeTextColors({
    required this.textColor,
    required this.textBlackColor,
    required this.hintTextColor,
    required this.descriptionColor,
    required this.pastalYellow,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.bodyTextColor,
    required this.darkTitleColor,
    required this.mutedTextColor,
    required this.subtitleColor,
  });

  final Color textColor;
  final Color textBlackColor;
  final Color hintTextColor;
  final Color descriptionColor;
  final Color pastalYellow;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color bodyTextColor;
  final Color darkTitleColor;
  final Color mutedTextColor;
  final Color subtitleColor;

  @override
  ThemeTextColors copyWith({
    Color? textColor,
    Color? textBlackColor,
    Color? hintTextColor,
    Color? descriptionColor,
    Color? pastalYellow,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? bodyTextColor,
    Color? darkTitleColor,
    Color? mutedTextColor,
    Color? subtitleColor,
  }) {
    return ThemeTextColors(
      textColor: textColor ?? this.textColor,
      textBlackColor: textBlackColor ?? this.textBlackColor,
      hintTextColor: hintTextColor ?? this.hintTextColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
      pastalYellow: pastalYellow ?? this.pastalYellow,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      darkTitleColor: darkTitleColor ?? this.darkTitleColor,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
    );
  }

  @override
  ThemeExtension<ThemeTextColors> lerp(
    covariant ThemeExtension<ThemeTextColors>? other,
    double t,
  ) {
    if (other is! ThemeTextColors) return this;
    return ThemeTextColors(
      textColor: Color.lerp(textColor, other.textColor, t)!,
      textBlackColor: Color.lerp(textBlackColor, other.textBlackColor, t)!,
      hintTextColor: Color.lerp(hintTextColor, other.hintTextColor, t)!,
      descriptionColor: Color.lerp(descriptionColor, other.descriptionColor, t)!,
      pastalYellow: Color.lerp(pastalYellow, other.pastalYellow, t)!,
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      bodyTextColor: Color.lerp(bodyTextColor, other.bodyTextColor, t)!,
      darkTitleColor: Color.lerp(darkTitleColor, other.darkTitleColor, t)!,
      mutedTextColor: Color.lerp(mutedTextColor, other.mutedTextColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
    );
  }
}
