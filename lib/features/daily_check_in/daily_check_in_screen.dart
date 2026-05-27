import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/db/app_db.dart';
import 'package:watch_earn_4/di/injector.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/features/home/provider/home_provider.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/utils/anaytics_manager.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/remote_config.dart';
import 'package:watch_earn_4/widgets/ad_slot.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:watch_earn_4/widgets/common_appbar.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _db = Injector.instance<AppDB>();
  InlineAdManager? _nativeAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'daily_check_in',
      screenClass: 'DailyCheckInScreen',
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    _nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.dailyCheckInNative,
    );
    await _nativeAd!.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: context.themeColors.backgroundColor,
      appBar: CommonAppBar(titleText: context.l10n.dailyCheckIn),
      bottomNavigationBar: AdSlot(ad: _nativeAd),
      body: StreamBuilder(
        stream: _db.userListenable(),
        builder: (context, _) {
          final user = _db.userModel;
          final totalDays = user?.totalClaimDays ?? 0;
          final checkInStreak = user?.checkInStreak ?? 0;
          final currentDay = provider.currentCheckInDay;
          final isClaimed = provider.isRewardClaimed;
          final rewardCoins = provider.dailyRewardCoins;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSize.w16,
              AppSize.h16,
              AppSize.w16,
              AppSize.h30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TotalDaysCard(totalDays: totalDays),
                SizedBox(height: AppSize.h16),
                _RewardCard(
                  checkInStreak: checkInStreak,
                  currentDay: currentDay,
                  isClaimed: isClaimed,
                  rewardCoins: rewardCoins,
                  onClaim: () => provider.claimDailyReward(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Total Days Claimed card ───────────────────────────────────────────────────

class _TotalDaysCard extends StatelessWidget {
  const _TotalDaysCard({required this.totalDays});
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w16,
        vertical: AppSize.h20,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: context.themeColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.borderColor,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.w52,
            height: AppSize.w52,
            decoration: BoxDecoration(
              color: context.themeColors.daysPillSurfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.themeColors.buttonColor2.withValues(alpha: 0.30),
                  blurRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Assets.icons.icFire.svg(
                width: AppSize.w28,
                height: AppSize.w28,
                colorFilter: ColorFilter.mode(
                  context.themeColors.buttonColor2,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSize.w14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.totalDaysClaimed,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp13,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColors.bodyTextColor,
                ),
              ),
              SizedBox(height: AppSize.h4),
              Text(
                context.l10n.totalDaysValue(totalDays),
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp24,
                  fontWeight: FontWeight.w900,
                  color: context.themeTextColors.darkTitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Main reward card ─────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.checkInStreak,
    required this.currentDay,
    required this.isClaimed,
    required this.rewardCoins,
    required this.onClaim,
  });

  final int checkInStreak;
  final int currentDay;
  final bool isClaimed;
  final int rewardCoins;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w20),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
        border: Border.all(color: context.themeColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.borderColor,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: '',
                isAdjust: true,
                showIconOnly: true,
                buttonColor: context.themeColors.coinGoldColor,
                shadowColor: context.themeColors.coinAmberColor,
                foregroundColor: context.themeColors.buttonColor2,
                horizontalPad: AppSize.w10,
                verticalPad: AppSize.h8,
                borderRadius: AppSize.r14,
                wallOffset: 4,
                icon: Assets.icons.icGift.svg(
                  width: AppSize.w40,
                  height: AppSize.w40,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: AppSize.h20),
          Text(
            context.l10n.dailyCheckInReward,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp18,
              fontWeight: FontWeight.w900,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
          SizedBox(height: AppSize.h6),
          Text(
            context.l10n.dayValue(currentDay),
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w900,
              color: context.themeColors.buttonColor2,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            isClaimed
                ? context.l10n.alreadyClaimedToday
                : context.l10n.claimCoinsToday(rewardCoins),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp13,
              color: context.themeTextColors.bodyTextColor,
            ),
          ),
          SizedBox(height: AppSize.h22),
          _ProgressBar(filledDays: checkInStreak, isClaimed: isClaimed),
          SizedBox(height: AppSize.h22),
          if (!isClaimed) ...[
            Text(
              context.l10n.sectionContainsAds,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.sp11,
                fontStyle: FontStyle.italic,
                color: context.themeTextColors.bodyTextColor.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(height: AppSize.h12),
          ],
          SizedBox(
            width: double.infinity,
            height: AppSize.h54,
            child: AppButton(
              text: isClaimed ? context.l10n.claimed : context.l10n.claim,
              buttonColor: context.themeColors.buttonColor2,
              shadowColor: context.themeColors.buttonBorderColor2,
              foregroundColor: context.themeColors.whiteColor,
              isDisabled: isClaimed,
              wallOffset: 4,
              borderRadius: AppSize.r28,
              trailingIcon: isClaimed
                  ? null
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: context.themeColors.whiteColor,
                      size: AppSize.sp22,
                    ),
              onPressed: isClaimed ? () {} : onClaim,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 7-segment progress bar ────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.filledDays, required this.isClaimed});

  final int filledDays;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final isFilled = index < filledDays;
        final isActive = !isClaimed && index == filledDays;

        final Color color;
        if (isFilled) {
          color = context.themeColors.buttonColor2;
        } else if (isActive) {
          color = context.themeColors.buttonColor2.withValues(alpha: 0.35);
        } else {
          color = context.themeColors.progressBgColor;
        }

        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: AppSize.w2),
            height: AppSize.h8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSize.r4),
            ),
          ),
        );
      }),
    );
  }
}
