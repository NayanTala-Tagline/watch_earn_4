import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../gen/fonts.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import 'provider/locale_provider.dart';

class _Language {
  const _Language(this.name, this.code, this.flag);
  final String name;
  final String code;
  final String flag;
}

const _languages = [
  _Language('English', 'en', '🇺🇸'),
  _Language('Spanish', 'es', '🇪🇸'),
  _Language('German', 'de', '🇩🇪'),
  _Language('French', 'fr', '🇫🇷'),
  _Language('Arabic', 'ar', '🇸🇦'),
  _Language('Hindi', 'hi', '🇮🇳'),
  _Language('Malay', 'ms', '🇲🇾'),
  _Language('Filipino', 'fil', '🇵🇭'),
  _Language('Dutch', 'nl', '🇳🇱'),
  _Language('Swahili', 'sw', '🇹🇿'),
];

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    final saved = context.read<LocaleProvider>().locale?.languageCode ?? '';
    _selectedCode = saved.isNotEmpty ? saved : 'en';
  }

  void _onSelect(String code) => setState(() => _selectedCode = code);

  void _onGetStarted() {
    context.read<LocaleProvider>().setLocale(_selectedCode);
    context.goNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEEFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSize.h24),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                'Set Default Language',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2359),
                  height: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                  .slideX(begin: -0.08, end: 0, duration: 400.ms, curve: Curves.easeOut),
            ),

            SizedBox(height: AppSize.h10),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: Text(
                'Selected language will use as default language for this app which you can change later if you want to.',
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4A4E6B),
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
            ),

            SizedBox(height: AppSize.h20),

            // Language list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                itemCount: _languages.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSize.h12),
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  return _LanguageTile(
                    language: lang,
                    isSelected: lang.code == _selectedCode,
                    onTap: () => _onSelect(lang.code),
                    animationDelay: (index * 50).ms,
                  );
                },
              ),
            ),

            SizedBox(height: AppSize.h16),

            // Get Started button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
              child: AppButton(
                text: 'Get Started',
                buttonColor: const Color(0xFF1A1AE8),
                shadowColor: const Color(0xFF0E0F66),
                foregroundColor: Colors.white,
                trailingIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                borderRadius: 29.r,
                onPressed: _onGetStarted,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOut),
            ),

            SizedBox(height: AppSize.h16),

            // AD placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.w16),
              child: Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(AppSize.r12),
                  border: Border.all(color: const Color(0xFFEED0CC), width: 1),
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
            ),

            SizedBox(height: AppSize.h16),
          ],
        ),
      ),
    );
  }
}

// ── 3-D language tile ─────────────────────────────────────────────────────────

class _LanguageTile extends StatefulWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile>
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

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    final surfaceColor = isSelected ? const Color(0xFF1A1AE8) : Colors.white;
    final wallColor =
        isSelected ? const Color(0xFF0E0F66) : const Color(0xFFA4ABC6);
    final borderColor =
        isSelected ? const Color(0xFF1A1AE8) : const Color(0xFFCDD0DE);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) {
          final p = _anim.value;
          final currentWall = (1 - p) * _wallH;
          final shiftY = p * _wallH;

          return Transform.translate(
            offset: Offset(0, shiftY),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(29.r),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: wallColor,
                    blurRadius: 0,
                    offset: Offset(0, currentWall),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            Text(
              widget.language.flag,
              style: TextStyle(fontSize: AppSize.sp22),
            ),
            SizedBox(width: AppSize.w12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: FontFamily.kommonGrotesk,
                  fontSize: AppSize.sp16,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected ? Colors.white : const Color(0xFF1C2359),
                ),
                child: Text(widget.language.name),
              ),
            ),
            // Check / empty circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26.r,
              height: 26.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.white
                      : const Color(0xFFCDD0DE),
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16.r,
                      color: const Color(0xFF1A1AE8),
                    )
                  : null,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: widget.animationDelay,
          duration: 350.ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.06,
          end: 0,
          delay: widget.animationDelay,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}
