import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../db/app_db.dart';
import '../../di/injector.dart';
import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../gen/fonts.gen.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/app_button.dart';
import 'widgets/spin_wheel_painter.dart';

const _kMaxSpinsPerDay = 3;

// ── Main screen ───────────────────────────────────────────────────────────────

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  bool _showWelcome = true;
  bool _isSpinning = false;
  int _spinsRemaining = _kMaxSpinsPerDay;

  late final AnimationController _ctrl;
  Animation<double>? _rotation;
  int _wonCoins = 0;
  String _wonLabel = '';
  double _currentAngle = 0;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _spinsRemaining = Injector.instance<AppDB>().getRemainingSpins(_kMaxSpinsPerDay);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _currentAngle = _rotation?.value ?? _currentAngle;
        setState(() => _isSpinning = false);
        _showResultSheet();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onGetStarted() => setState(() => _showWelcome = false);

  void _onSpin() {
    if (_isSpinning || _spinsRemaining <= 0) return;

    const segments = defaultSegments;
    final index = _random.nextInt(segments.length);
    _wonCoins = segments[index].coins;
    _wonLabel = segments[index].label;

    final segAngle = 2 * pi / segments.length;
    // Land the center of [index] under the top pointer.
    final targetAngle = 2 * pi - (segAngle * index + segAngle / 2);
    final currentMod = _currentAngle % (2 * pi);
    var delta = targetAngle - currentMod;
    if (delta < 0) delta += 2 * pi;
    final totalAngle = (5 + _random.nextInt(3)) * 2 * pi + delta;

    _rotation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + totalAngle,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.reset();
    setState(() => _isSpinning = true);
    _ctrl.forward();
  }

  void _showResultSheet() {
    final db = Injector.instance<AppDB>();
    db.recordSpin();
    setState(() => _spinsRemaining = db.getRemainingSpins(_kMaxSpinsPerDay));

    final isLoss = defaultSegments.firstWhere((s) => s.label == _wonLabel).isLoss;
    final isXp = defaultSegments.firstWhere((s) => s.label == _wonLabel).isXp;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetCtx) => _ResultSheet(
        coins: _wonCoins,
        label: _wonLabel,
        isLoss: isLoss,
        isXp: isXp,
        onClaim: () => Navigator.pop(sheetCtx),
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
        backgroundColor: const Color(0xFFECEEFA),
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(onBack: () => NavigationHelper().handleBackPress(context)),
              Expanded(
                child: _showWelcome
                    ? _WelcomeBody(
                        spinsRemaining: _spinsRemaining,
                        currentAngle: _currentAngle,
                        onGetStarted: _onGetStarted,
                      )
                    : _SpinBody(
                        isSpinning: _isSpinning,
                        spinsRemaining: _spinsRemaining,
                        currentAngle: _currentAngle,
                        rotation: _rotation,
                        onSpin: _onSpin,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA4ABC6).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: const Color(0xFF1C2359),
                  size: 20.r,
                ),
              ),
            ),
          ),
          Text(
            'Spin & Win',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C2359),
            ),
          ),
        ],
      ),
    );
  }
}

