import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../gen/assets.gen.dart';
import '../../models/achievement_model.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/app_button.dart';
import 'provider/achievement_provider.dart';


// ── Screen ────────────────────────────────────────────────────────────────────

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AchievementProvider(),
      child: const _AchievementBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _AchievementBody extends StatefulWidget {
  const _AchievementBody();

  @override
  State<_AchievementBody> createState() => _AchievementBodyState();
}

class _AchievementBodyState extends State<_AchievementBody> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'achievements',
      screenClass: 'AchievementScreen',
    );
  }

  static const _achievements = AchievementDef.all;

  int get _itemCount => _achievements.length + _achievements.length ~/ 2;

  bool _isAdSlot(int index) => (index + 1) % 3 == 0;

  int _achievementIndex(int index) => index - (index + 1) ~/ 3;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        appBar: _AppBar(
          onBack: () => NavigationHelper().handleBackPress(context),
        ),
        body: Consumer<AchievementProvider>(
          builder: (context, prov, _) {
            if (prov.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: context.themeColors.buttonColor2,
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSize.w16,
                AppSize.h16,
                AppSize.w16,
                AppSize.h32,
              ),
              itemCount: _itemCount,
              itemBuilder: (context, index) {
                if (_isAdSlot(index)) {
                  return const _AdPlaceholder()
                      .animate()
                      .fadeIn(duration: 400.ms);
                }

                final achIndex = _achievementIndex(index);
                if (achIndex >= _achievements.length) {
                  return const SizedBox.shrink();
                }

                final def = _achievements[achIndex];
                final progress  = prov.getProgress(def);
                final completed = prov.isCompleted(def);
                final claimed   = prov.isClaimed(def);

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSize.h12),
                  child: _AchievementCard(
                    def: def,
                    progress: progress,
                    isCompleted: completed,
                    isClaimed: claimed,
                    isClaiming: prov.isClaiming,
                    onClaim: () => _handleClaim(prov, def),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: achIndex * 60),
                        duration: 350.ms,
                      )
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: achIndex * 60),
                        duration: 350.ms,
                        curve: Curves.easeOut,
                      ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleClaim(
    AchievementProvider prov,
    AchievementDef def,
  ) async {
    final success = await prov.claimAchievement(def);
    if (!mounted) return;

    if (success) {
      _showClaimSuccess(def);
    } else {
      'Could not claim reward. Try again.'.showErrorAlert();
    }
  }

  void _showClaimSuccess(AchievementDef def) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClaimSuccessSheet(def: def),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w18,
          vertical: AppSize.h6,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leading: GestureDetector(
            onTap: onBack,
            child: Container(
              width: AppSize.r40,
              height: AppSize.r40,
              decoration: BoxDecoration(
                color: context.themeColors.whiteColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.themeColors.borderColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: context.themeColors.navyColor,
                size: AppSize.r20,
              ),
            ),
          ),
          leadingWidth: AppSize.w50,
          title: Text(
            'Achievements',
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp19,
              fontWeight: FontWeight.w800,
              color: context.themeColors.navyColor,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}

