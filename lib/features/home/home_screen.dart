import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/db/app_db.dart';
import 'package:watch_earn_4/di/injector.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/features/home/provider/home_provider.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/routes/app_router.dart';
import 'package:watch_earn_4/utils/anaytics_manager.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/remote_config.dart';
import 'package:watch_earn_4/widgets/ad_slot.dart';
import 'package:watch_earn_4/widgets/app_button.dart';

List<BoxShadow> _kCardShadow(BuildContext context) => [
  BoxShadow(
    color: context.themeColors.cardShadowColor,
    offset: const Offset(0, 6),
    blurRadius: 16,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = Injector.instance<AppDB>();

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'home',
      screenClass: 'HomeScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _db.userListenable(),
      builder: (context, _) {
        final user = _db.userModel;
        final coins = user?.coin.toInt() ?? 0;
        final xp = user?.xp.toInt() ?? 0;
        final level = user?.level.toInt() ?? 1;
        final totalClaimDays = user?.totalClaimDays ?? 0;

        return Scaffold(
          backgroundColor: context.themeColors.backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopRow(coins, totalClaimDays),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: AppSize.h8,
                      bottom: AppSize.h20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _hPad(_BalanceCard(coins: coins, xp: xp, level: level)),
                        SizedBox(height: AppSize.h14),
                        _hPad(_DailyRewardCard(coins: coins)),
                        SizedBox(height: AppSize.h12),
                        _hPad(_StatsRow(xp: xp, level: level)),
                        SizedBox(height: AppSize.h16),
                        if(context.watch<HomeProvider>().nativeAd1!.adData.enabled)...[
                          AdSlot(
                            ad: context.watch<HomeProvider>().nativeAd1,
                            safeAreaTop: false,
                            safeAreaBottom: false,
                          ),
                          SizedBox(height: AppSize.h5),
                       ],
                        _hPad(_sectionTitle(context, 'Earn Money')),
                        SizedBox(height: AppSize.h14),
                        _hPad(const _EarnGrid()),
                        SizedBox(height: AppSize.h16),
                        _hPad(const _HowItWorksCard()),
                        SizedBox(height: AppSize.h16),
                        if(context.watch<HomeProvider>().nativeAd2!.adData.enabled)...[
                          AdSlot(
                            ad: context.watch<HomeProvider>().nativeAd2,
                            safeAreaTop: false,
                            safeAreaBottom: false,
                          ),
                          SizedBox(height: AppSize.h5),
                        ],
                        _hPad(const _BottomShortcuts()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(int coins, int totalClaimDays) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h8,
        AppSize.w16,
        AppSize.h8,
      ),
      child: Row(
        children: [
          _CoinsPill(coins: coins),
          const Spacer(),
          Assets.images.splash.splashLogo.image(
            width: AppSize.w60,
            height: AppSize.w60,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _DaysPill(days: totalClaimDays),
        ],
      ),
    );
  }

  Widget _hPad(Widget child) => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
    child: child,
  );

  Widget _sectionTitle(BuildContext context, String text) => Text(
    text,
    style: context.textTheme.titleLarge?.copyWith(
      fontSize: AppSize.sp18,
      fontWeight: FontWeight.w900,
      color: context.themeTextColors.darkTitleColor,
    ),
  );
}

// ── Top pills ──────────────────────────────────────────────────────────────
class _CoinsPill extends StatelessWidget {
  const _CoinsPill({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '$coins',
      isAdjust: true,
      buttonColor: context.themeColors.coinSurfaceColor,
      shadowColor: context.themeColors.coinAmberColor,
      foregroundColor: context.themeColors.coinTextColor,
      horizontalPad: AppSize.w12,
      verticalPad: AppSize.w7,
      borderRadius: AppSize.r24,
      wallOffset: 4,
      textStyle: context.textTheme.titleLarge?.copyWith(
        fontSize: AppSize.sp13,
        fontWeight: FontWeight.w900,
        color: context.themeColors.coinAmberColor,
      ),
      icon: Assets.icons.icCoin.svg(width: AppSize.w19, height: AppSize.w19),
      onPressed: () {},
    );
  }
}

class _DaysPill extends StatelessWidget {
  const _DaysPill({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '$days Days',
      isAdjust: true,
      buttonColor: context.themeColors.daysPillSurfaceColor,
      shadowColor: context.themeColors.buttonColor2,
      foregroundColor: context.themeColors.buttonColor2,
      horizontalPad: AppSize.w12,
      verticalPad: AppSize.w7,
      wallOffset: 4,
      textStyle: context.textTheme.titleLarge?.copyWith(
        fontSize: AppSize.sp13,
        fontWeight: FontWeight.w900,
        color: context.themeColors.buttonColor2,
      ),
      trailingIcon: Assets.icons.icFire.svg(
        width: AppSize.w19,
        height: AppSize.w19,
      ),
      onPressed: () {},
    );
  }
}

// ── Total Balance card ─────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.coins,
    required this.xp,
    required this.level,
  });

  final int coins;
  final int xp;
  final int level;

  String get _dollarValue {
    final divider = RemoteConfigService.instance.coinToDollarDivider;
    final val = coins / divider;
    final intPart = val.floor();
    final decPart = ((val - intPart) * 100).round().toString().padLeft(2, '0');
    return '\$$intPart.$decPart';
  }

  @override
  Widget build(BuildContext context) {
    final dollarStr = _dollarValue;
    final dotIdx = dollarStr.indexOf('.');
    final intStr = dotIdx >= 0 ? dollarStr.substring(0, dotIdx) : dollarStr;
    final decStr = dotIdx >= 0 ? dollarStr.substring(dotIdx) : '';

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
            'Total Balance',
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp13,
              color: context.themeTextColors.bodyTextColor,
            ),
          ),
          SizedBox(height: AppSize.h15),
          RichText(
            text: TextSpan(
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp40,
                fontWeight: FontWeight.w900,
                color: context.themeTextColors.textColor,
                letterSpacing: -1,
                height: 1.05,
              ),
              children: [
                TextSpan(text: intStr),
                TextSpan(
                  text: decStr,
                  style: TextStyle(
                    color: context.themeTextColors.mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h12),
          Row(
            children: [
              _CoinPill(label: '$coins Coins'),
              SizedBox(width: AppSize.w10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w10,
                  vertical: AppSize.h6,
                ),
                decoration: BoxDecoration(
                  color: context.themeColors.xpBadgeColor,
                  borderRadius: BorderRadius.circular(AppSize.r16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: AppSize.sp16,
                      color: context.themeColors.buttonBorderColor,
                    ),
                    SizedBox(width: AppSize.w4),
                    Text(
                      'LV $level - $xp XP',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: AppSize.sp12,
                        fontWeight: FontWeight.w900,
                        color: context.themeColors.buttonBorderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: AppButton(
                    text: 'Withdraw',
                    buttonColor: context.themeColors.buttonColor,
                    shadowColor: context.themeColors.buttonBorderColor,
                    foregroundColor: context.themeColors.whiteColor,
                    wallOffset: 4,
                    borderRadius: AppSize.r28,
                    textStyle: context.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.sp15,
                      color: context.themeColors.whiteColor,
                    ),
                    onPressed: () => context.pushNamed(AppRoutes.withdraw),
                  ),
                ),
              ),
              SizedBox(width: AppSize.w5),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: AppButton(
                    text: 'Rewards',
                    isFillButton: false,
                    borderRadius: AppSize.r28,
                    borderColor: context.themeColors.borderColor2,
                    borderWidth: 1.4,
                    textStyle: context.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.sp15,
                      color: context.themeColors.buttonBorderColor,
                    ),
                    onPressed: () => context.pushNamed(AppRoutes.rewards),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSize.w4,
        AppSize.h6,
        AppSize.w10,
        AppSize.h6,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.coinSurfaceColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.icCoin.svg(width: AppSize.w19, height: AppSize.w19),
          SizedBox(width: AppSize.w6),
          Text(
            label,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp12,
              fontWeight: FontWeight.w900,
              color: context.themeColors.coinAmberColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Reward card ──────────────────────────────────────────────────────
class _DailyRewardCard extends StatelessWidget {
  const _DailyRewardCard({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final day = provider.currentCheckInDay;
    final rewardCoins = provider.dailyRewardCoins;
    final isClaimed = provider.isRewardClaimed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w12,
        vertical: AppSize.h22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            context.themeColors.dailyRewardGradientStart,
            context.themeColors.dailyRewardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: Row(
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
              width: AppSize.w30,
              height: AppSize.w30,
            ),
            onPressed: () {},
          ),
          SizedBox(width: AppSize.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Reward - Day $day',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.themeTextColors.darkTitleColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  isClaimed
                      ? 'Claimed today! Come back tomorrow'
                      : 'Collect +$rewardCoins coins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.bodyTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSize.w8),
          AppButton(
            text: isClaimed ? 'Claimed' : 'Claim',
            isAdjust: true,
            buttonColor: context.themeColors.buttonColor2,
            shadowColor: context.themeColors.buttonBorderColor2,
            foregroundColor: context.themeColors.whiteColor,
            isDisabled: isClaimed,
            horizontalPad: AppSize.w14,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r22,
            wallOffset: 4,
            textStyle: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w900,
              color: context.themeColors.whiteColor,
            ),
            onPressed: isClaimed ? () {} : () => provider.claimDailyReward(context),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.xp, required this.level});
  final int xp;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icCoin.svg(width: AppSize.w20, height: AppSize.w20),
            label: 'Level',
            value: 'LV $level',
          ),
        ),
        SizedBox(width: AppSize.w10),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icXp.svg(width: AppSize.w15, height: AppSize.w15),
            label: 'XP',
            value: '$xp',
          ),
        ),
        SizedBox(width: AppSize.w10),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icRank.svg(width: AppSize.w15, height: AppSize.w15),
            label: 'Rank',
            value: 'Top',
          ),
        ),
      ],
    );
  }
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
        horizontal: AppSize.w12,
        vertical: AppSize.h18,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: AppSize.w10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.bodyTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp18,
              fontWeight: FontWeight.w900,
              color: context.themeColors.buttonBorderColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Earn Money grid ────────────────────────────────────────────────────────
