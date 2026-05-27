import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';

class _Game {
  const _Game(this.name, this.emoji);
  final String name;
  final String emoji;
}

const _games = <_Game>[
  _Game('Spin Wheel', '🎡'),
  _Game('Treasure Hunt', '🗺️'),
  _Game('Quiz Challenges', '❓'),
  _Game('Puzzle Game', '🧩'),
  _Game('Block Game', '🧱'),
  _Game('Stack Tower', '🏗️'),
  _Game('Bubble Shooter', '🫧'),
  _Game('Word Search', '🔤'),
  _Game('Memory Match', '🧠'),
  _Game('Card Flip', '🃏'),
  _Game('Sudoku', '🔢'),
  _Game('Tic Tac Toe', '⭕'),
];

class GameSelectScreen extends StatefulWidget {
  const GameSelectScreen({super.key});

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends State<GameSelectScreen> {
  final Set<String> _selected = {};
  InlineAdManager? _nativeAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'game_select',
      screenClass: 'GameSelectScreen',
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    _nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.gameSelectNative,
    );
    await _nativeAd!.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  void _onConfirm() {
    if (_selected.isEmpty) {
      'Please select at least one game'.showInfoAlert();
      return;
    }
    context.goNamed(AppRoutes.currency);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSize.h24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Which Game do you like?',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: AppSize.sp24,
                          color: context.themeColors.navyColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Select your fav Games which are you want to play',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.themeTextColors.subtitleColor,
                          height: 1.4,
                        ),
                      ),
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
                      'Available Games',
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
                SizedBox(height: AppSize.h16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: AppSize.h8),
                    child: Wrap(
                      spacing: AppSize.w10,
                      runSpacing: AppSize.h10,
                      children: [
                        for (var i = 0; i < _games.length; i++)
                          _GameChip(
                            label: '${_games[i].emoji}  ${_games[i].name}',
                            isSelected: _selected.contains(_games[i].name),
                            onTap: () => _toggle(_games[i].name),
                            animationDelay: (i * 40).ms,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSize.h8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: AppButton(
                    text: 'Done',
                    buttonColor: context.themeColors.buttonColor,
                    shadowColor: context.themeColors.buttonBorderColor,
                    trailingIcon: Icon(
                      Icons.arrow_forward_rounded,
                      color: context.themeColors.whiteColor,
                      size: 20,
                    ),
                    foregroundColor: context.themeColors.whiteColor,
                    borderRadius: AppSize.r29,
                    onPressed: _onConfirm,
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

class _GameChip extends StatelessWidget {
  const _GameChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: context.textTheme.titleSmall?.copyWith(
        fontSize: AppSize.sp13,
        color: isSelected
            ? context.themeColors.whiteColor
            : context.themeColors.navyColor,
      ),
      backgroundColor: context.themeColors.whiteColor,
      selectedColor: context.themeColors.buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.r24),
        side: BorderSide(
          color: isSelected
              ? context.themeColors.buttonColor
              : context.themeColors.borderColor2,
        ),
      ),
      showCheckmark: false,
      avatar: isSelected
          ? Icon(
              Icons.check_rounded,
              size: AppSize.r16,
              color: context.themeColors.whiteColor,
            )
          : null,
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w8,
        vertical: AppSize.h6,
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay, duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: animationDelay,
          duration: 300.ms,
        );
  }
}
