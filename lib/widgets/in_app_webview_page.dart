import 'dart:async';

import 'package:ad_manager/models/ad_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_earn_4/widgets/app_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../extension/ext_context.dart';
import '../routes/app_router.dart';
import '../services/coin_service.dart';
import '../utils/app_size.dart';
import '../utils/reward_ad_helper.dart';
import '../widgets/common_appbar.dart';

/// In-app webview with a countdown timer overlay.
///
/// Loads [url] in a WebView. A floating badge counts down from [durationSeconds].
/// When the timer reaches zero, a "Claim Reward" button replaces it. Tapping it
/// shows the reward ad; on completion coins are granted and [onRewardClaimed] fires.
class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    super.key,
    required this.url,
    required this.title,
    required this.durationSeconds,
    required this.coins,
    required this.adData,
    this.onRewardClaimed,
  });

  final String url;
  final String title;
  final int durationSeconds;
  final int coins;
  final AdData adData;
  final VoidCallback? onRewardClaimed;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController _controller;
  late int _remaining;
  Timer? _timer;
  bool _completed = false;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        if (mounted) setState(() { _remaining = 0; _completed = true; });
      } else {
        if (mounted) setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onClaimReward() async {
    if (_claimed) return;
    setState(() => _claimed = true);

    final navCtx = rootNavKey.currentContext!;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: navCtx,
      adData: widget.adData,
      onAdCompleted: () async {
        await CoinService.addCoins(widget.coins);
        widget.onRewardClaimed?.call();
      },
      onAdCancelled: () => setState(() => _claimed = false),
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(titleText: widget.title),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSize.h32,
            child: Center(
              child: _completed
                ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w20),
                    child: AppButton(
                      text: _claimed ? 'Claimed' : 'Claim Reward',
                      buttonColor: context.themeColors.buttonColor,
                      shadowColor: context.themeColors.buttonBorderColor,
                      foregroundColor: context.themeColors.whiteColor,
                      isDisabled: _claimed,
                      onPressed: _claimed ? null : _onClaimReward
                    ),
                  )
                  : _TimerBadge(remaining: _remaining),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timer badge ───────────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.remaining});
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.w20,
        vertical: AppSize.h12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.r100),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.themeColors.webviewNavColor,
            context.themeColors.webviewNavColor.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(color: context.themeColors.webviewNavColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSize.w6,
        children: [
          Text(
            '? Reward in ${remaining}s..',
            style: TextStyle(
              fontSize: AppSize.sp14,
              fontWeight: FontWeight.w700,
              color: context.themeColors.whiteColor,
            ),
          ),
          SizedBox(
            height: AppSize.sp18,
            width: AppSize.sp18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.themeColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claim button ──────────────────────────────────────────────────────────────

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onPressed, required this.claimed});
  final VoidCallback? onPressed;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSize.r100);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: AppSize.w20),
          height: AppSize.h48,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.themeColors.webviewNavColor,
                context.themeColors.webviewNavColor.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(color: context.themeColors.webviewNavColor),
            boxShadow: [
              BoxShadow(
                color: context.themeColors.webviewNavColor.withValues(alpha: 0.4),
                blurRadius: AppSize.r20,
                offset: Offset(0, AppSize.h6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            claimed ? 'Claimed' : 'Claim Reward',
            style: TextStyle(
              fontSize: AppSize.sp16,
              fontWeight: FontWeight.w700,
              color: context.themeColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
