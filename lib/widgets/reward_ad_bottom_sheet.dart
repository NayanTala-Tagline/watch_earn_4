import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../extension/ext_context.dart';
import '../gen/assets.gen.dart';
import '../utils/app_size.dart';
import 'app_button.dart';

class RewardAdBottomSheet extends StatefulWidget {
  final VoidCallback onSupportUs;
  final VoidCallback onCancel;
  final int timerSeconds;

  const RewardAdBottomSheet({
    super.key,
    required this.onSupportUs,
    required this.onCancel,
    this.timerSeconds = 3,
  });

  @override
  State<RewardAdBottomSheet> createState() => _RewardAdBottomSheetState();
}

class _RewardAdBottomSheetState extends State<RewardAdBottomSheet> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timerSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        Navigator.of(context).pop();
        widget.onSupportUs();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.r28)),
        border: Border(top: BorderSide(color: colors.borderColor2, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h12,
        AppSize.w24,
        AppSize.h24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: AppSize.w40,
            height: AppSize.h4,
            decoration: BoxDecoration(
              color: colors.dragHandleColor,
              borderRadius: BorderRadius.circular(AppSize.r2),
            ),
          ),
          SizedBox(height: AppSize.h24),

          // Coin icon with glow ring
          _CoinBadge(colors: colors)
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          SizedBox(height: AppSize.h20),

          // Title
          Text(
            'Earn a Reward',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: textColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h8),

          // Description
          Text(
            'Watch a short ad to claim your reward.\nYour support keeps the app free!',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: AppSize.sp14,
              height: 1.5,
              color: textColors.bodyTextColor,
            ),
          ),
          SizedBox(height: AppSize.h20),

          // Auto-start countdown pill
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _remainingSeconds > 0
                ? Container(
                    key: ValueKey(_remainingSeconds),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize.w16,
                      vertical: AppSize.h8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.coinSurfaceColor,
                      borderRadius: BorderRadius.circular(AppSize.r20),
                      border: Border.all(
                        color: colors.coinGoldColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: AppSize.sp15,
                          color: colors.coinAmberColor,
                        ),
                        SizedBox(width: AppSize.w6),
                        Text(
                          'Auto-starting in $_remainingSeconds s',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppSize.sp13,
                            fontWeight: FontWeight.w600,
                            color: colors.coinAmberColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: AppSize.h36),
          ),
          SizedBox(height: AppSize.h24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  buttonColor: context.themeColors.whiteColor,
                  shadowColor: context.themeColors.borderColor,
                  foregroundColor: context.themeTextColors.textColor,
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                ),
              ),
              SizedBox(width: AppSize.w12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Get Reward',
                  buttonColor: context.themeColors.buttonColor,
                  shadowColor: context.themeColors.buttonBorderColor,
                  foregroundColor: context.themeColors.whiteColor,
                  wallOffset: 4,
                  borderRadius: AppSize.r28,
                  icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: AppSize.sp20,
                      ),
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pop();
                    widget.onSupportUs();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Coin badge icon ───────────────────────────────────────────────────────────

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.colors});

  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    final c = context.themeColors;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: AppSize.w90,
          height: AppSize.w90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                c.primary.withValues(alpha: 0.18),
                c.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Inner circle
        Container(
          width: AppSize.w72,
          height: AppSize.w72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.primary, c.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppSize.w18),
          child: Assets.icons.icCoin.svg(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

// ── Cancel button ─────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.r14),
      child: Container(
        height: AppSize.h52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.fieldBgColor,
          borderRadius: BorderRadius.circular(AppSize.r14),
          border: Border.all(color: colors.borderColor, width: 1.2),
        ),
        child: Text(
          'Cancel',
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: AppSize.sp15,
            fontWeight: FontWeight.w600,
            color: context.themeTextColors.bodyTextColor,
          ),
        ),
      ),
    );
  }
}

/// Shows the reward ad bottom sheet.
Future<void> showRewardAdBottomSheet({
  required BuildContext context,
  required VoidCallback onSupportUs,
  required VoidCallback onCancel,
  int timerSeconds = 3,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => RewardAdBottomSheet(
      onSupportUs: onSupportUs,
      onCancel: onCancel,
      timerSeconds: timerSeconds,
    ),
  );
}
