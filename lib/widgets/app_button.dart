import 'dart:async';

import 'package:flutter/material.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// Global app button.
///
/// **3-D filled mode** — activated when [isFillButton] is true AND
/// [shadowColor] is provided. Pass [buttonColor] for the surface and
/// [shadowColor] for the solid bottom-wall that creates the depth illusion.
/// The wall collapses and the button translates down on press for a physical
/// click feel.
///
/// **Flat filled mode** — [isFillButton] true, no [shadowColor]. Renders the
/// brand gradient (or a custom [gradient]).
///
/// **Outlined mode** — set [isFillButton] false (or [isOutlined] true). No
/// 3-D effect regardless of other params.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFillButton = true,
    this.isOutlined = false,
    this.isLoginButton = false,
    this.isAdjust = false,
    this.showIconOnly = false,
    this.icon,
    this.trailingIcon,
    this.buttonColor,
    this.shadowColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.horizontalPad,
    this.verticalPad,
    this.gradient,
    this.backgroundColor,
    this.primary,
    this.buttonStyle,
    this.visualDensity,
    this.wallOffset,
    this.slideShadowColor,
    this.slideShadowOffset,
    this.slideShadowBlur,
    this.slideShadowSpread,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  /// true  → filled button (3-D or gradient)
  /// false → no 3-D effect (outlined)
  final bool isFillButton;
  final bool isOutlined;

  /// Icon rendered before the label (Google sign-in, etc.)
  final Widget? icon;

  /// Icon rendered after the label (e.g. arrow for "Next →")
  final Widget? trailingIcon;

  final bool showIconOnly;
  final bool isLoginButton;
  final bool isAdjust;

  /// Surface colour for the 3-D or flat filled button.
  final Color? buttonColor;

  /// Solid bottom-wall colour. **Providing this enables 3-D mode** (only
  /// when [isFillButton] is true).
  final Color? shadowColor;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? primary;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? horizontalPad;
  final double? verticalPad;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;
  final VisualDensity? visualDensity;

  /// Fixed shadow wall offset for 3-D mode. When null, the wall animates
  /// from 6→0 on press. When provided, the wall stays fixed at this value.
  final double? wallOffset;

  /// Optional drop "slide" shadow rendered behind the button.
  /// When non-null, a soft BoxShadow in this colour is added to the
  /// button decoration.
  final Color? slideShadowColor;

  /// Offset of the slide shadow relative to the button. Defaults to
  /// Offset(0, 6) (a downward drop shadow).
  final Offset? slideShadowOffset;

  /// Blur radius for the slide shadow. Defaults to 12.
  final double? slideShadowBlur;

  /// Spread radius for the slide shadow. Defaults to 0.
  final double? slideShadowSpread;

  bool get _is3D => isFillButton && !isOutlined && shadowColor != null;

  BoxShadow? get slideBoxShadow => slideShadowColor == null
      ? null
      : BoxShadow(
          color: slideShadowColor!,
          offset: slideShadowOffset ?? const Offset(0, 6),
          blurRadius: slideShadowBlur ?? 12,
          spreadRadius: slideShadowSpread ?? 0,
        );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  // ── Debounce ───────────────────────────────────────────────────────────────
  bool _isProcessing = false;
  Timer? _debounceTimer;

  // ── Press animation (3-D mode only) ───────────────────────────────────────
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _pressAnim = CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) {
    if (!_canInteract) return;
    if (widget._is3D) _pressCtrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget._is3D) _pressCtrl.reverse();
    _fire();
  }

  void _onTapCancel() {
    if (widget._is3D) _pressCtrl.reverse();
  }

  void _fire() {
    if (!_canInteract) return;
    _isProcessing = true;
    widget.onPressed?.call();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _isProcessing = false,
    );
  }

  bool get _canInteract =>
      !_isProcessing && !widget.isDisabled && !widget.isLoading;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppSize.r34;
    final inner = widget.isLoading ? _loader() : _content(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      // Non-3D buttons still need onTap for debounce
      onTap: widget._is3D ? null : (widget.isDisabled ? null : _fire),
      child: widget.isAdjust
          ? _adjustLayout(radius, inner)
          : _fullLayout(radius, inner),
    );
  }

  // ── Layout variants ────────────────────────────────────────────────────────

  Widget _adjustLayout(double radius, Widget inner) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: _shell(
          radius: radius,
          height: null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPad ?? AppSize.w12,
            vertical: widget.verticalPad ?? AppSize.h4,
          ),
          inner: inner,
        ),
      ),
    );
  }

  Widget _fullLayout(double radius, Widget inner) {
    if (widget.isOutlined) {
      return Align(
        alignment: Alignment.center,
        child: IntrinsicWidth(
          child: _shell(
            radius: radius,
            height: AppSize.h42,
            padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPad ?? AppSize.w44,
              vertical: widget.verticalPad ?? AppSize.h8,
            ),
            inner: inner,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(AppSize.r5),
      child: _shell(
        radius: radius,
        height: AppSize.h50,
        padding: EdgeInsets.zero,
        inner: inner,
      ),
    );
  }

  // ── Shell (decoration) ─────────────────────────────────────────────────────

  Widget _shell({
    required double radius,
    required double? height,
    required EdgeInsetsGeometry padding,
    required Widget inner,
  }) {
    final slide = widget.slideBoxShadow;

    // ── Outlined ─────────────────────────────────────────────────────────
    if (widget.isOutlined || !widget.isFillButton) {
      return Container(
        height: height,
        width: height != null ? double.infinity : null,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            width: widget.borderWidth ?? 1.3,
            color: widget.borderColor ?? context.themeColors.borderColor,
          ),
          boxShadow: [?slide],
        ),
        child: inner,
      );
    }

    // ── 3-D filled ────────────────────────────────────────────────────────
    if (widget._is3D || widget.isDisabled) {
      final baseWall = widget.wallOffset ?? 6.0;

      // When disabled, the shadow wall is slightly faded because it sits
      // outside the ClipRRect overlay and would otherwise look too prominent
      // against the lighter-looking (overlaid) button surface.
      final shadowC = widget.isDisabled
          ? (widget.shadowColor ?? Colors.transparent).withValues(alpha: 0.5)
          : (widget.shadowColor ?? Colors.transparent);

      final button = AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) {
          final p = _pressAnim.value;
          final wallH = (1 - p) * baseWall;
          final shiftY = p * baseWall;

          return Transform.translate(
            offset: Offset(0, shiftY),
            child: Container(
              height: height,
              width: height != null ? double.infinity : null,
              padding: padding,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.buttonColor,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: shadowC,
                    offset: Offset(0, wallH),
                    blurRadius: 0,
                  ),
                  ?slide,
                ],
              ),
              child: child,
            ),
          );
        },
        child: inner,
      );

      // Disabled: stack a semi-transparent white overlay on the full-colour
      // button. White on white text keeps text readable; surface becomes
      // visually lighter — matches the Figma 50 % opacity treatment.
      if (widget.isDisabled) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              button,
              Positioned.fill(
                child: Container(
                  color: context.themeColors.whiteColor.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      }

      return button;
    }

    // ── Flat gradient filled (default) ─────────────────────────────────────
    return Container(
      height: height,
      width: height != null ? double.infinity : null,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.themeColors.secondary2,
            blurRadius: AppSize.r16,
            spreadRadius: AppSize.sp2,
          ),
          ?slide,
        ],
        gradient: widget.gradient ??
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.themeColors.buttonColor.withValues(alpha: 0.1),
                context.themeColors.buttonColor2.withValues(alpha: 0.2),
              ],
            ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          width: 2,
          color: widget.borderColor ??
              context.themeColors.buttonColor.withValues(alpha: 0.55),
        ),
      ),
      child: inner,
    );
  }

  // ── Inner content ──────────────────────────────────────────────────────────

  Widget _loader() {
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSize.h2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(
              widget.foregroundColor ?? context.themeTextColors.textColor,
            ),
            strokeWidth: 2,
            padding: EdgeInsets.all(AppSize.w14),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    // Text colour is never faded directly — the white overlay in _shell
    // provides the disabled appearance without changing the text colour.
    final textColor =
        widget.foregroundColor ?? context.themeTextColors.textColor;

    final label = Text(
      widget.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          widget.textStyle ??
          context.textTheme.titleLarge?.copyWith(
            color: widget.isOutlined
                ? context.themeTextColors.descriptionColor
                : textColor,
          ),
    );

    // Show only icon (leading or trailing)
    if (widget.showIconOnly) {
      final iconOnly = widget.icon ?? widget.trailingIcon;
      if (iconOnly != null) return iconOnly;
    }

    // Login layout: [icon] ··· [label]  (wide spacing, left-aligned)
    if (widget.isLoginButton && widget.icon != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w14),
        child: Row(spacing: AppSize.w35, children: [widget.icon!, label]),
      );
    }

    // Leading icon + label + optional trailing icon
    if (widget.icon != null || widget.trailingIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            SizedBox(width: AppSize.w6),
          ],
          label,
          if (widget.trailingIcon != null) ...[
            SizedBox(width: AppSize.w8),
            widget.trailingIcon!,
          ],
        ],
      );
    }

    return label;
  }
}
