import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/utils/app_size.dart';
import 'package:watch_earn_4/utils/anaytics_manager.dart';
import 'package:watch_earn_4/utils/navigation_helper.dart';
import 'package:watch_earn_4/widgets/common_appbar.dart';

import 'model/leaderboard_user_model.dart';
import 'provider/rank_provider.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'leaderboard',
      screenClass: 'RankScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RankProvider(),
      child: Consumer<RankProvider>(
        builder: (context, provider, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              NavigationHelper().handleBackPress(context);
            },
            child: Scaffold(
              backgroundColor: context.themeColors.backgroundColor,
              appBar: CommonAppBar(titleText: context.l10n.topEarners, showLeading: false,),
              body: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(
                      child: Text(
                        provider.error!,
                        style: context.textTheme.bodyMedium,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => provider.refresh(),
                      notificationPredicate: (_) => provider.canRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSize.w16,
                          AppSize.h12,
                          AppSize.w16,
                          AppSize.h20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Podium(players: provider.top3),
                            SizedBox(height: AppSize.h16),
                            _RefreshTimerRow(
                              canRefresh: provider.canRefresh,
                              formattedTimer: provider.formattedTimer,
                            ),
                            SizedBox(height: AppSize.h16),
                            _TableHeader(),
                            SizedBox(height: AppSize.h12),
                            for (int i = 0; i < provider.listUsers.length; i++) ...[
                              _RankRow(user: provider.listUsers[i], rank: i + 4),
                              SizedBox(height: AppSize.h12),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ── Refresh timer ────────────────────────────────────────────────────────────

class _RefreshTimerRow extends StatelessWidget {
  const _RefreshTimerRow({required this.canRefresh, required this.formattedTimer});

  final bool canRefresh;
  final String formattedTimer;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w16,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r12),
        border: Border.all(color: colors.borderColor2),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: canRefresh ? colors.successColor : colors.coinGoldColor,
            size: AppSize.sp20,
          ),
          SizedBox(width: AppSize.w8),
          Text(
            canRefresh ? context.l10n.pullDownToRefresh : context.l10n.refreshesIn(formattedTimer),
            style: context.textTheme.bodyMedium?.copyWith(
              color: canRefresh
                  ? colors.successColor
                  : context.themeTextColors.bodyTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Table header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w16,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r12),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSize.w30,
            child: Text(
              context.l10n.rankHash,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _RankColors.title,
              ),
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.rankPlayer,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: _RankColors.title,
              ),
            ),
          ),
          Text(
            context.l10n.rankCoins,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: _RankColors.title,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Colors ───────────────────────────────────────────────────────────────────
class _RankColors {
  static const title = Color(0xFF0B0E2C);
  static const body = Color(0xFF8A8FA8);
  static const cardBorder = Color(0xFFA4ABC6);
  static const gold = Color(0xFFF7A91E);
  static const goldDeep = Color(0xFFE38A00);
  static const silver = Color(0xFFB8BCC7);
  static const silverDeep = Color(0xFFA0A4B1);
  static const bronze = Color(0xFFC58A5E);
  static const bronzeDeep = Color(0xFFB07344);
  static const avatarBg = Color(0xFFE7E9F2);
  static const rowWallShadow = Color(0xFFA1A1B2);
  static const rowWallLightShadow = Color(0xFFC5C5C5);
}

// ── Podium ───────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  const _Podium({required this.players});
  final List<LeaderboardUser> players;

  @override
  Widget build(BuildContext context) {
    final second = players.length > 1 ? players[1] : null;
    final first = players.isNotEmpty ? players[0] : null;
    final third = players.length > 2 ? players[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: second != null
              ? _PodiumColumn(user: second, rank: 2, barHeight: AppSize.h100)
              : const SizedBox(),
        ),
        Expanded(
          child: first != null
              ? _PodiumColumn(user: first, rank: 1, barHeight: AppSize.h140)
              : const SizedBox(),
        ),
        Expanded(
          child: third != null
              ? _PodiumColumn(user: third, rank: 3, barHeight: AppSize.h70)
              : const SizedBox(),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.user, required this.rank, required this.barHeight});

  final LeaderboardUser user;
  final int rank;
  final double barHeight;

  ({Color avatarRing, Color barColor, Color barShadow}) _palette() {
    switch (rank) {
      case 1:
        return (
          avatarRing: _RankColors.goldDeep,
          barColor: _RankColors.gold,
          barShadow: _RankColors.goldDeep,
        );
      case 2:
        return (
          avatarRing: _RankColors.silverDeep,
          barColor: _RankColors.silver,
          barShadow: _RankColors.silverDeep,
        );
      default:
        return (
          avatarRing: _RankColors.bronzeDeep,
          barColor: _RankColors.bronze,
          barShadow: _RankColors.bronzeDeep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final isFirst = rank == 1;
    final avatarSize = isFirst ? AppSize.w58 : AppSize.w50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) ...[
          Icon(Icons.emoji_events_rounded, color: _RankColors.gold, size: AppSize.sp22),
          SizedBox(height: AppSize.h4),
        ],
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: palette.avatarRing, width: 2),
            boxShadow: [
              BoxShadow(
                color: palette.avatarRing.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            user.initial,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: isFirst ? AppSize.sp16 : AppSize.sp14,
              fontWeight: FontWeight.w900,
              color: _RankColors.title,
            ),
          ),
        ),
        SizedBox(height: AppSize.h6),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: AppSize.sp15,
            fontWeight: FontWeight.w900,
            color: _RankColors.title,
          ),
        ),
        SizedBox(height: AppSize.h2),
        Text(
          '${user.coins} coins',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: AppSize.sp12,
            fontWeight: FontWeight.w700,
            color: palette.barColor,
          ),
        ),
        SizedBox(height: AppSize.h8),
        _PodiumBar(rank: rank, height: barHeight, color: palette.barColor, shadow: palette.barShadow),
      ],
    );
  }
}

class _PodiumBar extends StatelessWidget {
  const _PodiumBar({
    required this.rank,
    required this.height,
    required this.color,
    required this.shadow,
  });

  final int rank;
  final double height;
  final Color color;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: AppSize.w8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSize.r18),
          topRight: Radius.circular(AppSize.r18),
        ),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.25),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: context.textTheme.titleLarge?.copyWith(
          fontSize: AppSize.sp24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Rank list row ─────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({required this.user, required this.rank});

  final LeaderboardUser user;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: _RankColors.cardBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _RankColors.rowWallLightShadow,
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: _RankColors.rowWallShadow,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w12,
        vertical: AppSize.h14,
      ),
      child: Row(
        children: [
          _RankCircle(rank: rank),
          SizedBox(width: AppSize.w10),
          _InitialsAvatar(initial: user.initial),
          SizedBox(width: AppSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: AppSize.sp15,
                    fontWeight: FontWeight.w900,
                    color: _RankColors.title,
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Text(
                  context.l10n.lvTierValue(user.level, user.tier),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp12,
                    color: _RankColors.body,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSize.w8),
          Text(
            user.coins,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w900,
              color: _RankColors.title,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCircle extends StatelessWidget {
  const _RankCircle({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w30,
      height: AppSize.w30,
      decoration: const BoxDecoration(
        color: _RankColors.avatarBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: AppSize.sp13,
          fontWeight: FontWeight.w900,
          color: _RankColors.title,
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w34,
      height: AppSize.w34,
      decoration: const BoxDecoration(
        color: _RankColors.avatarBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: AppSize.sp12,
          fontWeight: FontWeight.w900,
          color: _RankColors.title,
        ),
      ),
    );
  }
}
