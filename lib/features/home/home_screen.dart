import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watch_earn_4/gen/assets.gen.dart';
import 'package:watch_earn_4/gen/fonts.gen.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _pageBg = Color(0xFFEEF0F8);
  static const _titleColor = Color(0xFF0E0F66);
  static const _dailyRewardTitleColor = Color(0xFF0B0E2C);
  static const _earnGridTitleColor = Color(0xFF0F172A);
  static const _totalBalanceTxtColor = Color(0xFF6B7393);
  static const _bodyColor = Color(0xFF8A8FA8);
  static const _cardBorder = Color(0xFFEDEFF5);
  static const _primaryBlue = Color(0xFF1A1AE8);
  static const _primaryBlueShadow = Color(0xFF0E0F66);

  // Coin pill palette
  static const _coinPillSurface = Color(0xFFFFF1D6);
  static const _coinPillShadow = Color(0xFFC97A00);
  static const _coinPillText = Color(0xFF7A4A00);

  // Days pill palette
  static const _daysPillSurface = Color(0xFFFFE3EE);
  static const _daysPillShadow = Color(0xFFE0006E);
  static const _daysPillText = Color(0xFFE0006E);

  // LV / XP palette
  static const _xpBgColor = Color(0xFFE6E7FF);
  static const _xpTextColor = Color(0xFF0E0F66);

  // Coin C-icon gradient
  static const _coinGradient1 = Color(0xFFFFD86A);
  static const _coinGradient2 = Color(0xFFFFB620);
  static const _coinGradient3 = Color(0xFFC97A00);

  // Claim button palette
  static const _claimSurface = Color(0xFFFF5C8F);
  static const _claimShadow = Color(0xFF880343);

  // Shared soft drop-shadow for white cards
  static const _cardShadow = [
    BoxShadow(
      color: Color(0x140E0F66),
      offset: Offset(0, 6),
      blurRadius: 16,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSize.w16,
                  AppSize.h8,
                  AppSize.w16,
                  AppSize.h20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BalanceCard(),
                    SizedBox(height: AppSize.h14),
                    const _DailyRewardCard(),
                    SizedBox(height: AppSize.h12),
                    const _StatsRow(),
                    SizedBox(height: AppSize.h16),
                    _sectionTitle('Earn Money'),
                    SizedBox(height: AppSize.h14),
                    const _EarnGrid(),
                    SizedBox(height: AppSize.h16),
                    const _HowItWorksCard(),
                    SizedBox(height: AppSize.h16),
                    const _BottomShortcuts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h8,
        AppSize.w16,
        AppSize.h8,
      ),
      child: Row(
        children: [
          const _CoinsPill(),
          const Spacer(),
          Assets.images.splash.splashLogo.image(
            width: AppSize.w60,
            height: AppSize.w60,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          const _DaysPill(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: FontFamily.kommonGrotesk,
      fontSize: AppSize.sp18,
      fontWeight: FontWeight.w900,
      color: _dailyRewardTitleColor,
    ),
  );
}

// ── Top pills ──────────────────────────────────────────────────────────────
class _CoinsPill extends StatelessWidget {
  const _CoinsPill();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '50000',
      isAdjust: true,
      buttonColor: HomeScreen._coinPillSurface,
      shadowColor: HomeScreen._coinPillShadow,
      foregroundColor: HomeScreen._coinPillText,
      horizontalPad: AppSize.w12,
      verticalPad: AppSize.w7,
      borderRadius: AppSize.r24,
      wallOffset: 4,
      textStyle: TextStyle(
        fontFamily: FontFamily.kommonGrotesk,
        fontSize: AppSize.sp13,
        fontWeight: FontWeight.w900,
        color: HomeScreen._coinPillShadow,
      ),
      icon: Assets.icons.icCoin.svg(width: 19.w, height: 19.w),
      onPressed: () {},
    );
  }
}

class _DaysPill extends StatelessWidget {
  const _DaysPill();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '18 Days',
      isAdjust: true,
      buttonColor: HomeScreen._daysPillSurface,
      shadowColor: HomeScreen._daysPillShadow,
      foregroundColor: HomeScreen._daysPillText,
      horizontalPad: AppSize.w12,
      verticalPad: AppSize.w7,
      wallOffset: 4,
      textStyle: TextStyle(
        fontFamily: FontFamily.kommonGrotesk,
        fontSize: AppSize.sp13,
        fontWeight: FontWeight.w900,
        color: HomeScreen._daysPillText,
      ),
      trailingIcon:  Assets.icons.icFire.svg(width: 19.w, height: 19.w),
      onPressed: () {},
    );
  }
}

