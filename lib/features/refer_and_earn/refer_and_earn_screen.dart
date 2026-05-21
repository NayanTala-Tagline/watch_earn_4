import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/common_header.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  static const primaryTxtColor = Color(0xFF0B0E2C);
  static const secondaryTxtColor = Color(0xFF2B2F4A);
  static const _pageBg = Color(0xFFEAEFFC);
  static const _titleColor = Color(0xFF0E0F66);
  static const _bodyColor = Color(0xFF6B7393);
  static const _mutedTextColor = Color(0xFF8A8FA8);
  static const _cardBorder = Color(0xFFEDEFF5);
  static const _primaryBlue = Color(0xFF1A1AE8);
  static const _primaryBlueShadow = Color(0xFF0E0F66);
  static const _codePillBg = Color(0xFFF4F6FE);
  static const _codePillShadow = Color(0xFF6B7393);
  static const _pinkSurface = Color(0xFFFF1F7A);
  static const _pinkShadow = Color(0xFF880343);
  static const _howBgStart = Color(0xFFFFE5C8);
  static const _howBgEnd = Color(0xFFFFD8E2);
  static const _howIconBg = Color(0xFFFFC56C);
  static const _referralCode = '83URK8';

  static const _cardShadow = [
    BoxShadow(
      color: Color(0x140E0F66),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
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
                  _buildIntro(),
                  SizedBox(height: AppSize.h20),
                  _buildReferralCard(),
                  SizedBox(height: AppSize.h14),
                  _buildPromoCard(),
                  SizedBox(height: AppSize.h14),
                  _buildHowItWorksCard(),
                  SizedBox(height: AppSize.h14),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return
      Column(
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
                SizedBox(width: AppSize.w170,
                child:  Text(
                  'Invite Friends,\nGet 1000 Coins!',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp24,
                    fontWeight: FontWeight.w900,
                    color: primaryTxtColor,
                    letterSpacing: 0,
                    height: 1.15,
                  ),
                ),)
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
              color: secondaryTxtColor,
              height: 1.35,
            ),
          ),
        ],
      );

  }

  Widget _buildReferralCard() {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: _cardBorder),
        boxShadow: _cardShadow,
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
              color: primaryTxtColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          AppButton(
            text: _referralCode,
            buttonColor: _codePillBg,
            shadowColor: _codePillShadow,
            slideShadowColor: Color(0x501A1AE8),        // any color
            slideShadowOffset: const Offset(0, 10), // optional
            slideShadowBlur: 16,
            foregroundColor: Colors.white,
            wallOffset: 4,
            borderRadius: AppSize.r28,
            trailingIcon: Icon(
              Icons.copy_rounded,
              size: AppSize.sp30,
              color: _primaryBlue,
            ),
            textStyle: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w900,
              color: _primaryBlue,
              letterSpacing: 1,
            ),
            onPressed: _shareLink,
          ),
          SizedBox(height: AppSize.h12),
          SizedBox(
            height: AppSize.h56,
            child: AppButton(
              text: 'Share Link',
              buttonColor: _primaryBlue,
              shadowColor: _primaryBlueShadow,
              foregroundColor: Colors.white,
              wallOffset: 4,
              borderRadius: AppSize.r28,
              trailingIcon: Assets.icons.icShareLink.svg(
                width: 18.w,
                height: 18.w,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              textStyle: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              onPressed: _shareLink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: _cardBorder),
        boxShadow: _cardShadow,
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
              color: primaryTxtColor,
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
                    color: _codePillBg,
                    borderRadius: BorderRadius.circular(AppSize.r28),
                    border: Border.all(color: Color(0xFFECEEF6),width: 2)
                  ),
                  child: Center(
                    child: TextField(
                      controller: _promoController,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp14,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                      decoration: InputDecoration(
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
                buttonColor: _pinkSurface,
                shadowColor: _pinkShadow,
                slideShadowColor: Color(0x50FF1F7A),        // any color
                slideShadowOffset: const Offset(0, 10), // optional
                slideShadowBlur: 16,
                foregroundColor: Colors.white,
                horizontalPad: AppSize.w22,
                verticalPad: AppSize.h14,
                borderRadius: AppSize.r28,
                wallOffset: 4,
                textStyle: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                onPressed: _applyPromo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: EdgeInsets.all(AppSize.w14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_howBgStart, _howBgEnd],
        ),
        borderRadius: BorderRadius.circular(AppSize.r18),
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.w42,
            height: AppSize.w42,
            decoration: BoxDecoration(
              color: _howIconBg,
              borderRadius: BorderRadius.circular(AppSize.r12),
            ),
            child: Center(
              child: Assets.icons.icInfo.svg(
                width: AppSize.w22,
                height: AppSize.w22,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
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
                    color: _titleColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  'Share code, earn together when they join',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w600,
                    color: _mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icon(
              Icons.person_outline_rounded,
              size: AppSize.sp20,
              color: _primaryBlue,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r18),
        border: Border.all(color: _ReferAndEarnScreenState._cardBorder),
        boxShadow: _ReferAndEarnScreenState._cardShadow,
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
              color: _ReferAndEarnScreenState._mutedTextColor,
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
                  color: _ReferAndEarnScreenState._titleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
