import 'package:flutter/material.dart';
import 'package:watch_earn_4/extension/ext_context.dart';
import 'package:watch_earn_4/utils/app_size.dart';

class RankScreen extends StatelessWidget {
  const RankScreen({super.key});

  static const _pageBg = Color(0xFFEEF0F8);

  static const _topEarners = <_Earner>[
    _Earner(rank: 2, name: 'Mei', initials: 'ML', amount: 128.26),
    _Earner(rank: 1, name: 'Aarav', initials: 'AS', amount: 142.29),
    _Earner(rank: 3, name: 'Diego', initials: 'DR', amount: 119.60),
  ];

  static const _others = <_Earner>[
    _Earner(rank: 4, name: 'Sofia P.', initials: 'SP', amount: 98.10),
    _Earner(
      rank: 5,
      name: 'Riya (You)',
      initials: 'SP',
      amount: 98.10,
      subtitle: 'Rising',
      isYou: true,
    ),
    _Earner(rank: 6, name: 'Marcus J.', initials: 'MJ', amount: 120.50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSize.w16,
            AppSize.h12,
            AppSize.w16,
            AppSize.h20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Top Earners',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: AppSize.sp22,
                    fontWeight: FontWeight.w900,
                    color: _RankColors.title,
                  ),
                ),
              ),
              SizedBox(height: AppSize.h24),
              _Podium(earners: _topEarners),
              SizedBox(height: AppSize.h20),
              ..._others.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: AppSize.h16),
                  child: _RankRow(earner: e),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────
class _Earner {
  const _Earner({
    required this.rank,
    required this.name,
    required this.initials,
    required this.amount,
    this.subtitle,
    this.isYou = false,
  });

  final int rank;
  final String name;
  final String initials;
  final double amount;
  final String? subtitle;
  final bool isYou;
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
  static const youBorder = Color(0xFFE63F6E);
  static const youAvatarBg = Color(0xFFFDE2EA);
  static const youAvatarText = Color(0xFFE63F6E);
  static const avatarBg = Color(0xFFE7E9F2);
  static const rowWallShadow = Color(0xFFA1A1B2);
  static const youWallShadow = Color(0xFFE0006E);
  static const rowWallLightShadow = Color(0xFFC5C5C5);
  static const youWallLightShadow = Color(0x60E0006E);
}

// ── Podium ───────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  const _Podium({required this.earners});
  final List<_Earner> earners;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumColumn(earner: earners[0], barHeight: AppSize.h100)),
        Expanded(child: _PodiumColumn(earner: earners[1], barHeight: AppSize.h140)),
        Expanded(child: _PodiumColumn(earner: earners[2], barHeight: AppSize.h70)),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.earner, required this.barHeight});

  final _Earner earner;
  final double barHeight;

  ({Color avatarRing, Color barColor, Color barShadow}) _palette() {
    switch (earner.rank) {
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

  String get _amountStr {
    final s = earner.amount.toStringAsFixed(2);
    return '\$$s';
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final isFirst = earner.rank == 1;
    final avatarSize = isFirst ? AppSize.w58 : AppSize.w50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: palette.avatarRing, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            earner.initials,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: isFirst ? AppSize.sp16 : AppSize.sp14,
              fontWeight: FontWeight.w900,
              color: _RankColors.title,
            ),
          ),
        ),
        SizedBox(height: AppSize.h6),
        Text(
          earner.name,
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
          _amountStr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: AppSize.sp13,
            fontWeight: FontWeight.w800,
            color: _RankColors.title,
          ),
        ),
        SizedBox(height: AppSize.h8),
        _PodiumBar(
          rank: earner.rank,
          height: barHeight,
          color: palette.barColor,
          shadow: palette.barShadow,
        ),
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
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSize.h0),
        child: Text(
          '$rank',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: AppSize.sp24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Rank list row ────────────────────────────────────────────────────────────
class _RankRow extends StatelessWidget {
  const _RankRow({required this.earner});
  final _Earner earner;

  String get _amountStr {
    final s = earner.amount.toStringAsFixed(2);
    return '\$$s';
  }

  @override
  Widget build(BuildContext context) {
    final isYou = earner.isYou;
    final wallColor = isYou ? _RankColors.youWallShadow : _RankColors.rowWallShadow;
    final wallLightColor = isYou ? _RankColors.youWallLightShadow : _RankColors.rowWallLightShadow;

    return
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSize.r20),
          boxShadow: [
            BoxShadow(
              color: wallLightColor,
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child:  Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w12,
            vertical: AppSize.h14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSize.r20),
            border: Border.all(
              color: isYou ? _RankColors.youBorder : _RankColors.cardBorder,
              width: isYou ? 1.6 : 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: wallColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              _RankCircle(rank: earner.rank),
              SizedBox(width: AppSize.w10),
              _InitialsAvatar(
                initials: earner.initials,
                isYou: isYou,
              ),
              SizedBox(width: AppSize.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      earner.name,
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
                      earner.subtitle ?? '-',
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
                _amountStr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w900,
                  color: _RankColors.title,
                ),
              ),
            ],
          ),
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
  const _InitialsAvatar({required this.initials, required this.isYou});
  final String initials;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.w34,
      height: AppSize.w34,
      decoration: BoxDecoration(
        color: isYou ? _RankColors.youAvatarBg : _RankColors.avatarBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: AppSize.sp12,
          fontWeight: FontWeight.w900,
          color: isYou ? _RankColors.youAvatarText : _RankColors.title,
        ),
      ),
    );
  }
}