class _EarnGrid extends StatelessWidget {
  const _EarnGrid();

  @override
  Widget build(BuildContext context) {
    final rc = RemoteConfigService.instance;
    final items = [
      _EarnItem(
        title: 'Quiz Master',
        subtitle: 'Answer & Earn',
        reward: '+${rc.quizPerQuestionReward * 6}',
        illustration: _EarnIllustration.quiz,
        routeName: AppRoutes.quiz,
      ),
      _EarnItem(
        title: 'Spin Wheel',
        subtitle: 'Spin and Win',
        reward: '+${rc.spinBoardRewardValues.isNotEmpty ? rc.spinBoardRewardValues.reduce((a, b) => a > b ? a : b) : 30}',
        illustration: _EarnIllustration.spin,
        routeName: AppRoutes.spinWheel,
      ),
      _EarnItem(
        title: 'Scratch Card',
        subtitle: 'Scratch and Reveal',
        reward: '+${rc.scrachMaxReward}',
        illustration: _EarnIllustration.scratch,
        routeName: AppRoutes.scratchCard,
      ),
      _EarnItem(
        title: 'Web Visits',
        subtitle: 'Visit & Earn',
        reward: '+${rc.webVisitRewardCoins}',
        illustration: _EarnIllustration.web,
        routeName: AppRoutes.webVisits,
      ),
      _EarnItem(
        title: 'Game Zone',
        subtitle: 'Play Games',
        reward: '+${rc.gameVisitRewardCoins}',
        illustration: _EarnIllustration.game,
        routeName: AppRoutes.gameZone,
      ),
      _EarnItem(
        title: 'Refer & Earn',
        subtitle: 'Invite Friends',
        reward: '+${rc.referralRewardAmount}',
        illustration: _EarnIllustration.refer,
        routeName: AppRoutes.referAndEarn,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSize.w12,
        mainAxisSpacing: AppSize.h12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _EarnTile(item: items[i]),
    );
  }
}

enum _EarnIllustration { quiz, spin, scratch, web, game, refer }

class _EarnItem {
  const _EarnItem({
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.illustration,
    this.routeName,
  });

