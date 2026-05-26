import 'dart:math';

import 'package:ad_manager/ad_manager.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scratcher/widgets.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../services/coin_service.dart';
import '../../services/reward_ad_service.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';

// ── Scratch card state ────────────────────────────────────────────────────────

class _ScratchState {
  _ScratchState() {
    _generateReward();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  final scratchKey = GlobalKey<ScratcherState>();
  late final ConfettiController _confetti;

  bool isThresholdReached = false;
  bool isGiftRevealed = false;
  bool isGiftOpened = false;

  int? reward;

  ConfettiController get confetti => _confetti;

  void _generateReward() {
    final minR = RemoteConfigService.instance.scrachMinReward;
    final maxR = RemoteConfigService.instance.scrachMaxReward;
    final span = (maxR - minR).abs() + 1;
    reward = minR + Random().nextInt(span);
  }

  void revealGift() {
    isGiftRevealed = true;
  }

  void openGift() {
    isGiftOpened = true;
  }

  void dispose() => _confetti.dispose();
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen>
    with TickerProviderStateMixin {
  late final _ScratchState _scratch;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final int _luckyNumber;

  InlineAdManager? _nativeAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'scratch_card',
      screenClass: 'ScratchCardScreen',
    );
    _scratch = _ScratchState();
    _luckyNumber = 100 + Random().nextInt(900);
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    _nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.scratchCardNative,
    );
    await _nativeAd!.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scratch.dispose();
    _shakeCtrl.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _onScratchStopped() {
    if (!_scratch.isThresholdReached || _scratch.isGiftRevealed) return;
    setState(() => _scratch.revealGift());
    _scratch.scratchKey.currentState
        ?.reveal(duration: const Duration(milliseconds: 700));
    _shakeCtrl.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _shakeCtrl
        ..stop()
        ..reset();
      setState(() => _scratch.openGift());
      final reward = _scratch.reward ?? 0;
      if (reward > 0) _scratch.confetti.play();
      _showResultSheet(reward);
    });
  }

  void _showResultSheet(int reward) {
    final isLoss = reward == 0;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetCtx) => _ResultSheet(
        coins: reward,
        isLoss: isLoss,
        onClaim: () async {
          Navigator.pop(sheetCtx);
          if (!isLoss) {
            final navCtx = rootNavKey.currentContext!;
            final earned = await RewardAdService.showScratchCard(
              navCtx,
              defaultCoins: reward,
            );
            if (earned != null) {
              await CoinService.addCoins(earned);
              Injector.instance<AppDB>().recordScratchCard();
            }
          }
          if (!mounted) return;
          NavigationHelper().handleBackPress(context);
        },
      ),
    );
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
        bottomNavigationBar: AdSlot(ad: _nativeAd),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _ScratchAppBar(
                    onBack: () => NavigationHelper().handleBackPress(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSize.w24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: AppSize.h16),

                          // Lucky badge
                          _LuckyBadge(number: _luckyNumber)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(
                                  begin: -0.2,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOut),

                          SizedBox(height: AppSize.h20),

                          // Headline
                          Text(
                            'Scratch to reveal\nyour reward.',
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontSize: AppSize.sp28,
                              fontWeight: FontWeight.w800,
                              color: context.themeColors.navyColor,
                              height: 1.25,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 80.ms, duration: 400.ms),

                          SizedBox(height: AppSize.h28),

                          // Scratch card area
                          _ScratchArea(
                            scratch: _scratch,
                            shakeCtrl: _shakeCtrl,
                            shakeAnim: _shakeAnim,
                            onThreshold: () => setState(
                                () => _scratch.isThresholdReached = true),
                            onScratchStopped: _onScratchStopped,
                          ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

                          SizedBox(height: AppSize.h24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confetti burst
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _scratch.confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Color(0xFFFFD84D),
                  Color(0xFF1A1AE8),
                  Color(0xFFE0006E),
                  Color(0xFF22C55E),
                ],
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────

class _ScratchAppBar extends StatelessWidget {
  const _ScratchAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppSize.w20, vertical: AppSize.h10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: AppSize.r40,
                height: AppSize.r40,
                decoration: BoxDecoration(
                  color: context.themeColors.whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.themeColors.borderColor
                          .withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: context.themeColors.navyColor, size: AppSize.r20),
              ),
            ),
          ),
          Text(
            'Scratch Card',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp18,
              color: context.themeColors.navyColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lucky badge ───────────────────────────────────────────────────────────────

class _LuckyBadge extends StatelessWidget {
  const _LuckyBadge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSize.w16, vertical: AppSize.h8),
      decoration: BoxDecoration(
        color: context.themeColors.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.r100),
        border: Border.all(color: context.themeColors.buttonColor2, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.buttonColor2.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Lucky #$number',
        style: context.textTheme.titleMedium?.copyWith(
          color: context.themeColors.buttonColor2,
        ),
      ),
    );
  }
}

// ── Scratch area (same logic as clip_earn reference) ─────────────────────────

class _ScratchArea extends StatelessWidget {
  const _ScratchArea({
    required this.scratch,
    required this.shakeCtrl,
    required this.shakeAnim,
    required this.onThreshold,
    required this.onScratchStopped,
  });

