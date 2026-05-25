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
import '../../widgets/app_button.dart';
import '../../widgets/common_appbar.dart';
import 'provider/game_zone_provider.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _GameItem {
  const _GameItem(this.title, this.url);
  final String title;
  final String url;
}

int get _coinsPerGame => RemoteConfigService.instance.gameVisitRewardCoins;
int get _gameDurationSecs => RemoteConfigService.instance.gameVisitTimeSeconds;
bool get _useInAppWebView => RemoteConfigService.instance.inAppWebView;

final _gameItems = <_GameItem>[
  _GameItem(RemoteConfigService.instance.gameVisit1Title, RemoteConfigService.instance.gameVisit1),
  _GameItem(RemoteConfigService.instance.gameVisit2Title, RemoteConfigService.instance.gameVisit2),
  _GameItem(RemoteConfigService.instance.gameVisit3Title, RemoteConfigService.instance.gameVisit3),
  _GameItem(RemoteConfigService.instance.gameVisit4Title, RemoteConfigService.instance.gameVisit4),
  _GameItem(RemoteConfigService.instance.gameVisit5Title, RemoteConfigService.instance.gameVisit5),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class GameZoneScreen extends StatelessWidget {
  const GameZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameZoneProvider(),
      child: const _GameZoneContent(),
    );
  }
}

class _GameZoneContent extends StatefulWidget {
  const _GameZoneContent();

  @override
  State<_GameZoneContent> createState() => _GameZoneContentState();
}

class _GameZoneContentState extends State<_GameZoneContent>
    with WidgetsBindingObserver {
  DateTime? _launchTime;
  bool _waitingForReturn = false;
  int? _activeItemIndex;


  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'game_zone',
      screenClass: 'GameZoneScreen',
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

  Future<void> _launchGameExternal(_GameItem item) async {
    AnalyticsManager.instance.logEvent(
      name: 'game_launch_external',
      parameters: {'game_title': item.title},
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

    if (elapsed >= _gameDurationSecs) {
      AnalyticsManager.instance.logEvent(
        name: 'game_completion_eligible',
        parameters: {'time_spent': elapsed, 'required': _gameDurationSecs},
      );
      _showCongratsSheet();
    } else {
      AnalyticsManager.instance.logEvent(
        name: 'game_completion_failed',
        parameters: {'time_spent': elapsed, 'required': _gameDurationSecs},
      );
      _showTimeFailSheet(elapsed);
    }
  }

  void _launchGameInApp(_GameItem item) {
    AnalyticsManager.instance.logEvent(
      name: 'game_launch_inapp',
      parameters: {'game_title': item.title},
    );
    final index = _activeItemIndex;
    context.pushNamed(
      AppRoutes.inAppWebView,
      extra: {
        'url': item.url,
        'title': 'Game Zone',
        'durationSeconds': _gameDurationSecs,
        'coins': _coinsPerGame,
        'adData': RemoteConfigService.instance.playGameReward,
        'onRewardClaimed': () {
          if (index != null) {
            context.read<GameZoneProvider>().setLock(index);
          }
        },
      },
    );
  }

  void _showMissionBrief(int index, _GameItem item) {
    AnalyticsManager.instance.logEvent(
      name: 'game_mission_brief_shown',
      parameters: {'game_title': item.title},
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
          durationSecs: _gameDurationSecs,
          onStart: () {
            AnalyticsManager.instance.logEvent(
              name: 'game_mission_start',
              parameters: {'game_title': item.title},
            );
            sheetCtx.pop();
            _activeItemIndex = index;
            if (_useInAppWebView) {
              _launchGameInApp(item);
            } else {
              _launchGameExternal(item);
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
        coins: _coinsPerGame,
        onClaim: () async {
          AnalyticsManager.instance.logEvent(
            name: 'game_reward_claim_tap',
            parameters: {'coins': _coinsPerGame},
          );
          sheetCtx.pop();
          if (claimedIndex != null) {
            final granted = await context
                .read<GameZoneProvider>()
                .claimReward(claimedIndex);
            if (granted) {
              AnalyticsManager.instance.logEvent(
                name: 'game_reward_claimed',
                parameters: {'coins': _coinsPerGame},
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
        required: _gameDurationSecs,
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
          titleText: 'Game Zone',
          leading: _BackButton(
            onTap: () => NavigationHelper().handleBackPress(context),
          ),
        ),
        body: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            AppSize.w16,
            AppSize.h20,
            AppSize.w16,
            AppSize.h24,
          ),
          itemCount: _gameItems.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSize.h12),
          itemBuilder: (context, index) {
            final item = _gameItems[index];
            if (item.url.isEmpty) return const SizedBox.shrink();
            final prov = context.watch<GameZoneProvider>();
            final locked = prov.isLocked(index);
            final countdown = locked ? prov.lockCountdown(index) : null;

            return _GameTile(
              item: item,
              isLocked: locked,
              lockCountdown: countdown,
              onTap: locked ? () {} : () => _showMissionBrief(index, item),
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
        width: 40,
        height: 40,
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
            color: context.themeColors.navyColor, size: 20),
      ),
    );
  }
}

// ── Game tile ─────────────────────────────────────────────────────────────────

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.item,
    required this.onTap,
    this.isLocked = false,
    this.lockCountdown,
  });

  final _GameItem item;
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
            Assets.images.gameZone.image(
              height: AppSize.h60,
              width: AppSize.w60,
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
                      color: context.themeColors.navyColor,
                    ),
                  ),
                  Row(
                    children: [
                      Assets.icons.icCoin.svg(height: AppSize.sp16, width: AppSize.sp16),
                      SizedBox(width: AppSize.w4),
                      Text(
                        '+$_coinsPerGame Coins',
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
                width: AppSize.w30,
                height: AppSize.h30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD0D5E8),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
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
  const _SheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSize.r48),
          bottom: Radius.circular(AppSize.r48),
        ),
        border: Border(
          top: BorderSide(color: colors.borderColor2),
          left: BorderSide(color: colors.borderColor2),
          right: BorderSide(color: colors.borderColor2),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: AppSize.r24,
            offset: Offset(0, -AppSize.h4),
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
                  'Mission Brief',
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
                        text: 'Stay on the page for $durationSecs Secs., '
                            'A countdown timer will appear. click ',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSize.sp18,
                        ),
                      ),
                      TextSpan(
                        text: '"CLAIM COIN"',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSize.sp18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: ' when ready!',
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
                    Expanded(child: _OutlinePill(label: 'Cancel', onPressed: onCancel)),
                    SizedBox(width: AppSize.w12),
                    Expanded(child: _CyanPill(label: 'Start Now', onPressed: onStart)),
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
          Assets.images.trophy
              .image(height: 90, width: 90, fit: BoxFit.contain),
          SizedBox(height: AppSize.h16),
          Text(
            'Congratulations..!',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp24,
              fontWeight: FontWeight.w800,
              color: context.themeColors.coinGoldColor,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            'You won $coins Coins',
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: AppSize.sp16,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h28),
          _CyanPill(label: 'Claim Coins', onPressed: onClaim),
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
          const Icon(Icons.timer_off_rounded,
              size: 72, color: Color(0xFFFF5183)),
          SizedBox(height: AppSize.h16),
          Text(
            'Time Not Completed!',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF5183),
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text(
            'You stayed for ${elapsed}s out of ${required}s.\nPlease stay on the page for the full duration.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.themeTextColors.descriptionColor,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppSize.h28),
          _CyanPill(label: 'Try Again', onPressed: onDismiss),
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
