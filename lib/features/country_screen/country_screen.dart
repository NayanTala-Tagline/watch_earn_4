import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../extension/ext_context.dart';
import '../../extension/ext_string_alert.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';

class _Country {
  const _Country(this.name, this.flag);
  final String name;
  final String flag;
}

const _countries = [
  _Country('India', '🇮🇳'),
  _Country('Canada', '🇨🇦'),
  _Country('Germany', '🇩🇪'),
  _Country('UK', '🇬🇧'),
  _Country('America', '🇺🇸'),
  _Country('China', '🇨🇳'),
  _Country('France', '🇫🇷'),
  _Country('Japan', '🇯🇵'),
  _Country('Brazil', '🇧🇷'),
  _Country('Australia', '🇦🇺'),
];

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  String? _selectedName;
  InlineAdManager? _nativeAd;

  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'country',
      screenClass: 'CountryScreen',
    );
    _loadAd();
  }

  Future<void> _loadAd() async {
    _nativeAd = InlineAdManager(
      adData: RemoteConfigService.instance.countryNative,
    );
    await _nativeAd!.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _onSelect(String name) => setState(() => _selectedName = name);

  void _onConfirm() {
    if (_selectedName == null) {
      'Please select a country'.showInfoAlert();
      return;
    }
    context.goNamed(AppRoutes.gameSelect);
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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSize.h24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Which Country do you like?',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: AppSize.sp28,
                          color: context.themeColors.navyColor,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
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
                  ],
                ),
                SizedBox(height: AppSize.h10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Select your fav countries which are you like.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.themeTextColors.subtitleColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 400.ms, curve: Curves.easeOut),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: context.themeColors.primary),
                    ),
                    SizedBox(width: AppSize.w8),
                    Text(
                      'Available Country',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: AppSize.sp13,
                        color: context.themeColors.navyColor,
                      ),
                    ),
                    SizedBox(width: AppSize.w8),
                    Expanded(
                      child: Divider(color: context.themeColors.primary),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: AppSize.h10),
                    itemCount: _countries.length,
                    separatorBuilder: (_, _) => SizedBox(height: AppSize.h12),
                    itemBuilder: (context, index) {
                      final c = _countries[index];
                      return _EmojiTile(
                        name: c.name,
                        emoji: c.flag,
                        isSelected: c.name == _selectedName,
                        onTap: () => _onSelect(c.name),
                        animationDelay: (index * 50).ms,
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSize.h16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w24),
                  child: AppButton(
                    text: 'Done',
                    buttonColor: context.themeColors.buttonColor,
                    shadowColor: context.themeColors.buttonBorderColor,
                    foregroundColor: context.themeColors.whiteColor,
                    trailingIcon: Icon(
                      Icons.arrow_forward_rounded,
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
      ),
    );
  }
}

// ── Shared 3-D emoji tile (also used by Currency screen) ─────────────────────

class EmojiTile extends StatelessWidget {
  const EmojiTile({
    super.key,
    required this.name,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  final String name;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    return _EmojiTile(
      name: name,
      emoji: emoji,
      isSelected: isSelected,
      onTap: onTap,
      animationDelay: animationDelay,
    );
  }
}

class _EmojiTile extends StatefulWidget {
  const _EmojiTile({
    required this.name,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  final String name;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<_EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<_EmojiTile>
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
              widget.emoji,
              style: TextStyle(fontSize: AppSize.sp22,color: widget.isSelected
                  ? context.themeColors.whiteColor
                  : context.themeColors.navyColor,),
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
                child: Text(widget.name),
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
