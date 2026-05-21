import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import '../../gen/fonts.gen.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/app_button.dart';

// ── Constants ────────────────────────────────────────────────────────────────

const _kTotalQuestions = 6;
const _kSecondsPerQuestion = 30;
const _kLetters = ['A', 'B', 'C', 'D'];

// ── Question model ────────────────────────────────────────────────────────────

class _Question {
  const _Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
}

// ── Question generators (ported from clip_earn reference) ────────────────────

typedef _Gen = _Question Function(Random rng);

_Question _build(
  Random rng,
  String text,
  String correct,
  List<String> wrongs,
) {
  final opts = [correct, ...wrongs]..shuffle(rng);
  return _Question(
    question: text,
    options: opts,
    correctIndex: opts.indexOf(correct),
  );
}

_Question _genMultiply(Random rng) {
  final a = 11 + rng.nextInt(19);
  final b = 11 + rng.nextInt(9);
  final c = a * b;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(21) - 10;
    if (off != 0) w.add('${c + off}');
  }
  return _build(rng, 'What is $a × $b?', '$c', w.toList());
}

_Question _genSolveAdd(Random rng) {
  final x = 10 + rng.nextInt(41);
  final a = 10 + rng.nextInt(31);
  final b = x + a;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(11) - 5;
    if (off != 0) w.add('${x + off}');
  }
  return _build(rng, 'If x + $a = $b, what is x?', '$x', w.toList());
}

_Question _genDivide(Random rng) {
  final d = 6 + rng.nextInt(7);
  final q = 8 + rng.nextInt(13);
  final n = d * q;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(7) - 3;
    if (off != 0) w.add('${q + off}');
  }
  return _build(rng, 'What is $n ÷ $d?', '$q', w.toList());
}

_Question _genPercent(Random rng) {
  final pct = [15, 20, 25, 30, 35, 40][rng.nextInt(6)];
  final whole = (4 + rng.nextInt(7)) * 20;
  final c = (pct * whole) ~/ 100;
  final w = <String>{};
  while (w.length < 3) {
    final off = (rng.nextInt(21) - 10);
    if (off != 0 && c + off > 0) w.add('${c + off}');
  }
  return _build(rng, 'What is $pct% of $whole?', '$c', w.toList());
}

_Question _genSqrt(Random rng) {
  final root = 7 + rng.nextInt(12);
  final sq = root * root;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(5) - 2;
    if (off != 0) w.add('${root + off}');
  }
  return _build(rng, 'What is the square root of $sq?', '$root', w.toList());
}

_Question _genOrderOps(Random rng) {
  final a = 3 + rng.nextInt(6);
  final b = 4 + rng.nextInt(7);
  final c = 5 + rng.nextInt(16);
  final d = 2 + rng.nextInt(9);
  final res = a * b - c + d;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(11) - 5;
    if (off != 0) w.add('${res + off}');
  }
  return _build(rng, 'Solve: $a × $b - $c + $d = ?', '$res', w.toList());
}

_Question _genFraction(Random rng) {
  final fracs = [(2, 3), (3, 4), (2, 5), (3, 5), (4, 5)];
  final f = fracs[rng.nextInt(fracs.length)];
  final m = 3 + rng.nextInt(8);
  final whole = f.$2 * m * 10;
  final c = (f.$1 * whole) ~/ f.$2;
  final w = <String>{};
  while (w.length < 3) {
    final off = (rng.nextInt(21) - 10) * 5;
    if (off != 0 && c + off > 0) w.add('${c + off}');
  }
  return _build(rng, 'What is ${f.$1}/${f.$2} of $whole?', '$c', w.toList());
}

_Question _genSolveMul(Random rng) {
  final y = 5 + rng.nextInt(36);
  final a = 3 + rng.nextInt(8);
  final b = a * y;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(11) - 5;
    if (off != 0) w.add('${y + off}');
  }
  return _build(rng, 'If ${a}y = $b, what is y?', '$y', w.toList());
}

_Question _genSquareMinus(Random rng) {
  final a = 12 + rng.nextInt(13);
  final c = 50 + rng.nextInt(151);
  final res = a * a - c;
  final w = <String>{};
  while (w.length < 3) {
    final off = rng.nextInt(21) - 10;
    if (off != 0) w.add('${res + off}');
  }
  return _build(rng, 'What is $a² - $c?', '$res', w.toList());
}

