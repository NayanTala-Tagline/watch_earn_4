import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extension/ext_context.dart';
import '../../gen/assets.gen.dart';
import '../../routes/app_router.dart';
import '../../utils/anaytics_manager.dart';
import '../../utils/app_size.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/remote_config.dart';
import '../../gen/fonts.gen.dart';
import '../../widgets/ad_slot.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';
import 'provider/visit_website_provider.dart';

// ── Screen args ───────────────────────────────────────────────────────────────

class WebVisitsScreenArgs {
  const WebVisitsScreenArgs({this.nativeAd1, this.nativeAd2});
  final InlineAdManager? nativeAd1;
  final InlineAdManager? nativeAd2;
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _WebVisitItem {
  const _WebVisitItem(this.title, this.url);
  final String title;
  final String url;
}

int get _coinsPerVisit => RemoteConfigService.instance.webVisitRewardCoins;
int get _visitDurationSecs => RemoteConfigService.instance.webVisitTimeSeconds;
bool get _useInAppWebView => RemoteConfigService.instance.inAppWebView;

final _webVisitItems = <_WebVisitItem>[
  _WebVisitItem(RemoteConfigService.instance.webVisit1Title, RemoteConfigService.instance.webVisit1),
  _WebVisitItem(RemoteConfigService.instance.webVisit2Title, RemoteConfigService.instance.webVisit2),
  _WebVisitItem(RemoteConfigService.instance.webVisit3Title, RemoteConfigService.instance.webVisit3),
  _WebVisitItem(RemoteConfigService.instance.webVisit4Title, RemoteConfigService.instance.webVisit4),
  _WebVisitItem(RemoteConfigService.instance.webVisit5Title, RemoteConfigService.instance.webVisit5),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class WebVisitsScreen extends StatelessWidget {
  const WebVisitsScreen({super.key, this.args});
  final WebVisitsScreenArgs? args;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisitWebsiteProvider(),
      child: _WebVisitsContent(args: args),
    );
  }
}

class _WebVisitsContent extends StatefulWidget {
  const _WebVisitsContent({this.args});
  final WebVisitsScreenArgs? args;

  @override
  State<_WebVisitsContent> createState() => _WebVisitsContentState();
}

