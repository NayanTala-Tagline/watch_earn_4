import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../extension/ext_context.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';

class _Step {
  const _Step(this.title, this.description);
  final String title;
  final String description;
}

List<_Step> _buildSteps(BuildContext context) => [
      _Step(context.l10n.stepWhatAreCoinsTitle, context.l10n.stepWhatAreCoinsDesc),
      _Step(context.l10n.stepDailyMissionsTitle, context.l10n.stepDailyMissionsDesc),
      _Step(context.l10n.stepSpinWheelTitle, context.l10n.stepSpinWheelDesc),
      _Step(context.l10n.stepScratchCardsTitle, context.l10n.stepScratchCardsDesc),
      _Step(context.l10n.stepQuizGameTitle, context.l10n.stepQuizGameDesc),
      _Step(context.l10n.stepWatchAdsTitle, context.l10n.stepWatchAdsDesc),
      _Step(context.l10n.stepReferralSystemTitle, context.l10n.stepReferralSystemDesc),
      _Step(context.l10n.stepWithdrawMoneyTitle, context.l10n.stepWithdrawMoneyDesc),
    ];

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key, this.preloadedNative});
  final InlineAdManager? preloadedNative;

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'how_it_works',
      screenClass: 'HowItWorksScreen',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.w16,
                AppSize.h8,
                AppSize.w16,
                AppSize.h8,
              ),
              child: _ReadyCard(
                onPressed: () => NavigationHelper().handleBackPress(context),
              ),
            ),
            AdSlot(ad: widget.preloadedNative),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AppBar(
                onBack: () => NavigationHelper().handleBackPress(context),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w16,
                    AppSize.h12,
                    AppSize.w16,
                    AppSize.h12,
                  ),
                  itemCount: _buildSteps(context).length,
                  itemBuilder: (context, index) {
                    final steps = _buildSteps(context);
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSize.h12),
                      child: _StepCard(
                        index: index + 1,
                        step: steps[index],
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: index * 60),
                            duration: 350.ms,
                          )
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            delay: Duration(milliseconds: index * 60),
                            duration: 350.ms,
                            curve: Curves.easeOut,
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w18,
        vertical: AppSize.h6,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: AppSize.r40,
              height: AppSize.r40,
              decoration: BoxDecoration(
                color: context.themeColors.whiteColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        context.themeColors.borderColor.withValues(alpha: 0.25),
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
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: AppSize.r40),
                child: Text(
                  context.l10n.howItWorks,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp19,
                    fontWeight: FontWeight.w800,
                    color: context.themeColors.navyColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step card ────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});

  final int index;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSize.w14),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.cardShadowColor,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.r40,
            height: AppSize.r40,
            decoration: BoxDecoration(
              color: context.themeColors.buttonColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSize.r12),
              border: Border.all(
                color: context.themeColors.buttonColor.withValues(alpha: 0.35),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: AppSize.sp18,
                fontWeight: FontWeight.w900,
                color: context.themeColors.buttonColor,
              ),
            ),
          ),
          SizedBox(width: AppSize.w14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: AppSize.sp16,
                    fontWeight: FontWeight.w900,
                    color: context.themeColors.navyColor,
                  ),
                ),
                SizedBox(height: AppSize.h6),
                Text(
                  step.description,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: AppSize.sp13,
                    color: context.themeTextColors.bodyTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ready card ───────────────────────────────────────────────────────────────

class _ReadyCard extends StatelessWidget {
  const _ReadyCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        AppSize.h18,
        AppSize.w16,
        AppSize.h18,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r20),
        border: Border.all(color: context.themeColors.borderColor2),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.cardShadowColor,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.l10n.howItWorksReady,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w900,
              color: context.themeColors.navyColor,
            ),
          ),
          SizedBox(height: AppSize.h14),
          AppButton(
            text: context.l10n.backToHome,
            buttonColor: context.themeColors.buttonColor,
            shadowColor: context.themeColors.buttonBorderColor,
            foregroundColor: context.themeColors.whiteColor,
            borderRadius: AppSize.r29,
            wallOffset: 4,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
