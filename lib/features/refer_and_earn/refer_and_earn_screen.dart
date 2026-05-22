import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/common_header.dart';

List<BoxShadow> _kCardShadow(BuildContext context) => [
  BoxShadow(
    color: context.themeColors.cardShadowColor,
    offset: const Offset(0, 6),
    blurRadius: 16,
  ),
];

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  static const _referralCode = '83URK8';

  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _promoController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        children: [
          const CommonHeader(title: 'Refer & Earn'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSize.w16,
                AppSize.h8,
                AppSize.w16,
                AppSize.h24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildIntro(context),
                  SizedBox(height: AppSize.h20),
                  _buildReferralCard(context),
                  SizedBox(height: AppSize.h14),
                  _buildPromoCard(context),
                  SizedBox(height: AppSize.h14),
                  _buildHowItWorksCard(context),
                  SizedBox(height: AppSize.h14),
                  _buildStatsRow(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Assets.images.gifts.image(
              width: AppSize.w105,
              height: AppSize.w105,
              fit: BoxFit.contain,
            ),
            SizedBox(width: AppSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppSize.w170,
                    child: Text(
                      'Invite Friends,\nGet 1000 Coins!',
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp24,
                        fontWeight: FontWeight.w900,
                        color: context.themeTextColors.darkTitleColor,
                        letterSpacing: 0,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h8),
        Text(
          'Share your code. When they sign up or enter '
              'it, you both get 1000 coins!',
          style: TextStyle(
            fontFamily: FontFamily.kommonGrotesk,
            fontSize: AppSize.sp14,
            fontWeight: FontWeight.w200,
            color: context.themeColors.navyColor,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Code',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w700,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          AppButton(
            text: _referralCode,
            buttonColor: context.themeColors.fieldBgColor,
            shadowColor: context.themeColors.codePillShadowColor,
            slideShadowColor: context.themeColors.buttonColor.withValues(alpha: 0.31),
            slideShadowOffset: const Offset(0, 10),
            slideShadowBlur: 16,
            foregroundColor: context.themeColors.whiteColor,
            wallOffset: 4,
            borderRadius: AppSize.r28,
            trailingIcon: Icon(
              Icons.copy_rounded,
              size: AppSize.sp30,
              color: context.themeColors.buttonColor,
            ),
            textStyle: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w900,
              color: context.themeColors.buttonColor,
              letterSpacing: 1,
            ),
            onPressed: _shareLink,
          ),
          SizedBox(height: AppSize.h12),
          SizedBox(
            height: AppSize.h56,
            child: AppButton(
              text: 'Share Link',
              buttonColor: context.themeColors.buttonColor,
              shadowColor: context.themeColors.buttonBorderColor,
              foregroundColor: context.themeColors.whiteColor,
              wallOffset: 4,
              borderRadius: AppSize.r28,
              trailingIcon: Assets.icons.icShareLink.svg(
                width: 18.w,
                height: 18.w,
                colorFilter: ColorFilter.mode(
                  context.themeColors.whiteColor,
                  BlendMode.srcIn,
                ),
              ),
              textStyle: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp15,
                fontWeight: FontWeight.w800,
                color: context.themeColors.whiteColor,
              ),
              onPressed: _shareLink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a Promo Code?',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w700,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: AppSize.h50,
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
                  decoration: BoxDecoration(
                    color: context.themeColors.fieldBgColor,
                    borderRadius: BorderRadius.circular(AppSize.r28),
                    border: Border.all(
                      color: context.themeColors.borderColor2,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _promoController,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: context.themeColors.buttonBorderColor,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w10),
              AppButton(
                text: 'Apply',
                isAdjust: true,
                buttonColor: context.themeColors.buttonColor2,
                shadowColor: context.themeColors.buttonBorderColor2,
                slideShadowColor: context.themeColors.buttonColor2.withValues(alpha: 0.31),
                slideShadowOffset: const Offset(0, 10),
                slideShadowBlur: 16,
                foregroundColor: context.themeColors.whiteColor,
                isDisabled: _promoController.text.trim().isEmpty,
                horizontalPad: AppSize.w22,
                verticalPad: AppSize.h14,
                borderRadius: AppSize.r28,
                wallOffset: 4,
                textStyle: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w900,
                  color: context.themeColors.whiteColor,
                ),
                onPressed: _applyPromo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            context.themeColors.howCardBgEnd,
            context.themeColors.howCardBgStart,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSize.r18),
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.w42,
            height: AppSize.w42,
            decoration: BoxDecoration(
              color: context.themeColors.howCardIconBg,
              borderRadius: BorderRadius.circular(AppSize.r12),
            ),
            child: Center(
              child: Assets.icons.icInfo.svg(
                width: AppSize.w22,
                height: AppSize.w22,
                colorFilter: ColorFilter.mode(
                  context.themeColors.whiteColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How Referrals Work',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w900,
                    color: context.themeColors.buttonBorderColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  'Share code, earn together when they join',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w600,
                    color: context.themeTextColors.bodyTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icon(
              Icons.person_outline_rounded,
              size: AppSize.sp20,
              color: context.themeColors.buttonColor,
            ),
            label: 'Friends Invited',
            value: '0',
          ),
        ),
        SizedBox(width: AppSize.w12),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icCoin.svg(width: 20.w, height: 20.w),
            label: 'Coins Earned',
            value: '0',
          ),
        ),
      ],
    );
  }

  void _copyCode() {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareLink() {}

  void _applyPromo() {}
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w14,
        vertical: AppSize.h14,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r18),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp12,
              fontWeight: FontWeight.w600,
              color: context.themeTextColors.bodyTextColor,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Row(
            children: [
              icon,
              SizedBox(width: AppSize.w8),
              Text(
                value,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp18,
                  fontWeight: FontWeight.w900,
                  color: context.themeColors.buttonBorderColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