class _WebVisitsContentState extends State<_WebVisitsContent>
    with WidgetsBindingObserver {
  DateTime? _launchTime;
  bool _waitingForReturn = false;
  int? _activeItemIndex;


  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'web_visits',
      screenClass: 'WebVisitsScreen',
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForReturn) {
      _waitingForReturn = false;
      _onReturnedToApp();
    }
  }

  Future<void> _launchVisitExternal(_WebVisitItem item) async {
    AnalyticsManager.instance.logEvent(
      name: 'web_visit_launch_external',
      parameters: {'visit_title': item.title},
    );
    final uri = Uri.tryParse(item.url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      _launchTime = DateTime.now();
      _waitingForReturn = true;
      ignoreNextEvent = true;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onReturnedToApp() {
    if (!mounted || _launchTime == null) return;
    final elapsed = DateTime.now().difference(_launchTime!).inSeconds;
    _launchTime = null;

    if (elapsed >= _visitDurationSecs) {
      AnalyticsManager.instance.logEvent(
        name: 'web_visit_completion_eligible',
        parameters: {'time_spent': elapsed, 'required': _visitDurationSecs},
      );
      _showCongratsSheet();
    } else {
      AnalyticsManager.instance.logEvent(
        name: 'web_visit_completion_failed',
        parameters: {'time_spent': elapsed, 'required': _visitDurationSecs},
      );
      _showTimeFailSheet(elapsed);
    }
  }

  void _launchVisitInApp(_WebVisitItem item) {
    AnalyticsManager.instance.logEvent(
      name: 'web_visit_launch_inapp',
      parameters: {'visit_title': item.title},
    );
    final index = _activeItemIndex;
    context.pushNamed(
      AppRoutes.inAppWebView,
      extra: {
        'url': item.url,
        'title': 'Web Visits',
        'durationSeconds': _visitDurationSecs,
        'coins': _coinsPerVisit,
        'adData': RemoteConfigService.instance.websiteReward,
        'onRewardClaimed': () {
          if (index != null) {
            context.read<VisitWebsiteProvider>().setLock(index);
          }
        },
      },
    );
  }

  void _showMissionBrief(int index, _WebVisitItem item) {
    AnalyticsManager.instance.logEvent(
      name: 'web_visit_mission_brief_shown',
      parameters: {'visit_title': item.title},
    );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSize.w16,
          AppSize.h0,
          AppSize.w16,
          AppSize.h16 + MediaQuery.viewPaddingOf(sheetCtx).bottom,
        ),
        child: _MissionBriefSheet(
          durationSecs: _visitDurationSecs,
          onStart: () {
            AnalyticsManager.instance.logEvent(
              name: 'web_visit_mission_start',
              parameters: {'visit_title': item.title},
            );
            sheetCtx.pop();
            _activeItemIndex = index;
            if (_useInAppWebView) {
              _launchVisitInApp(item);
            } else {
              _launchVisitExternal(item);
            }
          },
          onCancel: () => sheetCtx.pop(),
        ),
      ),
    );
  }

  void _showCongratsSheet() {
    final claimedIndex = _activeItemIndex;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) => _CongratsSheet(
        coins: _coinsPerVisit,
        onClaim: () async {
          AnalyticsManager.instance.logEvent(
            name: 'web_visit_reward_claim_tap',
            parameters: {'coins': _coinsPerVisit},
          );
          sheetCtx.pop();
          if (claimedIndex != null) {
            final granted = await context
                .read<VisitWebsiteProvider>()
                .claimReward(claimedIndex);
            if (granted) {
              AnalyticsManager.instance.logEvent(
                name: 'web_visit_reward_claimed',
                parameters: {'coins': _coinsPerVisit},
              );
            }
          }
        },
      ),
    );
  }

  void _showTimeFailSheet(int elapsedSecs) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _TimeFailSheet(
        required: _visitDurationSecs,
        elapsed: elapsedSecs,
        onDismiss: () => sheetCtx.pop(),
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
        appBar: CommonAppBar(
          titleText: context.l10n.webVisits,
          leading: _BackButton(
            onTap: () => NavigationHelper().handleBackPress(context),
          ),
        ),
        bottomNavigationBar: AdSlot(
          ad: widget.args?.nativeAd2,
        ),
        body: Builder(
          builder: (context) {
            final prov = context.watch<VisitWebsiteProvider>();
            final adIndex = (_webVisitItems.length / 2).floor();
            final totalCount = _webVisitItems.length + 1;

            return ListView.builder(
              padding: EdgeInsets.only(
                top: AppSize.h16,
                bottom: AppSize.h24,
              ),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                if (index == adIndex && (widget.args?.nativeAd1?.adData.enabled ?? false)) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h12),
                    child: AdSlot(
                      ad: widget.args?.nativeAd1,
                      safeAreaTop: false,
                      safeAreaBottom: false,
                    ),
                  );
                }
                final itemIndex = index > adIndex ? index - 1 : index;
                final item = _webVisitItems[itemIndex];
                if (item.url.isEmpty) return const SizedBox.shrink();
                final locked = prov.isLocked(itemIndex);
                final countdown = locked ? prov.lockCountdown(itemIndex) : null;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSize.w16,
                    0,
                    AppSize.w16,
                    AppSize.h12,
                  ),
                  child: _VisitTile(
                    item: item,
                    isLocked: locked,
                    lockCountdown: countdown,
                    onTap: locked
                        ? () {}
                        : () => _showMissionBrief(itemIndex, item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.r40,
        height: AppSize.r40,
        decoration: BoxDecoration(
          color: context.themeColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.themeColors.borderColor.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_rounded,
            color: context.themeColors.navyColor, size: AppSize.r20),
      ),
    );
  }
}

// ── Visit tile ────────────────────────────────────────────────────────────────

class _VisitTile extends StatelessWidget {
  const _VisitTile({
    required this.item,
    required this.onTap,
    this.isLocked = false,
    this.lockCountdown,
  });