  final _ScratchState scratch;
  final AnimationController shakeCtrl;
  final Animation<double> shakeAnim;
  final VoidCallback onThreshold;
  final VoidCallback onScratchStopped;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.r20),
        boxShadow: [
          BoxShadow(
            color: context.themeColors.buttonColor.withValues(alpha: 0.25),
            blurRadius: AppSize.r24,
            offset: Offset(0, AppSize.h8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.r20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Listener(
              onPointerUp: (_) => onScratchStopped(),
              child: Scratcher(
              key: scratch.scratchKey,
              brushSize: 70,
              threshold: 40,
              image: Assets.images.scratchCover.image(fit: BoxFit.cover),
              onChange: (_) {},
              onThreshold: onThreshold,
              child: Container(
                height: AppSize.h360,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.themeColors.buttonColor,
                      const Color(0xFF1010C8),
                      const Color(0xFF0808A0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: scratch.isGiftOpened
                    ? _RevealedReward(reward: scratch.reward ?? 0)
                    : scratch.isGiftRevealed
                        ? AnimatedBuilder(
                            animation: shakeAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(sin(shakeAnim.value) * 5, 0),
                              child: Transform.rotate(
                                angle: sin(shakeAnim.value) * 0.1,
                                child: child,
                              ),
                            ),
                            child: Icon(
                              Icons.card_giftcard_rounded,
                              size: AppSize.sp100,
                              color: context.themeColors.coinGoldColor,
                            ),
                          )
                        : Icon(
                            Icons.card_giftcard_rounded,
                            size: AppSize.sp100,
                            color: context.themeColors.whiteColor.withValues(alpha: 0.15),
                          ),
              ),
            ),
            ),

            // "MYSTERY" label — top-left (hidden once threshold reached)
            if (!scratch.isThresholdReached)
              Positioned(
                top: AppSize.h16,
                left: AppSize.w16,
                child: IgnorePointer(
                  child: Text(
                    'MYSTERY',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.themeColors.whiteColor.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

            // "Drag to scratch" hint — bottom-center (hidden once threshold reached)
            if (!scratch.isThresholdReached)
              Positioned(
                bottom: AppSize.h24,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Text(
                    'Drag to scratch',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: AppSize.sp24,
                      fontWeight: FontWeight.w800,
                      color: context.themeColors.whiteColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Revealed reward ───────────────────────────────────────────────────────────

class _RevealedReward extends StatelessWidget {
  const _RevealedReward({required this.reward});
  final int reward;

  @override
  Widget build(BuildContext context) {
    if (reward == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded,
              size: AppSize.r60, color: const Color(0xFFFF5183)),
          SizedBox(height: AppSize.h8),
          Text(
            'Better Luck\nNext Time',
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              color: const Color(0xFFFF5183),
              height: 1.3,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.icons.icCoin.svg(width: AppSize.r56, height: AppSize.r56),
        SizedBox(height: AppSize.h8),
        Text(
          '+$reward',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: AppSize.sp48,
            fontWeight: FontWeight.w900,
            color: context.themeColors.coinGoldColor,
            height: 1,
          ),
        ),
        SizedBox(height: AppSize.h4),
        Text(
          'Coins',
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: AppSize.sp18,
            fontWeight: FontWeight.w600,
            color: context.themeColors.whiteColor.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

// ── Result bottom sheet ───────────────────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.coins,
    required this.isLoss,
    required this.onClaim,
  });

  final int coins;
  final bool isLoss;
  final VoidCallback onClaim;

  static const double _trophyD = 104.0;

  @override
  Widget build(BuildContext context) {
    final half = (_trophyD / 2).r;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        0,
        AppSize.w16,
        bottomPad > 0 ? bottomPad : AppSize.h16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: half),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // White card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.themeColors.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.r28),
                ),
                padding: EdgeInsets.fromLTRB(
                  AppSize.w24,
                  half + AppSize.h16,
                  AppSize.w24,
                  AppSize.h28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: AppSize.h16),
                    Text(
                      isLoss ? 'Oops!' : 'Congratulations..!',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: AppSize.sp26,
                        fontWeight: FontWeight.w800,
                        color: context.themeColors.navyColor,
                      ),
                    ),
                    SizedBox(height: AppSize.h8),
                    Text(
                      isLoss
                          ? 'Better luck next time!'
                          : 'You won $coins Coins',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSize.sp16,
                        color: context.themeTextColors.subtitleColor,
                      ),
                    ),
                    SizedBox(height: AppSize.h28),
                    AppButton(
                      text: isLoss ? 'Try Again' : 'Claim Now',
                      buttonColor: context.themeColors.buttonColor,
                      shadowColor: context.themeColors.buttonBorderColor,
                      foregroundColor: context.themeColors.whiteColor,
                      borderRadius: AppSize.r29,
                      onPressed: onClaim,
                    ),
                  ],
                ),
              ),

              // Floating trophy
              Positioned(
                top: -half,
                child: Container(
                  width: _trophyD.r,
                  height: _trophyD.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.themeColors.xpBadgeColor,
                    border: Border.all(color: context.themeColors.whiteColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: context.themeColors.buttonColor
                            .withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(AppSize.w14),
                  child:
                      Assets.images.trophy.image(fit: BoxFit.contain),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.55, 0.55),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 350.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
