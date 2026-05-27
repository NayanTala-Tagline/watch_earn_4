import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_earn_4/db/app_db.dart';
import 'package:watch_earn_4/di/injector.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/extension/ext_string_alert.dart';
import 'package:watch_earn_4/features/bottom_nav/bottom_nav_page.dart';
import 'package:watch_earn_4/features/rewards/provider/rewards_provider.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/anaytics_manager.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/navigation_helper.dart';
import 'package:watch_earn_4/utils/remote_config.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/common_header.dart';

List<BoxShadow> _kCardShadow(BuildContext context) => [
  BoxShadow(
    color: context.themeColors.cardShadowColor,
    offset: const Offset(0, 6),
    blurRadius: 16,
  ),
];

Future<String> _getPlayStoreUrl() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return 'https://play.google.com/store/apps/details?id=${info.packageName}';
  } catch (_) {
    return 'https://play.google.com/store/apps';
  }
}

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RewardsProvider(),
      child: const _ReferAndEarnBody(),
    );
  }
}

class _ReferAndEarnBody extends StatefulWidget {
  const _ReferAndEarnBody();

  @override
  State<_ReferAndEarnBody> createState() => _ReferAndEarnBodyState();
}

class _ReferAndEarnBodyState extends State<_ReferAndEarnBody> {
  final _db = Injector.instance<AppDB>();

