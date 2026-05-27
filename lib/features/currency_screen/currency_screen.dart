import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../country_screen/country_screen.dart' show EmojiTile;

class _Currency {
  const _Currency(this.name, this.symbol);
  final String name;
  final String symbol;
}

const _currencies = [
  _Currency('Indian Rupees', '₹'),
  _Currency('Naira', '₦'),
  _Currency('Dollor', '\$'),
  _Currency('Euro', '€'),
  _Currency('Thai', '฿'),
  _Currency('Peso', '₱'),
  _Currency('Pound', '£'),
  _Currency('Yen', '¥'),
  _Currency('Won', '₩'),
  _Currency('Lira', '₺'),
];

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String? _selectedName;
  InlineAdManager? _nativeAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'currency',
      screenClass: 'CurrencyScreen',
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    _nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.currencyNative,
    );
    await _nativeAd!.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _onSelect(String name) => setState(() => _selectedName = name);

  void _onConfirm() {
    if (_selectedName == null) {
      'Please select a currency'.showInfoAlert();
      return;
    }
    Injector.instance<AppDB>().isOnboardingCompleted = true;
    context.goNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        bottomNavigationBar: AdSlot(ad: _nativeAd),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSize.h24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Choose your currency',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: AppSize.sp28,
                          color: context.themeColors.navyColor,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                          .slideX(
                            begin: -0.08,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Select your currency which are you like.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.themeTextColors.subtitleColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: context.themeColors.primary),
                    ),
                    SizedBox(width: AppSize.w8),
                    Text(
                      'Available Currency',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp13,
                        color: context.themeColors.navyColor,
                      ),
                    ),
                    SizedBox(width: AppSize.w8),
                    Expanded(
                      child: Divider(color: context.themeColors.primary),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: AppSize.h10),
                    itemCount: _currencies.length,
                    separatorBuilder: (_, _) => SizedBox(height: AppSize.h12),
                    itemBuilder: (context, index) {
                      final c = _currencies[index];
                      return EmojiTile(
                        name: c.name,
                        emoji: c.symbol,
                        isSelected: c.name == _selectedName,
                        onTap: () => _onSelect(c.name),
                        animationDelay: (index * 50).ms,
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSize.h16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: AppButton(
                    text: 'Done',
                    buttonColor: context.themeColors.buttonColor,
                    shadowColor: context.themeColors.buttonBorderColor,
                    foregroundColor: context.themeColors.whiteColor,
                    trailingIcon: Icon(
                      Icons.arrow_forward_rounded,
                      color: context.themeColors.whiteColor,
                      size: 20,
                    ),
                    borderRadius: AppSize.r29,
                    onPressed: _onConfirm,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 200.ms,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                ),
                SizedBox(height: AppSize.h16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
