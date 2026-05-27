import 'dart:async';

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
  const GameSelectScreen({super.key, this.preloadedNative});

  /// Native ad pre-loaded by the country screen.
  final InlineAdManager? preloadedNative;

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends State<GameSelectScreen> {
  final Set<String> _selected = {};

  /// Next native ad pre-loaded for the currency screen.
  InlineAdManager? _nextNativeAd;
  bool _nextNativeAdTransferred = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'game_select',
      screenClass: 'GameSelectScreen',
    );
    _nextNativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.currencyNative,
    );
    unawaited(_nextNativeAd!.load());
  }

  @override
  void dispose() {
    widget.preloadedNative?.dispose();
    if (!_nextNativeAdTransferred) _nextNativeAd?.dispose();
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

  void _onConfirm() async {
    if (_selected.isEmpty) {
      context.l10n.pleaseSelectGame.showInfoAlert();
      return;
    }

    // Wait for currency native if it's still loading (button shows loader).
    if (_nextNativeAd != null && _nextNativeAd!.isLoading) {
      setState(() => _isButtonLoading = true);
      await _nextNativeAd!.future();
      if (!mounted) return;
      setState(() => _isButtonLoading = false);
    }

    if (!mounted) return;
    _nextNativeAdTransferred = true;
    context.goNamed(AppRoutes.currency, extra: _nextNativeAd);
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
        bottomNavigationBar: AdSlot(ad: widget.preloadedNative),
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
                        context.l10n.whichGame,
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
                        context.l10n.selectFavGames,
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
                      context.l10n.availableGames,
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
                AppButton(
                  text: context.l10n.done,
                  isLoading: _isButtonLoading,
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
                SizedBox(height: AppSize.h16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameChip extends StatefulWidget {
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
  State<_GameChip> createState() => _GameChipState();
}

class _GameChipState extends State<_GameChip>
    with SingleTickerProviderStateMixin {
  static const _wallH = 4.0;

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    final surfaceColor = isSelected
        ? context.themeColors.buttonColor
        : context.themeColors.whiteColor;
    final wallColor = isSelected
        ? context.themeColors.buttonBorderColor
        : context.themeColors.borderColor;
    final borderColor = isSelected
        ? context.themeColors.buttonColor
        : context.themeColors.dragHandleColor;
    final textColor = isSelected
        ? context.themeColors.whiteColor
        : context.themeColors.navyColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) {
          final p = _anim.value;
          final currentWall = (1 - p) * _wallH;
          final shiftY = p * _wallH;

          return Transform.translate(
            offset: Offset(0, shiftY),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.w12,
                vertical: AppSize.h8,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSize.r24),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: wallColor,
                    blurRadius: 0,
                    offset: Offset(0, currentWall),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isSelected) ...[
              Icon(
                Icons.check_rounded,
                size: AppSize.r14,
                color: context.themeColors.whiteColor,
              ),
              SizedBox(width: AppSize.w4),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: (context.textTheme.titleSmall ?? const TextStyle())
                  .copyWith(fontSize: AppSize.sp13, color: textColor),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.animationDelay, duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: widget.animationDelay,
          duration: 300.ms,
        );
  }
}