_Question _genDecimal(Random rng) {
  final aInt = 15 + rng.nextInt(76);
  final bInt = 10 + rng.nextInt(81);
  final cInt = aInt * bInt;
  String fmt(int v) {
    var s = (v / 10000).toStringAsFixed(4);
    s = s.replaceAll(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s += '0';
    return s;
  }

  final cStr = fmt(cInt);
  final aStr = (aInt / 100).toStringAsFixed(2);
  final bStr = (bInt / 100).toStringAsFixed(2);
  final w = <String>{};
  while (w.length < 3) {
    final off = (rng.nextInt(11) - 5) * 100;
    if (off != 0) {
      final ws = fmt(cInt + off);
      if (ws != cStr) w.add(ws);
    }
  }
  return _build(rng, 'What is $aStr × $bStr?', cStr, w.toList());
}

final _generators = <_Gen>[
  _genMultiply, _genSolveAdd, _genDivide, _genPercent, _genSqrt,
  _genOrderOps, _genFraction, _genSolveMul, _genSquareMinus, _genDecimal,
];

List<_Question> _generateQuestions() {
  final rng = Random();
  return (List<_Gen>.from(_generators)..shuffle(rng))
      .take(_kTotalQuestions)
      .map((g) => g(rng))
      .toList();
}

int get _coinsPerCorrect => RemoteConfigService.instance.quizPerQuestionReward;

// ── Main screen ───────────────────────────────────────────────────────────────

class QuizMasterScreen extends StatefulWidget {
  const QuizMasterScreen({super.key});

  @override
  State<QuizMasterScreen> createState() => _QuizMasterScreenState();
}

class _QuizMasterScreenState extends State<QuizMasterScreen> {
  late final List<_Question> _questions = _generateQuestions();

  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;

  // Per-question countdown
  int _secondsLeft = _kSecondsPerQuestion;
  Timer? _timer;

  // History of last 5 answers (true = correct, false = wrong/skipped)
  final List<bool> _history = [];

  _Question get _current => _questions[_currentIndex];

  int get _currentStreak {
    var streak = 0;
    for (var i = _history.length - 1; i >= 0; i--) {
      if (_history[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _kSecondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        if (!_answered) _onTimerExpired();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onTimerExpired() {
    _history.add(false);
    setState(() {
      _answered = true;
      _selectedOption = null;
    });
    Future.delayed(const Duration(milliseconds: 900), _advance);
  }

  void _onOptionTap(int index) {
    if (_answered) return;
    _timer?.cancel();
    final isCorrect = index == _current.correctIndex;
    _history.add(isCorrect);
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (isCorrect) _correctCount++;
    });
    Future.delayed(const Duration(milliseconds: 800), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _showResultSheet();
    }
  }

  void _showResultSheet() {
    final totalCoins = _correctCount * _coinsPerCorrect;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetCtx) => _ResultSheet(
        correctCount: _correctCount,
        totalQuestions: _questions.length,
        totalCoins: totalCoins,
        onClaim: () {
          Navigator.pop(sheetCtx);
          NavigationHelper().handleBackPress(context);
        },
      ),
    );
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s left';
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
              // AppBar
              _QuizAppBar(
                onBack: () => NavigationHelper().handleBackPress(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSize.h16),

                      // Progress header
                      _ProgressHeader(
                        current: _currentIndex + 1,
                        total: _questions.length,
                        coinsPerCorrect: _coinsPerCorrect,
                      ),

                      SizedBox(height: AppSize.h20),

                      // Question card
                      _QuestionCard(
                        question: _current.question,
                        timerText: _timerText,
                        secondsLeft: _secondsLeft,
                        totalSeconds: _kSecondsPerQuestion,
                      ),

                      SizedBox(height: AppSize.h20),

                      // Option tiles
                      ..._current.options.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(bottom: AppSize.h12),
                            child: _QuizOptionTile(
                              index: e.key,
                              text: e.value,
                              selectedIndex: _selectedOption,
                              answeredCorrectIndex:
                                  _answered ? _current.correctIndex : null,
                              onTap: () => _onOptionTap(e.key),
                            ),
                          )),

                      SizedBox(height: AppSize.h16),

                      // Streak indicator
                      _StreakRow(
                        history: _history,
                        streak: _currentStreak,
                      ),

                      SizedBox(height: AppSize.h20),

                      // AD placeholder
                      Container(
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(AppSize.r16),
                          border: Border.all(
                            color: const Color(0xFFEED0CC),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'AD',
                          style: TextStyle(
                            fontFamily: FontFamily.kommonGrotesk,
                            fontSize: AppSize.sp14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD060A0),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSize.h24),
                    ],
                  ),
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

class _QuizAppBar extends StatelessWidget {
  const _QuizAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: AppSize.w20, vertical: AppSize.h10),
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
            'Quiz Master',
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

// ── Progress header ───────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.coinsPerCorrect,
  });

  final int current;
  final int total;
  final int coinsPerCorrect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$current of $total',
              style: TextStyle(
                fontFamily: FontFamily.kommonGrotesk,
                fontSize: AppSize.sp16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C2359),
              ),
            ),
            const Spacer(),
            // "+N per correct" coin badge
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w12, vertical: AppSize.h8),
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
                  Assets.icons.icCoin.svg(width: 16.r, height: 16.r),
                  SizedBox(width: AppSize.w4),
                  Text(
                    '+$coinsPerCorrect per correct',
                    style: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC97A00),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.h10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSize.r100),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 7.h,
            backgroundColor: const Color(0xFFDDE2F0),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF1A1AE8)),
          ),
        ),
      ],
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.timerText,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  final String question;
  final String timerText;
  final int secondsLeft;
  final int totalSeconds;

  Color get _timerColor {
    if (secondsLeft <= 10) return const Color(0xFFEF4444);
    if (secondsLeft <= 20) return const Color(0xFFFFB300);
    return const Color(0xFF9AA0B5);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.w20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.r20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140E0F66),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C2359),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSize.h14),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: _timerColor,
                size: 18.r,
              ),
              SizedBox(width: AppSize.w6),
              Text(
                timerText,
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w500,
                  color: _timerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 3-D option tile ───────────────────────────────────────────────────────────

class _QuizOptionTile extends StatefulWidget {
  const _QuizOptionTile({
    required this.index,
    required this.text,
    required this.selectedIndex,
    required this.answeredCorrectIndex,
    required this.onTap,
  });

  final int index;
  final String text;
  final int? selectedIndex;

  /// Non-null after the user has answered; value = the correct option index.
  final int? answeredCorrectIndex;
  final VoidCallback onTap;

  bool get _isSelected => selectedIndex == index;
  bool get _isAnswered => answeredCorrectIndex != null;
  bool get _isCorrect => answeredCorrectIndex == index;
  bool get _isWrong => _isSelected && _isAnswered && !_isCorrect;

  @override
  State<_QuizOptionTile> createState() => _QuizOptionTileState();
}

class _QuizOptionTileState extends State<_QuizOptionTile>
    with SingleTickerProviderStateMixin {
  static const _wallH = 5.0;

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget._isAnswered) return;
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    if (!widget._isAnswered) widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  // ── Color helpers ─────────────────────────────────────────────────────────

  Color get _surface {
    if (widget._isCorrect) return const Color(0xFF22C55E);
    if (widget._isWrong) return const Color(0xFFEF4444);
    if (widget._isSelected) return const Color(0xFF1A1AE8);
    return Colors.white;
  }

  Color get _wall {
    if (widget._isCorrect) return const Color(0xFF166534);
    if (widget._isWrong) return const Color(0xFF991B1B);
    if (widget._isSelected) return const Color(0xFF0E0F66);
    return const Color(0xFFA4ABC6);
  }

  Color get _badgeColor {
    if (widget._isCorrect) return const Color(0xFF166534);
    if (widget._isWrong) return const Color(0xFF991B1B);
    if (widget._isSelected) return const Color(0xFF0E0F66);
    return const Color(0xFFDDE2F0);
  }

  Color get _badgeTextColor {
    if (widget._isSelected || widget._isCorrect || widget._isWrong) {
      return Colors.white;
    }
    return const Color(0xFF4A4E6B);
  }

  Color get _textColor {
    if (widget._isSelected || widget._isCorrect || widget._isWrong) {
      return Colors.white;
    }
    return const Color(0xFF1C2359);
  }

  Widget? get _radioContent {
    if (widget._isCorrect) {
      return Icon(Icons.check_rounded, size: 15.r,
          color: const Color(0xFF22C55E));
    }
    if (widget._isWrong) {
      return Icon(Icons.close_rounded, size: 15.r,
          color: const Color(0xFFEF4444));
    }
    if (widget._isSelected) {
      return Icon(Icons.check_rounded, size: 15.r,
          color: const Color(0xFF1A1AE8));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) {
          final p = widget._isAnswered ? 0.0 : _anim.value;
          final wall = (1 - p) * _wallH;
          final shift = p * _wallH;

          return Transform.translate(
            offset: Offset(0, shift),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(29.r),
                border: Border.all(
                  color: widget._isAnswered
                      ? _surface
                      : const Color(0xFFCDD0DE),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _wall,
                    blurRadius: 0,
                    offset: Offset(0, wall),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: _badgeColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp14,
                    fontWeight: FontWeight.w700,
                    color: _badgeTextColor,
                  ),
                  child: Text(_kLetters[widget.index]),
                ),
              ),
            ),

            SizedBox(width: AppSize.w12),

            // Option text
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp15,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
                child: Text(widget.text),
              ),
            ),

            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26.r,
              height: 26.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget._isSelected || widget._isCorrect || widget._isWrong)
                    ? Colors.white
                    : Colors.transparent,
                border: Border.all(
                  color: (widget._isSelected || widget._isCorrect || widget._isWrong)
                      ? Colors.white
                      : const Color(0xFFCDD0DE),
                  width: 2,
                ),
              ),
              child: _radioContent,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak row ────────────────────────────────────────────────────────────────

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.history, required this.streak});

  final List<bool> history;
  final int streak;

  @override
  Widget build(BuildContext context) {
    // Show last 5 answers (pad with nulls if fewer than 5 answered)
    const dots = 5;
    final visible = history.length > dots
        ? history.sublist(history.length - dots)
        : history;
    final padded = [
      ...visible,
      ...List<bool?>.filled(dots - visible.length, null),
    ];

    return Row(
      children: [
        ...padded.asMap().entries.map((e) {
          final result = e.value;
          final isCorrect = result == true;
          final hasAnswer = result != null;

          return Padding(
            padding: EdgeInsets.only(right: AppSize.w6),
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect
                    ? const Color(0xFFFFB300)
                    : const Color(0xFFE8EAF0),
                boxShadow: isCorrect
                    ? const [
                        BoxShadow(
                          color: Color(0xFFC97A00),
                          blurRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: hasAnswer
                  ? Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      size: 16.r,
                      color: isCorrect ? Colors.white : const Color(0xFF9AA0B5),
                    )
                  : null,
            )
                .animate(key: ValueKey('dot_${e.key}_${e.value}'))
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 250.ms),
          );
        }),

        SizedBox(width: AppSize.w8),

        Text(
          '$streak in a row',
          style: TextStyle(
            fontFamily: FontFamily.kommonGrotesk,
            fontSize: AppSize.sp13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9AA0B5),
          ),
        ),
      ],
    );
  }
}

