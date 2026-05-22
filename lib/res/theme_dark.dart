
import 'package:watch_earn_4/res/theme_colors.dart';
import 'package:watch_earn_4/res/theme_text_colors.dart';
import 'package:flutter/material.dart';

import '../gen/fonts.gen.dart';
import '../utils/app_size.dart';

/// Application Theme
///
final _darkThemeData = ThemeData.dark(useMaterial3: true);

const _themeColors = ThemeColors(
  whiteColor: Color(0xFFFFFFFF),
  secondary2: Color(0xFFFBD7B7),
  backgroundColor: Color(0xFF000503),
  backgroundColor2: Color(0xFF062820),
  primary: Color(0xFF016B06),
  secondary: Color(0xFFF5D90A),
  borderColor: Color(0xFF003626),
  borderColor2: Color(0xFFF2D024),
  iconColor: Color(0xFFFFFFFF),
  cardColor: Color(0xFF192E40),
  buttonColor: Color(0xFF1CFF0C),
  buttonColor2: Color(0xFF1C6599),
  buttonBorderColor: Color(0xFF0E0F66),
  buttonBorderColor2: Color(0xFF9C004D),
  redColor: Color(0xFFFF3624),
  redColor2: Color(0xFFFF0040),
  navyColor: Color(0xFF1C2359),
  successColor: Color(0xFF4CAF50),
  successShadowColor: Color(0xFF2E7D32),
  coinGoldColor: Color(0xFFFFB800),
  coinAmberColor: Color(0xFFC97A00),
  coinSurfaceColor: Color(0xFFFFF1D6),
  coinTextColor: Color(0xFF7A4A00),
  daysPillSurfaceColor: Color(0xFFFFE3EE),
  xpBadgeColor: Color(0xFFE6E7FF),
  dailyRewardGradientStart: Color(0xFFFFF1E0),
  dailyRewardGradientEnd: Color(0xFFFFE0C9),
  gradientColor: Color(0xFF013717),
  gradientColor2: Color(0xFF0D9191),
  fieldBgColor: Color(0xFFF6F7FB),
  linkColor: Color(0xFF4A6CF7),
  progressBgColor: Color(0xFFE8EAF0),
  adPlaceholderBg: Color(0xFFF5E8FF),
  adPlaceholderBorder: Color(0xFFDEC6F5),
  adPlaceholderText: Color(0xFFBB86CC),
  dragHandleColor: Color(0xFFCDD2E0),
  cardShadowColor: Color(0x140E0F66),
  toggleActiveColor: Color(0xFF009A65),
  toggleInactiveColor: Color(0xFFB8BDD4),
  howCardBgStart: Color(0xFFFFE5C8),
  howCardBgEnd: Color(0xFFFFD8E2),
  howCardIconBg: Color(0xFFFFC56C),
  codePillShadowColor: Color(0xFF6B7393),
  webviewNavColor: Color(0xFF0E3E4F),
);

const _themeTextColors = ThemeTextColors(
  textColor: Color(0xFFFFFFFF),
  textBlackColor: Color(0xFF1D1B06),
  hintTextColor: Color(0xFF757575),
  descriptionColor: Color(0xFFBCC4C8),
  pastalYellow: Color(0xF3DCC1CC),
  primaryTextColor: Color(0xFF0B0E2C),
  secondaryTextColor: Color(0xFF5BF2DA),
  bodyTextColor: Color(0xFF8A8FA8),
  darkTitleColor: Color(0xFF0B0E2C),
  mutedTextColor: Color(0xFF9AA0B5),
  subtitleColor: Color(0xFF3D4778),
);

final TextTheme _textTheme = _darkThemeData.textTheme.copyWith(
  titleLarge: TextStyle(
    fontWeight: FontWeight.w700,
    color: _themeTextColors.textColor,
    fontFamily: FontFamily.kommonGrotesk,
    fontSize: AppSize.sp16,
    inherit: false,
  ),
  titleMedium: TextStyle(
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.kommonGrotesk,
    color: _themeTextColors.textColor,
    // inherit: false,
    fontSize: AppSize.sp14,
  ),
  titleSmall: TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.kommonGrotesk,
    color: _themeTextColors.textColor,
    // inherit: false,
    fontSize: AppSize.sp14,
  ),
  bodyLarge: TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.kommonGrotesk,
    color: _themeTextColors.textColor,
    // inherit: false,
    fontSize: AppSize.sp14,
  ),
  bodyMedium: TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.kommonGrotesk,
    color: _themeTextColors.textColor,

    // inherit: false,
    fontSize: AppSize.sp14,
  ),
  bodySmall: TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.kommonGrotesk,
    color: _themeTextColors.textColor,

    // inherit: false,
    fontSize: AppSize.sp14,
  ),
  /*labelSmall: TextStyle(
          fontFamily: FontFamily.kommonGrotesk,
          fontWeight: FontWeight.w200,
          color: _themeTextColors.text,
        ),*/
);

/// Tab bar theme
final _tabBarTheme = TabBarThemeData(
  labelColor: _themeTextColors.textColor,
  labelStyle: _textTheme.titleLarge,
  unselectedLabelStyle: _textTheme.titleLarge,
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: _themeColors.backgroundColor),
    insets: EdgeInsets.symmetric(vertical: AppSize.sp10),
  ),
  overlayColor: WidgetStateProperty.all<Color>(Colors.grey.shade100),
  unselectedLabelColor: _themeTextColors.hintTextColor,
);

/// Application Dark Theme
final ThemeData darkTheme = _darkThemeData.copyWith(
  colorScheme: ColorScheme.dark(primary: _themeColors.primary),
  cardColor: Colors.grey.shade200,
  splashColor: Colors.transparent,
  scaffoldBackgroundColor: _themeColors.backgroundColor,
  textTheme: _textTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: _themeColors.primary,
    centerTitle: true,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: FontFamily.kommonGrotesk,
      color: _themeTextColors.textColor,
      fontSize: AppSize.sp16,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: _themeColors.iconColor,
      disabledBackgroundColor: _themeColors.borderColor,
      disabledForegroundColor: _themeTextColors.hintTextColor,
      maximumSize: Size(double.infinity, AppSize.h48),
      minimumSize: Size(AppSize.w64, AppSize.h48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _textTheme.bodyMedium?.copyWith(
        fontSize: AppSize.sp18,
        fontWeight: FontWeight.w700,
        color: _themeColors.iconColor,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _themeColors.primary,
      disabledBackgroundColor: _themeColors.borderColor,
      disabledForegroundColor: _themeTextColors.hintTextColor,
      maximumSize: Size(double.infinity, AppSize.h48),
      minimumSize: Size(AppSize.w64, AppSize.h48),
      side: BorderSide(color: _themeColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: _textTheme.bodyMedium?.copyWith(
        fontSize: AppSize.sp16,
        fontWeight: FontWeight.w700,
        color: _themeColors.cardColor,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _themeTextColors.textColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.sp12)),
      textStyle: _textTheme.bodyMedium?.copyWith(
        fontSize: AppSize.sp16,
        fontWeight: FontWeight.w700,
        color: _themeTextColors.textColor,
      ),
    ),
  ),
  extensions: <ThemeExtension<dynamic>>[_themeColors, _themeTextColors],
  tabBarTheme: _tabBarTheme,
);