  final String title;
  final String subtitle;
  final String reward;
  final _EarnIllustration illustration;
  final String? routeName;
}

class _EarnTile extends StatelessWidget {
  const _EarnTile({required this.item});
  final _EarnItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.routeName != null
          ? () => context.pushNamed(item.routeName!)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSize.w12),
        decoration: BoxDecoration(
          color: context.themeColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r20),
          border: Border.all(color: context.themeColors.borderColor2),
          boxShadow: _kCardShadow(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w12,
            vertical: AppSize.w6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EarnArt(kind: item.illustration),
              SizedBox(height: AppSize.h8),
              Text(
                item.title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight(950),
                  color: context.themeColors.buttonBorderColor,
                ),
              ),
              SizedBox(height: AppSize.h2),
              Text(
                item.subtitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: AppSize.sp11,
                  color: context.themeTextColors.bodyTextColor,
                ),
              ),
              SizedBox(height: AppSize.h10),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSize.w6,
                      AppSize.h6,
                      AppSize.w10,
                      AppSize.h6,
                    ),
                    decoration: BoxDecoration(
                      color: context.themeColors.coinSurfaceColor,
                      borderRadius: BorderRadius.circular(AppSize.r14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.icCoin.svg(
                          width: AppSize.w20,
                          height: AppSize.w20,
                        ),
                        SizedBox(width: AppSize.w4),
                        Text(
                          item.reward,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontSize: AppSize.sp12,
                            fontWeight: FontWeight.w900,
                            color: context.themeColors.coinAmberColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.themeTextColors.bodyTextColor,
                    size: AppSize.sp22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarnArt extends StatelessWidget {
  const _EarnArt({required this.kind});
  final _EarnIllustration kind;

  @override
  Widget build(BuildContext context) {
    final asset = switch (kind) {
      _EarnIllustration.quiz    => Assets.images.quizMaster,
      _EarnIllustration.spin    => Assets.images.spinWheel,
      _EarnIllustration.scratch => Assets.images.scratchCard,
      _EarnIllustration.web     => Assets.images.webVisits2,
      _EarnIllustration.game    => Assets.images.gameZone2,
      _EarnIllustration.refer   => Assets.images.referAndEarn,
    };
    return asset.image(
      width: AppSize.w86,
      height: AppSize.w60,
      fit: BoxFit.contain,
    );
  }
}

// ── How It Works card ──────────────────────────────────────────────────────
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSize.w14,
        AppSize.h18,
        AppSize.w14,
        AppSize.h18,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: _kCardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppButton(
            text: '',
            isAdjust: true,
            showIconOnly: true,
            buttonColor: context.themeColors.buttonColor2,
            shadowColor: context.themeColors.buttonBorderColor2,
            foregroundColor: context.themeColors.buttonColor2,
            horizontalPad: AppSize.w10,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r16,
            wallOffset: 4,
            icon: Icon(Icons.question_mark, size: AppSize.h30),
            onPressed: () {},
          ),
          SizedBox(width: AppSize.w14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How It Works',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: AppSize.sp15,
                    fontWeight: FontWeight.w900,
                    color: context.themeColors.buttonBorderColor,
                  ),
                ),
                SizedBox(height: AppSize.h4),
                Text(
                  'Learn Step-by-Step how to\nearn money',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.bodyTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSize.w8),
          AppButton(
            text: 'Learn',
            isAdjust: true,
            buttonColor: context.themeColors.buttonColor,
            shadowColor: context.themeColors.buttonBorderColor,
            foregroundColor: context.themeColors.whiteColor,
            horizontalPad: AppSize.w18,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r22,
            wallOffset: 4,
            textStyle: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w800,
              color: context.themeColors.whiteColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Bottom shortcuts ───────────────────────────────────────────────────────
class _BottomShortcuts extends StatelessWidget {
  const _BottomShortcuts();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            topLabel: 'See top earner',
            title: 'Leader board',
            icon: Assets.icons.icLeaderboard.svg(),
            onTap: () => context.pushNamed(AppRoutes.rank),
          ),
        ),
        SizedBox(width: AppSize.w12),
        Expanded(
          child: _ShortcutCard(
            topLabel: 'XP',
            title: 'Achievements',
            icon: Assets.icons.icAchievements.svg(),
            onTap: () => context.pushNamed(AppRoutes.achievements),
          ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.topLabel,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String topLabel;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSize.w12),
        decoration: BoxDecoration(
          color: context.themeColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r18),
          border: Border.all(color: context.themeColors.borderColor2),
          boxShadow: _kCardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  topLabel,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: context.themeTextColors.bodyTextColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.themeTextColors.bodyTextColor,
                  size: AppSize.sp18,
                ),
              ],
            ),
            SizedBox(height: AppSize.h8),
            Row(
              children: [
                icon,
                SizedBox(width: AppSize.w6),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: context.themeTextColors.darkTitleColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
