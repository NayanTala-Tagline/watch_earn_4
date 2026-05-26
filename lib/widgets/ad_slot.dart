import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extension/ext_context.dart';
import '../utils/app_size.dart';

/// Renders an [InlineAdManager]'s widget with a shimmer placeholder while the
/// ad is loading, and collapses to nothing on failure or when disabled.
class AdSlot extends StatefulWidget {
  const AdSlot({
    super.key,
    this.ad,
    this.height,
    this.safeAreaTop,
    this.safeAreaBottom,
  });

  final InlineAdManager? ad;
  final bool? safeAreaTop;
  final bool? safeAreaBottom;

  /// Placeholder height used while the ad is loading. When null we fall back
  /// to a reasonable native-template height.
  final double? height;

  @override
  State<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends State<AdSlot> {
  @override
  void initState() {
    super.initState();
    widget.ad?.future().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    if (ad?.adData.enabled == false) return const SizedBox.shrink();
    if (ad == null) return const SizedBox.shrink();

    if (ad.isFailed) return const SizedBox.shrink();

    // Priority: caller override → adData.height (if > 0) → template-based default.
    // adData.height defaults to 0 (not null), so ?? alone is not enough.
    final adHeight = (widget.height != null && widget.height! > 0)
        ? widget.height!
        : (ad.adData.height > 0)
            ? ad.adData.height
            : (ad.adData.templateType == TemplateType.medium
                ? 360.0
                : 100.0);

    if (!ad.isLoaded) {
      return _ShimmerPlaceholder(
        height: adHeight,
        safeAreaTop: widget.safeAreaTop ?? false,
        safeAreaBottom: widget.safeAreaBottom ?? true,
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSize.h10),
      child: SafeArea(
        top: widget.safeAreaTop ?? false,
        bottom: widget.safeAreaBottom ?? true,
        child: SizedBox(
          height: adHeight,
          child: ad.adWidget(),
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder({
    required this.height,
    required this.safeAreaTop,
    required this.safeAreaBottom,
  });

  final double height;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSize.h10),
      child: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.themeColors.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.r12),
            ),
          ),
        ),
      ),
    );
  }
}