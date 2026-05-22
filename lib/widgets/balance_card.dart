import 'package:flutter/material.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/widgets/app_button.dart';

List<BoxShadow> _kCardShadow(BuildContext context) => [
  BoxShadow(
    color: context.themeColors.cardShadowColor,
    offset: const Offset(0, 6),
    blurRadius: 16,
  ),
];

/// Reusable balance card.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    this.title = 'Total Balance',
    required this.amountWhole,
    this.amountFraction,
    this.body,
    this.onWithdraw,
    this.onRewards,
    this.withdrawLabel = 'Withdraw',
    this.rewardsLabel = 'Rewards',
  });

  final String title;
  final String amountWhole;
  final String? amountFraction;
  final Widget? body;
  final VoidCallback? onWithdraw;
  final VoidCallback? onRewards;
  final String withdrawLabel;
  final String rewardsLabel;

  bool get _showActions => onWithdraw != null || onRewards != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r25),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w500,
              color: context.themeTextColors.bodyTextColor,
            ),
          ),
          SizedBox(height: AppSize.h15),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp40,
                fontWeight: FontWeight.w900,
                color: context.themeTextColors.textColor,
                letterSpacing: -1,
                height: 1.05,
              ),
              children: [
                TextSpan(text: amountWhole),
                if (amountFraction != null)
                  TextSpan(
                    text: amountFraction,
                    style: TextStyle(
                      color: context.themeTextColors.mutedTextColor,
                    ),
                  ),
              ],
            ),
          ),
          if (body != null) ...[
            SizedBox(height: AppSize.h12),
            body!,
          ],
          if (_showActions) ...[
            SizedBox(height: AppSize.h12),
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        if (onWithdraw != null)
          Expanded(
            child: SizedBox(
              height: 55,
              child: AppButton(
                text: withdrawLabel,
                buttonColor: context.themeColors.buttonColor,
                shadowColor: context.themeColors.buttonBorderColor,
                foregroundColor: context.themeColors.whiteColor,
                wallOffset: 4,
                borderRadius: AppSize.r28,
                textStyle: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w700,
                  color: context.themeColors.whiteColor,
                ),
                onPressed: onWithdraw,
              ),
            ),
          ),
        if (onWithdraw != null && onRewards != null) SizedBox(width: AppSize.w5),
        if (onRewards != null)
          Expanded(
            child: SizedBox(
              height: 56,
              child: AppButton(
                text: rewardsLabel,
                isFillButton: false,
                borderRadius: AppSize.r28,
                borderColor: context.themeColors.borderColor2,
                borderWidth: 1.4,
                textStyle: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w700,
                  color: context.themeColors.buttonBorderColor,
                ),
                onPressed: onRewards,
              ),
            ),
          ),
      ],
    );
  }
}