// ── Achievement card ──────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.def,
    required this.progress,
    required this.isCompleted,
    required this.isClaimed,
    required this.isClaiming,
    required this.onClaim,
  });

  final AchievementDef def;
  final int progress;
  final bool isCompleted;
  final bool isClaimed;
  final bool isClaiming;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.themeColors.borderColor,
        borderRadius: BorderRadius.circular(AppSize.r24),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSize.h4),
        decoration: BoxDecoration(
          color: context.themeColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.r24),
          border: Border.all(color: context.themeColors.borderColor, width: 1),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSize.w14,
          AppSize.h6,
          AppSize.w14,
          AppSize.h6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _categoryIcon(def.category),
                SizedBox(width: AppSize.w8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.title,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.themeColors.navyColor,
                        ),
                      ),
                      Text(
                        def.description,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.themeTextColors.bodyTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSize.w10),
                // ── Claim button ──────────────────────────────────────────
                // In-progress / claimable: buttonColor2 — same look, onPressed guards action
                // Claimed:                 successColor (green)
                AppButton(
                  text: isClaimed ? 'Claimed' : 'Claim',
                  isAdjust: true,
                  buttonColor: isClaimed
                      ? context.themeColors.successColor
                      : context.themeColors.buttonColor2,
                  shadowColor: isClaimed
                      ? context.themeColors.successShadowColor
                      : context.themeColors.buttonBorderColor2,
                  foregroundColor: context.themeColors.whiteColor,
                  wallOffset: 4,
                  borderRadius: AppSize.r30,
                  horizontalPad: AppSize.w22,
                  verticalPad: AppSize.h6,
                  isDisabled: !isCompleted && !isClaimed,
                  isLoading: isClaiming && isCompleted && !isClaimed,
                  onPressed: isClaimed || !isCompleted ? () {} : onClaim,
                ),
              ],
            ),
            // SizedBox(height: AppSize.h10),
            Row(
              children: [
                Expanded(
                  child: _ProgressBar(progress: progress, goal: def.goal),
                ),
                SizedBox(width: AppSize.w8),
                Assets.icons.icCoin.svg(
                  width: AppSize.sp14,
                  height: AppSize.sp14,
                ),
                SizedBox(width: AppSize.w3),
                Text(
                  '+${def.reward} Coins',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.themeColors.coinAmberColor,
                    fontWeight: FontWeight.w800,
                    fontSize: AppSize.sp12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryIcon(AchievementCategory category) {
    final image = switch (category) {
      AchievementCategory.quiz     => Assets.images.quizMaster,
      AchievementCategory.spin     => Assets.images.spinWheel,
      AchievementCategory.scratch  => Assets.images.scratchCard,
      AchievementCategory.webVisit => Assets.images.webVisits2,
      AchievementCategory.checkIn ||
      AchievementCategory.streak   => Assets.images.gifts,
      AchievementCategory.coins    => Assets.images.trophy,
    };
    return image.image(
      width: AppSize.w60,
      height: AppSize.h60,
      fit: BoxFit.contain,
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.goal});

  final int progress;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final fraction = goal > 0 ? (progress / goal).clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.r100),
      child: SizedBox(
        height: AppSize.h10,
        child: LinearProgressIndicator(
          value: fraction,
          backgroundColor: context.themeColors.progressBgColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.themeColors.coinGoldColor,
          ),
        ),
      ),
    );
  }
}

// ── AD placeholder ────────────────────────────────────────────────────────────

class _AdPlaceholder extends StatelessWidget {
  const _AdPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.h80,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSize.h12),
      decoration: BoxDecoration(
        color: context.themeColors.adPlaceholderBg,
        borderRadius: BorderRadius.circular(AppSize.r16),
        border: Border.all(color: context.themeColors.adPlaceholderBorder, width: 1),
      ),
      child: Center(
        child: Text(
          'AD',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.themeColors.adPlaceholderText,
            fontWeight: FontWeight.w700,
            fontSize: AppSize.sp14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ── Claim success sheet ───────────────────────────────────────────────────────

class _ClaimSuccessSheet extends StatelessWidget {
  const _ClaimSuccessSheet({required this.def});

  final AchievementDef def;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h24,
        AppSize.w24,
        AppSize.h32 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.r24)),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.buttonColor2.withValues(alpha: 0.15),
            blurRadius: AppSize.r24,
            offset: Offset(0, -AppSize.h6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.w40,
            height: AppSize.h4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.r100),
              color: context.themeColors.dragHandleColor,
            ),
          ),
          SizedBox(height: AppSize.h20),
          Assets.images.trophy.image(
            width: AppSize.w80,
            height: AppSize.h80,
            fit: BoxFit.contain,
          ),
          SizedBox(height: AppSize.h16),
          Text(
            'Achievement Unlocked!',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: context.themeColors.navyColor,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            def.title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.themeColors.buttonColor2,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSize.h6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icCoin.svg(
                width: AppSize.sp18,
                height: AppSize.sp18,
              ),
              SizedBox(width: AppSize.w6),
              Text(
                '+${def.reward} Coins Awarded!',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.themeColors.coinGoldColor,
                  fontWeight: FontWeight.w700,
                  fontSize: AppSize.sp16,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.h28),
          AppButton(
            text: 'Awesome!',
            buttonColor: context.themeColors.buttonColor2,
            shadowColor: context.themeColors.buttonBorderColor2,
            foregroundColor: context.themeColors.whiteColor,
            wallOffset: 4,
            borderRadius: AppSize.r100,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