// ── State 1: Welcome ──────────────────────────────────────────────────────────

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody({
    required this.spinsRemaining,
    required this.currentAngle,
    required this.onGetStarted,
  });

  final int spinsRemaining;
  final double currentAngle;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        children: [
          SizedBox(height: AppSize.h8),

          // "N Spins Left Today" badge — centered
          Center(
            child: _SpinsLeftBadge(count: spinsRemaining)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          ),

          SizedBox(height: AppSize.h20),

          // Headline
          Text(
            'Take a spin.\nStack the coins.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C2359),
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),

          SizedBox(height: AppSize.h24),

          // Wheel
          Expanded(
            child: _WheelComposite(angle: currentAngle)
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .scale(
                  begin: const Offset(0.88, 0.88),
                  end: const Offset(1, 1),
                  delay: 150.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
          ),

          SizedBox(height: AppSize.h20),

          // Info cards row
          Row(
            spacing: AppSize.w12,
            children: const [
              Expanded(child: _InfoCard(label: 'Possible Win', value: 'Up to \$1.00')),
              Expanded(child: _InfoCard(label: 'Streak Bonus', value: 'x2')),
            ],
          )
              .animate()
              .fadeIn(delay: 220.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, delay: 220.ms, duration: 400.ms, curve: Curves.easeOut),

          SizedBox(height: AppSize.h20),

          // Get Started button
          AppButton(
            text: 'Get Started',
            buttonColor: context.themeColors.buttonColor2,
            shadowColor: context.themeColors.buttonBorderColor2,
            foregroundColor: Colors.white,
            borderRadius: 29.r,
            trailingIcon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            onPressed: onGetStarted,
          )
              .animate()
              .fadeIn(delay: 280.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 280.ms, duration: 400.ms, curve: Curves.easeOut),

          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}

// ── State 2: Spin ─────────────────────────────────────────────────────────────

class _SpinBody extends StatelessWidget {
  const _SpinBody({
    required this.isSpinning,
    required this.spinsRemaining,
    required this.currentAngle,
    required this.onSpin,
    this.rotation,
  });

  final bool isSpinning;
  final int spinsRemaining;
  final double currentAngle;
  final Animation<double>? rotation;
  final VoidCallback onSpin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
      child: Column(
        children: [
          SizedBox(height: AppSize.h8),

          // Coin balance badge — centered
          Center(
            child: StreamBuilder<dynamic>(
              stream: Injector.instance<AppDB>().userListenable(),
              builder: (context, _) {
                final balance =
                    Injector.instance<AppDB>().userModel?.coin.toInt() ?? 0;
                return _CoinBadge(amount: balance);
              },
            ),
          ),

          SizedBox(height: AppSize.h16),

          // Headline
          Text(
            'Earn Coins Easily by\nSpinning Wheel',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C2359),
              height: 1.3,
            ),
          ),

          SizedBox(height: AppSize.h20),

          // Wheel — Expanded so it fills available space (matches Figma large wheel)
          Expanded(
            child: AnimatedBuilder(
              animation: rotation ?? const AlwaysStoppedAnimation(0),
              builder: (_, _) => _WheelComposite(
                angle: (isSpinning && rotation != null)
                    ? rotation!.value
                    : currentAngle,
              ),
            ),
          ),

          SizedBox(height: AppSize.h20),

          // Spin / Spinning button — stays pink while spinning (guard is in _onSpin)
          AppButton(
            text: isSpinning ? 'Spinning...' : 'Spin Now',
            buttonColor: context.themeColors.buttonColor2,
            shadowColor: spinsRemaining <= 0 ? null : context.themeColors.buttonBorderColor2,
            foregroundColor: Colors.white,
            isDisabled: spinsRemaining <= 0,
            borderRadius: 29.r,
            onPressed: onSpin,
          ),

          SizedBox(height: AppSize.h24),
        ],
      ),
    );
  }
}

// ── Wheel composite ───────────────────────────────────────────────────────────
//
// Ring layers (outside → in):
//   1. Thin gradient STROKE ring  (strokeWidth ≈ 3.5 % of wheel size)
//   2. Page-bg gap                (≈ 2 % — shows through between rings)
//   3. Dark navy filled circle    (≈ 87 % of total size)
//   4. White filled circle        (≈ 79 % — creates the thin white gap)
//   5. Rotating segments          (≈ 78 %)
//   6. Fixed pointer triangle     (sits just inside gradient ring at 12 o'clock)

class _WheelComposite extends StatelessWidget {
  const _WheelComposite({required this.angle});
  final double angle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(0.0, constraints.maxHeight);
        final strokeW = size * 0.038;