// ── Total Balance card ─────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r25),
        border: Border.all(color: HomeScreen._cardBorder),
        boxShadow: HomeScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w500,
              color: HomeScreen._totalBalanceTxtColor,
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
                const TextSpan(text: '\$24'),
                TextSpan(
                  text: '.86',
                  style: TextStyle(
                    color: const Color(0xFF9AA0B5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.h12),
          Row(
            children: [
              const _CoinPill(label: '2,486 Coins'),
              SizedBox(width: AppSize.w10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w10,
                  vertical: AppSize.h6,
                ),
                decoration: BoxDecoration(
                  color: HomeScreen._xpBgColor,
                  borderRadius: BorderRadius.circular(AppSize.r16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: AppSize.sp16,
                      color: HomeScreen._xpTextColor,
                    ),
                    SizedBox(width: AppSize.w4),
                    Text(
                      'LV 5 - 412 XP',
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp12,
                        fontWeight: FontWeight.w900,
                        color: HomeScreen._xpTextColor,
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
                    buttonColor: HomeScreen._primaryBlue,
                    shadowColor: HomeScreen._primaryBlueShadow,
                    foregroundColor: Colors.white,
                    wallOffset: 4,
                    borderRadius: AppSize.r28,
                    textStyle: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    onPressed: () {},
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
                    borderColor: HomeScreen._cardBorder,
                    borderWidth: 1.4,
                    textStyle: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp15,
                      fontWeight: FontWeight.w700,
                      color: HomeScreen._titleColor,
                    ),
                    onPressed: () {},
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
        color: const Color(0xFFFFF3D1),
        borderRadius: BorderRadius.circular(AppSize.r16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.icCoin.svg(width: 19.w, height: 19.w),
          SizedBox(width: AppSize.w6),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp12,
              fontWeight: FontWeight.w900,
              color: HomeScreen._coinPillShadow,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Reward card ──────────────────────────────────────────────────────
class _DailyRewardCard extends StatelessWidget {
  const _DailyRewardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w12,
        vertical: AppSize.h22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFF1E0), Color(0xFFFFE0C9)],
        ),
        borderRadius: BorderRadius.circular(AppSize.r20),
      ),
      child: Row(
        children: [
          AppButton(
            text: '',
            isAdjust: true,
            showIconOnly: true,
            buttonColor: HomeScreen._coinGradient2,
            shadowColor: HomeScreen._coinPillShadow,
            foregroundColor: HomeScreen._daysPillText,
            horizontalPad: AppSize.w10,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r14,
            wallOffset: 4,
            icon: Assets.icons.icGift.svg(width: 30.w, height: 30.w),
            onPressed: () {},
          ),
          SizedBox(width: AppSize.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Reward - Day 18',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w900,
                    color: HomeScreen._dailyRewardTitleColor,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  'Collect +10 coins, Reset in 14h',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w600,
                    color: HomeScreen._bodyColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSize.w8),
          AppButton(
            text: 'Claim',
            isAdjust: true,
            buttonColor: HomeScreen._daysPillShadow,
            shadowColor: HomeScreen._claimShadow,
            foregroundColor: Colors.white,
            horizontalPad: AppSize.w14,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r22,
            wallOffset: 4,
            textStyle: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icCoin.svg(width: 20.w, height: 20.w),
            label: 'Today',
            value: '\$1.20',
          ),
        ),
        SizedBox(width: AppSize.w10),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icXp.svg(width: 15.w, height: 15.w),
            label: 'XP',
            value: '+45',
          ),
        ),
        SizedBox(width: AppSize.w10),
        Expanded(
          child: _StatCard(
            icon: Assets.icons.icRank.svg(width: 15.w, height: 15.w),
            label: 'Rank',
            value: '#214',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color: HomeScreen._cardBorder),
        boxShadow: HomeScreen._cardShadow,
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
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w600,
                    color: HomeScreen._bodyColor,
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
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp18,
              fontWeight: FontWeight.w900,
              color: HomeScreen._titleColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ad placeholder ─────────────────────────────────────────────────────────

// ── Earn Money grid ────────────────────────────────────────────────────────
class _EarnGrid extends StatelessWidget {
  const _EarnGrid();

  @override
  Widget build(BuildContext context) {
    final items = const <_EarnItem>[
      _EarnItem(
        title: 'Quiz Master',
        subtitle: 'Answer & Earn',
        reward: '+50',
        illustration: _EarnIllustration.quiz,
      ),
      _EarnItem(
        title: 'Spin Wheel',
        subtitle: 'Spin and Win',
        reward: '+25',
        illustration: _EarnIllustration.spin,
      ),
      _EarnItem(
        title: 'Scratch Card',
        subtitle: 'Scratch and Reveal',
        reward: '+15',
        illustration: _EarnIllustration.scratch,
      ),
      _EarnItem(
        title: 'Web Visits',
        subtitle: 'Visit & Earn',
        reward: '+32',
        illustration: _EarnIllustration.web,
      ),
      _EarnItem(
        title: 'Game Zone',
        subtitle: 'Play Games',
        reward: '+40',
        illustration: _EarnIllustration.game,
      ),
      _EarnItem(
        title: 'Refer & Earn',
        subtitle: 'Invite Friends',
        reward: '+10',
        illustration: _EarnIllustration.refer,
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
  });

  final String title;
  final String subtitle;
  final String reward;
  final _EarnIllustration illustration;
}

class _EarnTile extends StatelessWidget {
  const _EarnTile({required this.item});
  final _EarnItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:AppSize.w12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: HomeScreen._cardBorder),
        boxShadow: HomeScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EarnArt(kind: item.illustration),
          Padding(padding: EdgeInsets.symmetric(horizontal:AppSize.w12,vertical:AppSize.w12  ),
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                item.title,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight(950),
                  color: HomeScreen._earnGridTitleColor,
                ),
              ),
                SizedBox(height: AppSize.h2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp11,
                    fontWeight: FontWeight.w600,
                    color: HomeScreen._bodyColor,
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
                        color: const Color(0xFFFFF3D1),
                        borderRadius: BorderRadius.circular(AppSize.r14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.icons.icCoin.svg(width: 20.w, height: 20.w),
                          // _CoinIcon(size: AppSize.w18),
                          SizedBox(width: AppSize.w4),
                          Text(
                            item.reward,
                            style: TextStyle(
                              fontFamily: FontFamily.kommonGrotesk,
                              fontSize: AppSize.sp12,
                              fontWeight: FontWeight.w900,
                              color: HomeScreen._coinPillShadow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: HomeScreen._bodyColor,
                      size: AppSize.sp22,
                    ),
                  ],
                ),],
            ),)

        ],
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
      _EarnIllustration.quiz => Assets.images.quizMaster,
      _EarnIllustration.spin => Assets.images.spinWheel,
      _EarnIllustration.scratch => Assets.images.scratchCard,
      _EarnIllustration.web => Assets.images.webVisits,
      _EarnIllustration.game => Assets.images.gameZone2,
      _EarnIllustration.refer => Assets.images.referAndEarn,
    };

    return asset.image(
      width: AppSize.w86,
      height: AppSize.w60,
      fit: BoxFit.cover,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r24),
        border: Border.all(color: HomeScreen._cardBorder),
        boxShadow: HomeScreen._cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppButton(
            text: '',
            isAdjust: true,
            showIconOnly: true,
            buttonColor: HomeScreen._daysPillShadow,
            shadowColor: HomeScreen._claimShadow,
            foregroundColor: HomeScreen._daysPillText,
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
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp15,
                    fontWeight: FontWeight.w900,
                    color: HomeScreen._titleColor,
                  ),
                ),
                SizedBox(height: AppSize.h4),
                Text(
                  'Lern Step-by-Step how to\nearn money',
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp12,
                    fontWeight: FontWeight.w600,
                    color: HomeScreen._bodyColor,
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
            buttonColor: HomeScreen._primaryBlue,
            shadowColor: HomeScreen._primaryBlueShadow,
            foregroundColor: Colors.white,
            horizontalPad: AppSize.w18,
            verticalPad: AppSize.h8,
            borderRadius: AppSize.r22,
            wallOffset: 4,
            textStyle: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
            icon: Icons.leaderboard_rounded,
            iconColor: const Color(0xFFFFB300),
          ),
        ),
        SizedBox(width: AppSize.w12),
        Expanded(
          child: _ShortcutCard(
            topLabel: 'XP',
            title: 'Achievements',
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFE63F6E),
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
    required this.iconColor,
  });

  final String topLabel;
  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r18),
        border: Border.all(color: HomeScreen._cardBorder),
        boxShadow: HomeScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                topLabel,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp12,
                  fontWeight: FontWeight.w600,
                  color: HomeScreen._bodyColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: HomeScreen._bodyColor,
                size: AppSize.sp18,
              ),
            ],
          ),
          SizedBox(height: AppSize.h8),
          Row(
            children: [
              Icon(icon, color: iconColor, size: AppSize.sp22),
              SizedBox(width: AppSize.w6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w900,
                    color: HomeScreen._dailyRewardTitleColor,
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

