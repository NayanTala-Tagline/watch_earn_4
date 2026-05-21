import 'package:flutter/material.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/widgets/app_button.dart';

/// Reusable balance card.
///
/// Displays a title, a two-tone money amount (whole + fractional), an
/// optional [body] for chip rows, and an optional action row with
/// Withdraw and/or Rewards buttons. Each action button is shown only
/// when its callback is provided.
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

  /// Whole part of the amount, rendered in solid black (e.g. "\$24").
  final String amountWhole;

  /// Fractional part rendered in a muted grey (e.g. ".86"). Optional.
  final String? amountFraction;

  /// Optional content rendered between the amount and the action buttons.
  /// Typically a row of chips/pills specific to the host screen.
  final Widget? body;

  /// When provided, shows the primary Withdraw button.
  final VoidCallback? onWithdraw;

  /// When provided, shows the secondary Rewards button.
  final VoidCallback? onRewards;

  final String withdrawLabel;
  final String rewardsLabel;

  static const _titleColor = Color(0xFF6B7393);
  static const _cardBorder = Color(0xFFEDEFF5);
  static const _fractionColor = Color(0xFF9AA0B5);
  static const _primaryBlue = Color(0xFF1A1AE8);
  static const _primaryBlueShadow = Color(0xFF0E0F66);
  static const _rewardsTextColor = Color(0xFF0E0F66);
  static const _cardShadow = [
    BoxShadow(
      color: Color(0x140E0F66),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  bool get _showActions => onWithdraw != null || onRewards != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r25),
        border: Border.all(color: _cardBorder),
        boxShadow: _cardShadow,
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
              color: _titleColor,
            ),
          ),
          SizedBox(height: AppSize.h15),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp40,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -1,
                height: 1.05,
              ),
              children: [
                TextSpan(text: amountWhole),
                if (amountFraction != null)
                  TextSpan(
                    text: amountFraction,
                    style: const TextStyle(color: _fractionColor),
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
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    final buttons = <Widget>[
      if (onWithdraw != null)
        Expanded(
          child: SizedBox(
            height: 55,
            child: AppButton(
              text: withdrawLabel,
              buttonColor: _primaryBlue,
              shadowColor: _primaryBlueShadow,
              foregroundColor: Colors.white,
              wallOffset: 4,
              borderRadius: AppSize.r28,
              textStyle: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
              borderColor: _cardBorder,
              borderWidth: 1.4,
              textStyle: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp15,
                fontWeight: FontWeight.w700,
                color: _rewardsTextColor,
              ),
              onPressed: onRewards,
            ),
          ),
        ),
    ];

    return Row(children: buttons);
  }
}
