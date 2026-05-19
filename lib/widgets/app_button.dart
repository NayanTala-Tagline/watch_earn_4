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
    this.gradient,
    this.backgroundColor,
    this.primary,
    this.buttonStyle,
    this.visualDensity,
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
  final Gradient? gradient;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;
  final VisualDensity? visualDensity;

  bool get _is3D => isFillButton && !isOutlined && shadowColor != null;

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
            vertical: AppSize.h4,
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
              vertical: AppSize.h8,
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
            color: widget.borderColor ?? const Color(0xFF686767),
          ),
        ),
        child: inner,
      );
    }

    // ── 3-D filled ────────────────────────────────────────────────────────
    if (widget._is3D) {
      return AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) {
          final p = _pressAnim.value;
          final wallH = (1 - p) * 6.0;
          final shiftY = p * 5.0;

          return Transform.translate(
            offset: Offset(0, shiftY),
            child: Container(
              height: height,
              width: height != null ? double.infinity : null,
              padding: padding,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isDisabled
                    ? Colors.grey.shade400
                    : widget.buttonColor,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDisabled
                        ? Colors.grey.shade600
                        : widget.shadowColor!,
                    offset: Offset(0, wallH),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: inner,
      );
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
            color: const Color(0xffF9D2C5),
            blurRadius: AppSize.r16,
            spreadRadius: AppSize.sp2,
          ),
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
              widget.foregroundColor ?? context.themeColors.iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final textColor = widget.isDisabled
        ? Colors.grey.shade400
        : (widget.foregroundColor ?? context.themeTextColors.textColor);

    final label = Text(
      widget.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.textStyle ??
          context.textTheme.titleSmall?.copyWith(
            color: widget.isOutlined
                ? context.themeTextColors.descriptionColor
                : textColor,
            fontSize: AppSize.sp17,
          ),
    );

    // Show only icon
    if (widget.icon != null && widget.showIconOnly) return widget.icon!;

    // Login layout: [icon] ··· [label]  (wide spacing, left-aligned)
    if (widget.isLoginButton && widget.icon != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w14),
        child: Row(
          spacing: AppSize.w35,
          children: [widget.icon!, label],
        ),
      );
    }

    // Leading icon + label + optional trailing icon
    if (widget.icon != null || widget.trailingIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[widget.icon!, SizedBox(width: AppSize.w6)],
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