  String get _referralCode => _db.userModel?.userId ?? '';
  bool get _isGuest => _db.userModel?.isGuest ?? true;
  bool get _alreadyReferred => (_db.userModel?.referredBy ?? '').isNotEmpty;
  int get _rewardAmount => RemoteConfigService.instance.referralRewardAmount;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'refer_and_earn',
      screenClass: 'ReferAndEarnScreen',
    );
  }

  Future<void> _copyCode() async {
    if (_referralCode.isEmpty) return;
    final msg = context.l10n.referralCodeCopied;
    await Clipboard.setData(ClipboardData(text: _referralCode));
    msg.showSuccessAlert();
  }

  Future<void> _shareLink() async {
    if (_referralCode.isEmpty) return;
    try {
      final storeUrl = await _getPlayStoreUrl();
      await SharePlus.instance.share(
        ShareParams(
          text: 'Join me on Rewardo : Daily Rewards and earn coins! '
              'Use my referral code: $_referralCode\n\n'
              'Download the app: $storeUrl',
        ),
      );
    } catch (_) {
      await SharePlus.instance.share(
        ShareParams(text: 'Use my referral code: $_referralCode'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RewardsProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      body: Column(
        children: [
          CommonHeader(title: context.l10n.referAndEarn),
          Expanded(
            child: StreamBuilder(
              stream: _db.userListenable(),
              builder: (context, _) {
                return SingleChildScrollView(
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
                      _buildPromoCard(context, provider),
                      SizedBox(height: AppSize.h14),
                      _buildHowItWorksCard(context),
                      SizedBox(height: AppSize.h14),
                      _buildStatsRow(context, provider),
                      if (_isGuest) ...[
                        SizedBox(height: AppSize.h12),
                        _LinkAccountCard(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ── Intro header ────────────────────────────────────────────────────────
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
              child: Text(
                context.l10n.inviteFriendsTitle(_rewardAmount),
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
        SizedBox(height: AppSize.h8),
        Text(
          context.l10n.referralShareDesc(_rewardAmount),
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

  // ── Your Referral Code card ─────────────────────────────────────────────
  Widget _buildReferralCard(BuildContext context) {
    final canShare = !_isGuest && _referralCode.isNotEmpty;

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
            context.l10n.yourReferralCode,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w700,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          if (!canShare)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.w16,
                vertical: AppSize.h14,
              ),
              decoration: BoxDecoration(
                color: context.themeColors.fieldBgColor,
                borderRadius: BorderRadius.circular(AppSize.r14),
                border: Border.all(color: context.themeColors.borderColor2),
              ),
              child: Text(
                context.l10n.signInForReferralCode,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColors.bodyTextColor,
                ),
              ),
            )
          else ...[
            _CodePill(code: _referralCode, onTap: _copyCode),
            SizedBox(height: AppSize.h12),
            SizedBox(
              height: AppSize.h56,
              child: AppButton(
                text: context.l10n.shareLink,
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
        ],
      ),
    );
  }

  // ── Have a Promo Code? card ─────────────────────────────────────────────
  Widget _buildPromoCard(BuildContext context, RewardsProvider provider) {
    if (_alreadyReferred) {
      return Container(
        padding: EdgeInsets.all(AppSize.w16),
        decoration: BoxDecoration(
          color: context.themeColors.successColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSize.r20),
          border: Border.all(
            color: context.themeColors.successColor.withValues(alpha: 0.4),
          ),
          boxShadow: _kCardShadow(context),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: context.themeColors.successColor,
              size: AppSize.sp22,
            ),
            SizedBox(width: AppSize.w10),
            Text(
              context.l10n.referralCodeAlreadyApplied,
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp14,
                fontWeight: FontWeight.w700,
                color: context.themeColors.successColor,
              ),
            ),
          ],
        ),
      );
    }

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
            context.l10n.haveAPromoCode,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w700,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                          controller: provider.referralController,
                          enabled: !_isGuest && !provider.isApplyingReferral,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp14,
                            fontWeight: FontWeight.w700,
                            color: context.themeColors.buttonBorderColor,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: context.l10n.enterReferralCode,
                            hintStyle: TextStyle(
                              fontFamily: FontFamily.kommonGrotesk,
                              fontSize: AppSize.sp14,
                              fontWeight: FontWeight.w400,
                              color: context.themeTextColors.bodyTextColor,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSize.w10),
              AppButton(
                text: provider.isApplyingReferral ? '...' : context.l10n.apply,
                isAdjust: true,
                buttonColor: context.themeColors.buttonColor2,
                shadowColor: context.themeColors.buttonBorderColor2,
                slideShadowColor:
                    context.themeColors.buttonColor2.withValues(alpha: 0.31),
                slideShadowOffset: const Offset(0, 10),
                slideShadowBlur: 16,
                foregroundColor: context.themeColors.whiteColor,
                isDisabled: provider.isApplyingReferral,
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
                onPressed: () {
                  if (_isGuest) {
                    context.l10n.pleaseSignInForReferral.showInfoAlert();
                    return;
                  }
                  if (provider.isApplyingReferral) return;
                  provider.validateReferralCode(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── How Referrals Work card ─────────────────────────────────────────────
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
                  context.l10n.howReferralsWork,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w900,
                    color: context.themeColors.buttonBorderColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  context.l10n.howReferralsWorkDesc(_rewardAmount),
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

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context, RewardsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icon(
              Icons.person_outline_rounded,
              size: AppSize.sp20,
              color: context.themeColors.buttonColor,
            ),
            label: context.l10n.friendsInvited,
            value: '${provider.friendsInvited}',
          ),
        ),
        SizedBox(width: AppSize.w12),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icCoin.svg(width: 20.w, height: 20.w),
            label: context.l10n.coinsEarned,
            value: '${provider.coinsEarned}',
          ),
        ),
      ],
    );
  }
}

// ── 3-D code pill ─────────────────────────────────────────────────────────────
class _CodePill extends StatelessWidget {
  const _CodePill({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSize.h4),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w20,
          vertical: AppSize.h10,
        ),
        decoration: BoxDecoration(
          color: colors.fieldBgColor,
          borderRadius: BorderRadius.circular(AppSize.r28),
          boxShadow: [
            BoxShadow(
              color: colors.codePillShadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: colors.borderColor,
              offset: const Offset(0, 10),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp20,
                  fontWeight: FontWeight.w900,
                  color: colors.buttonColor,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(width: AppSize.w12),
            Icon(
              Icons.copy_rounded,
              size: AppSize.sp28,
              color: colors.buttonColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────
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

class _LinkAccountCard extends StatelessWidget {
  const _LinkAccountCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSize.r20),
      onTap: () {
        // AnalyticsManager.instance.logEvent(name: 'rewards_link_account_tap');
        // context.read<BottomNavController>().setIndex(3);
        // Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w20,
          vertical: AppSize.h24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSize.r20),
          border: Border.all(color: context.themeColors.borderColor),
          boxShadow: [
            BoxShadow(
                color: context.themeColors.borderColor,
                offset: const Offset(0, 4)
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.link_rounded,
              color: context.themeColors.primary,
              size: AppSize.sp40,
            ),
            SizedBox(height: AppSize.h8),
            Text(
              'Link Your Account',
              style: context.textTheme.titleSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSize.h6),
            Text(
              'Sign in with Google to get your referral code and invite friends, Go to Profile and link your account.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.themeTextColors.descriptionColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}