  final _WebVisitItem item;
  final VoidCallback onTap;
  final bool isLocked;
  final String? lockCountdown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Outer "wall" — shows 4px at the bottom as the 3D border
        decoration: BoxDecoration(
          color: context.themeColors.borderColor,
          borderRadius: BorderRadius.circular(AppSize.r20),
        ),
        child: Container(
          // Inner white card sits 4px above the bottom
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: context.themeColors.whiteColor,
            borderRadius: BorderRadius.circular(AppSize.r20),
            border: Border.all(color: context.themeColors.borderColor, width: 1),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.w16,
            vertical: AppSize.h10,
          ),
          child: Row(
          children: [
            Assets.images.webVisits.image(
              height: AppSize.r60,
              width: AppSize.r60,
              fit: BoxFit.contain,
            ),
            SizedBox(width: AppSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: AppSize.sp16
                    ),
                  ),
                  Row(
                    children: [
                      Assets.icons.icCoin.svg(height: AppSize.h16, width: AppSize.h16),
                      SizedBox(width: AppSize.w3),
                      Text(
                        context.l10n.plusCoinsValue(_coinsPerVisit),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: AppSize.sp13,
                          color: const Color(0xFFFF9500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked && lockCountdown != null && lockCountdown!.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w10,
                  vertical: AppSize.h4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.r8),
                  color: const Color(0xFFFF5183).withValues(alpha: 0.15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 14, color: Color(0xFFFF5183)),
                    SizedBox(width: AppSize.w4),
                    Text(
                      lockCountdown!,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: AppSize.sp12,
                        color: const Color(0xFFFF5183),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: AppSize.r30,
                height: AppSize.r30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD0D5E8),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: AppSize.r18,
                  color: context.themeColors.navyColor,
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── Shared bottom sheet shell ─────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child, this.floating = false});
  final Widget child;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = floating
        ? BorderRadius.circular(AppSize.r24)
        : BorderRadius.vertical(top: Radius.circular(AppSize.r48), bottom: Radius.circular(AppSize.r48));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h12,
        AppSize.w24,
        AppSize.h24,
      ),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: radius,
        border: floating
            ? Border.all(color: colors.borderColor2)
            : Border(
                top: BorderSide(color: colors.borderColor2),
                left: BorderSide(color: colors.borderColor2),
                right: BorderSide(color: colors.borderColor2),
              ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: AppSize.r24,
            offset: floating ? Offset.zero : Offset(0, -AppSize.h4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.w40,
            height: AppSize.h4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.r100),
              color: colors.dragHandleColor,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ── Mission brief sheet ───────────────────────────────────────────────────────

class _MissionBriefSheet extends StatelessWidget {
  const _MissionBriefSheet({
    required this.durationSecs,
    required this.onStart,
    required this.onCancel,
  });

  final int durationSecs;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textColors = context.themeTextColors;
    const iconSize = 130.0;
    const iconRadius = iconSize / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: iconRadius),
          child: _SheetShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: iconRadius + 5),

                Text(
                  context.l10n.missionBrief,
                  style: TextStyle(
                    fontFamily: FontFamily.kommonGrotesk,
                    fontSize: AppSize.sp28,
                    fontWeight: FontWeight.w900,
                    color: textColors.darkTitleColor,
                  ),
                ),
                SizedBox(height: AppSize.h8),

                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: FontFamily.kommonGrotesk,
                      fontSize: AppSize.sp18,
                      color: textColors.bodyTextColor,
                    ),
                    children: [
                      TextSpan(
                        text: context.l10n.missionBriefDuration(durationSecs),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSize.sp18,
                        ),
                      ),
                      TextSpan(
                        text: context.l10n.claimCoinBold,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSize.sp18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: context.l10n.whenReady,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSize.sp18,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.h20),

                Row(
                  children: [
                    Expanded(child: _OutlinePill(label: context.l10n.cancel, onPressed: onCancel)),
                    SizedBox(width: AppSize.w12),
                    Expanded(child: _CyanPill(label: context.l10n.startNow, onPressed: onStart)),
                  ],
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: colors.xpBadgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              padding: EdgeInsets.all(AppSize.w20),
              child: Assets.images.missionBrief.image(fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Congrats sheet ────────────────────────────────────────────────────────────

class _CongratsSheet extends StatelessWidget {
  const _CongratsSheet({required this.coins, required this.onClaim});
  final int coins;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.trophy.image(height: 90, width: 90, fit: BoxFit.contain),
          SizedBox(height: AppSize.h16),
          Text(
            context.l10n.congratulations,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp24,
              fontWeight: FontWeight.w800,
              color: context.themeColors.coinGoldColor,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            context.l10n.youWonCoins(coins),
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp16,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h28),
          _CyanPill(label: context.l10n.claimCoins, onPressed: onClaim),
        ],
      ),
    );
  }
}

// ── Time fail sheet ───────────────────────────────────────────────────────────

class _TimeFailSheet extends StatelessWidget {
  const _TimeFailSheet({
    required this.required,
    required this.elapsed,
    required this.onDismiss,
  });

  final int required;
  final int elapsed;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_off_rounded,
            size: 72,
            color: const Color(0xFFFF5183),
          ),
          SizedBox(height: AppSize.h16),
          Text(
            context.l10n.timeNotCompleted,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF5183),
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            context.l10n.timeNotCompletedDesc(elapsed, required),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.themeTextColors.descriptionColor,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppSize.h28),
          _CyanPill(label: context.l10n.tryAgain, onPressed: onDismiss),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _CyanPill extends StatelessWidget {
  const _CyanPill({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      buttonColor: context.themeColors.buttonColor,
      shadowColor: context.themeColors.buttonBorderColor,
      foregroundColor: context.themeColors.whiteColor,
      wallOffset: 4,
      borderRadius: AppSize.r28,
      textStyle: TextStyle(
        fontFamily: FontFamily.kommonGrotesk,
        fontSize: AppSize.sp15,
        fontWeight: FontWeight.w800,
        color: context.themeColors.whiteColor,
      ),
      onPressed: onPressed,
    );
  }
}

class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSize.r28);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: Container(
          height: AppSize.h48,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.themeColors.fieldBgColor,
            borderRadius: radius,
            border: Border.all(
              color: context.themeColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.kommonGrotesk,
              fontSize: AppSize.sp15,
              fontWeight: FontWeight.w600,
              color: context.themeTextColors.darkTitleColor,
            ),
          ),
        ),
      ),
    );
  }
}