        // Center keeps the square wheel centred when Expanded gives a taller box,
        // preventing the pointer from drifting above the ring area.
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Thin gradient stroke ring
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: GradientRingPainter(strokeWidth: strokeW),
                  ),
                ),

                // 2. Navy filled circle — creates the dark ring band
                Container(
                  width: size * 0.87,
                  height: size * 0.87,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1C2359),
                  ),
                ),

                // 3. White fill — thin white gap inside the navy ring
                Container(
                  width: size * 0.79,
                  height: size * 0.79,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),

                // 4. Rotating segments
                SpinWheelWidget(
                  angle: angle,
                  size: size * 0.78,
                ),

                // 5. Fixed pointer — top of the square SizedBox = top of the ring
                Positioned(
                  top: size * 0.03,
                  child: CustomPaint(
                    size: Size(22.r, 26.r),
                    painter: const PointerTrianglePainter(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Spins left badge ─────────────────────────────────────────────────────────

class _SpinsLeftBadge extends StatelessWidget {
  const _SpinsLeftBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E8),
        borderRadius: BorderRadius.circular(AppSize.r100),
        border: Border.all(
          color: const Color(0xFFE0006E).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE0006E),
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: AppSize.sp16)),
          SizedBox(width: AppSize.w6),
          Text(
            '$count Spins Left Today',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE0006E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coin balance badge ────────────────────────────────────────────────────────

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w14, vertical: AppSize.h8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D6),
        borderRadius: BorderRadius.circular(AppSize.r100),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC97A00),
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.icCoin.svg(width: 20.r, height: 20.r),
          SizedBox(width: AppSize.w6),
          Text(
            '$amount',
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7A4800),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info cards (3-D solid shadow style) ──────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w16, vertical: AppSize.h14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r16),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFA4ABC6),
            blurRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7B8099),
            ),
          ),
          SizedBox(height: AppSize.h4),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C2359),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result bottom sheet ───────────────────────────────────────────────────────
//
// Figma floating-trophy layout:
//   ┌─────────────────────────────────┐  ← transparent spacer (= trophy half-height)
//   │   [modal barrier shows through] │    trophy's upper half is here
//   ├──────────┬──────────────────────┤  ← white sheet top edge
//   │          │  ○ trophy (floats)   │
//   │  handle  │                      │
//   │  title   │                      │
//   │  subtitle│                      │
//   │ [Claim]  │                      │
//   └──────────┴──────────────────────┘

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.coins,
    required this.label,
    required this.isLoss,
    required this.isXp,
    required this.onClaim,
  });

  final int coins;
  final String label;
  final bool isLoss;
  final bool isXp;
  final VoidCallback onClaim;

  // Trophy circle diameter; half used for the spacer / negative top offset.
  static const double _trophyD = 104.0;

  String get _title => isLoss ? 'Oops!' : 'Congratulations..!';

  String get _subtitle {
    if (isLoss) return 'Better luck next time!';
    if (isXp) return 'You earned +XP Bonus!';
    return 'You won $coins Coins';
  }

  @override
  Widget build(BuildContext context) {
    final half = (_trophyD / 2).r;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Outer Padding gives left / right / bottom margins so the card floats
    // above the screen edges — matching the Figma inset card look.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.w16,
        0,
        AppSize.w16,
        (bottomPad > 0 ? bottomPad : AppSize.h16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transparent gap — modal barrier shows here so the trophy looks
          // like it's floating above the white card edge.
          SizedBox(height: half),

          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ── White card — fully rounded on all corners ───────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.r28),
                ),
                padding: EdgeInsets.fromLTRB(
                  AppSize.w24,
                  half + AppSize.h16, // clears trophy lower half
                  AppSize.w24,
                  AppSize.h28,
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: AppSize.w40,
                    height: AppSize.h4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE2F0),
                      borderRadius: BorderRadius.circular(AppSize.r100),
                    ),
                  ),

                  SizedBox(height: AppSize.h20),

                  // Title
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1C2359),
                    ),
                  ),

                  SizedBox(height: AppSize.h8),

                  // Subtitle
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A4E6B),
                    ),
                  ),

                  SizedBox(height: AppSize.h28),

                  // Claim / Try Again button
                  AppButton(
                    text: isLoss ? 'Try Again' : 'Claim Now',
                    buttonColor: const Color(0xFF1A1AE8),
                    shadowColor: const Color(0xFF0E0F66),
                    foregroundColor: Colors.white,
                    borderRadius: 29.r,
                    onPressed: onClaim,
                  ),
                ],
              ),
            ),

            // ── Floating trophy — straddles the sheet's top edge ────────
            Positioned(
              top: -half,
              child: Container(
                width: _trophyD.r,
                height: _trophyD.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEEF1FF),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1AE8).withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(AppSize.w14),
                child: Assets.images.trophy.image(fit: BoxFit.contain),
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
    ),   // Column
    );   // Padding
  }
}