// ── Result bottom sheet ───────────────────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.correctCount,
    required this.totalQuestions,
    required this.totalCoins,
    required this.onClaim,
  });

  final int correctCount;
  final int totalQuestions;
  final int totalCoins;
  final VoidCallback onClaim;

  static const double _trophyD = 104.0;

  bool get _isLoss => correctCount == 0;

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
                  color: Colors.white,
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
                      _isLoss ? 'Oops!' : 'Congratulations..!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C2359),
                      ),
                    ),

                    SizedBox(height: AppSize.h8),

                    Text(
                      _isLoss
                          ? 'Better luck next time!'
                          : 'You scored $correctCount/$totalQuestions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.kommonGrotesk,
                        fontSize: AppSize.sp16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A4E6B),
                      ),
                    ),

                    if (!_isLoss) ...[
                      SizedBox(height: AppSize.h4),
                      Text(
                        'You won $totalCoins Coins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontFamily.kommonGrotesk,
                          fontSize: AppSize.sp15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ],

                    SizedBox(height: AppSize.h28),

                    AppButton(
                      text: _isLoss ? 'Try Again' : 'Claim Now',
                      buttonColor: const Color(0xFF1A1AE8),
                      shadowColor: const Color(0xFF0E0F66),
                      foregroundColor: Colors.white,
                      borderRadius: 29.r,
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
      ),
    );
  }
}
