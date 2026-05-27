import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../extension/ext_context.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/app_size.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';
import 'provider/locale_provider.dart';

/// Passed via GoRouter [extra] when navigating from onboarding page 3.
/// Carries pre-loaded native ads so the language screen shows them immediately.
class LanguageScreenArgs {
  const LanguageScreenArgs({this.nativeAd1, this.nativeAd2});
  final NativeAdManager? nativeAd1;
  final NativeAdManager? nativeAd2;
}

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
  /// [fromSettings] true  → navigated from profile/settings (show back, save & pop)
  /// [fromSettings] false → navigated from onboarding (show Get Started, push to login)
  const LanguageScreen({
    super.key,
    this.fromSettings = false,
    this.nativeAd1,
    this.nativeAd2,
  });

  final bool fromSettings;
  final NativeAdManager? nativeAd1;
  final NativeAdManager? nativeAd2;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;
  // Flips to true on the first language tap this session; drives the ad swap.
  bool _hasSelectedOnce = false;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'language',
      screenClass: 'LanguageScreen',
    );
    final saved = context.read<LocaleProvider>().locale?.languageCode ?? '';
    _selectedCode = saved.isNotEmpty ? saved : 'en';

    // Rebuild when either pre-loaded ad finishes so the bar shows immediately.
    widget.nativeAd1?.future().then((_) { if (mounted) setState(() {}); });
    widget.nativeAd2?.future().then((_) { if (mounted) setState(() {}); });
  }

  void _onSelect(String code) {
    setState(() {
      _selectedCode = code;
      _hasSelectedOnce = true;
    });
  }

  void _onConfirm() {
    context.read<LocaleProvider>().setLocale(_selectedCode);
    if (widget.fromSettings) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.country);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromSettings = widget.fromSettings;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        NavigationHelper().handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: context.themeColors.backgroundColor,
        appBar: fromSettings ? CommonAppBar(titleText: context.l10n.language) : null,
        bottomNavigationBar: fromSettings
            ? null
            : _NativeAdBar(
                key: ValueKey(_hasSelectedOnce ? 'ad2' : 'ad1'),
                ad: _hasSelectedOnce ? widget.nativeAd2 : widget.nativeAd1,
              ),
        body: SafeArea(
          top: !fromSettings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!fromSettings) ...[
                SizedBox(height: AppSize.h24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: Text(
                    context.l10n.setDefaultLanguage,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: AppSize.sp28,
                      color: context.themeColors.navyColor,
                      height: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .slideX(
                        begin: -0.08,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                ),
                SizedBox(height: AppSize.h10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: Text(
                    context.l10n.setDefaultLanguageDesc,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.themeTextColors.subtitleColor,
                      height: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
                ),
                SizedBox(height: AppSize.h20),
              ] else
                SizedBox(height: AppSize.h8),

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.w24,
                    vertical: AppSize.h12,
                  ),
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                child: AppButton(
                  text: fromSettings ? context.l10n.save : context.l10n.getStarted,
                  buttonColor: context.themeColors.buttonColor,
                  shadowColor: context.themeColors.buttonBorderColor,
                  foregroundColor: context.themeColors.whiteColor,
                  trailingIcon: Icon(
                    fromSettings
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    color: context.themeColors.whiteColor,
                    size: 20,
                  ),
                  borderRadius: AppSize.r29,
                  onPressed: _onConfirm,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 200.ms,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              ),

              SizedBox(height: AppSize.h16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom native ad bar ──────────────────────────────────────────────────────

class _NativeAdBar extends StatelessWidget {
  const _NativeAdBar({super.key, this.ad});

  final NativeAdManager? ad;

  @override
  Widget build(BuildContext context) {
    if (ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: _AdSlot(ad: ad!),
    );
  }
}

class _AdSlot extends StatelessWidget {
  const _AdSlot({required this.ad});

  final NativeAdManager ad;

  @override
  Widget build(BuildContext context) {
    if (!ad.adData.enabled && ad.adData.adType != AdType.custom) {
      return const SizedBox.shrink();
    }

    final isCustom = ad.adData.adType == AdType.custom;
    final placeholderHeight =
        ad.adData.templateType == TemplateType.medium ? AppSize.h360 : AppSize.h100;

    return Padding(
      padding: EdgeInsets.only(top: AppSize.h5),
      child: Container(
        color: context.theme.cardColor,
        child: isCustom
            ? ad.adWidget()
            : ad.isLoaded
                ? SizedBox(height: placeholderHeight, child: ad.adWidget())
                : ad.isFailed
                    ? const SizedBox.shrink()
                    : Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: placeholderHeight,
                          color: context.theme.cardColor,
                        ),
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

    final surfaceColor = isSelected
        ? context.themeColors.buttonColor
        : context.themeColors.whiteColor;
    final wallColor = isSelected
        ? context.themeColors.buttonBorderColor
        : context.themeColors.borderColor;
    final borderColor = isSelected
        ? context.themeColors.buttonColor
        : context.themeColors.dragHandleColor;

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
              height: AppSize.h56,
              padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSize.r29),
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
                style: (context.textTheme.titleSmall ?? const TextStyle())
                    .copyWith(
                  fontSize: AppSize.sp16,
                  color: widget.isSelected
                      ? context.themeColors.whiteColor
                      : context.themeColors.navyColor,
                ),
                child: Text(widget.language.name),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppSize.r26,
              height: AppSize.r26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected
                    ? context.themeColors.whiteColor
                    : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected
                      ? context.themeColors.whiteColor
                      : context.themeColors.dragHandleColor,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: AppSize.r16,
                      color: context.themeColors.buttonColor,
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
