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

  static const _bg = Color(0xFFECEEFA);

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
      builder: (sheetCtx) => _MissionBriefSheet(
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
        backgroundColor: _bg,
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
        child: const Icon(Icons.arrow_back_rounded,
            color: Color(0xFF1C2359), size: 20),
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
          color: const Color(0xFFA4ABC6),
          borderRadius: BorderRadius.circular(AppSize.r20),
        ),
        child: Container(
          // Inner white card sits 4px above the bottom
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSize.r20),
            border: Border.all(color: const Color(0xFFA4ABC6), width: 1),
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
                      color: const Color(0xFF1C2359),
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
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Color(0xFF1C2359),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSize.w24,
        AppSize.h20,
        AppSize.w24,
        AppSize.h32 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.cardColor,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSize.r24)),
        border: Border(
          top: BorderSide(
              color: const Color(0xFF29B0E6).withValues(alpha: 0.4)),
          left: BorderSide(
              color: const Color(0xFF29B0E6).withValues(alpha: 0.4)),
          right: BorderSide(
              color: const Color(0xFF29B0E6).withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B7FF).withValues(alpha: 0.2),
            blurRadius: AppSize.r24,
            offset: Offset(0, -AppSize.h6),
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
              color: const Color(0xFFCDD2E0),
            ),
          ),
          SizedBox(height: AppSize.h20),
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
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.trophy
              .image(height: 90, width: 90, fit: BoxFit.contain),
          SizedBox(height: AppSize.h16),
          Text(
            'Mission Brief',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp22,
              fontWeight: FontWeight.w800,
              color: context.themeTextColors.textColor,
            ),
          ),
          SizedBox(height: AppSize.h8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Stay on the page for $durationSecs secs. A countdown\ntimer will appear. Click "',
                ),
                TextSpan(
                  text: 'Claim Coin',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.themeTextColors.textColor,
                  ),
                ),
                const TextSpan(text: '" when ready!'),
              ],
            ),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.themeTextColors.descriptionColor,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppSize.h24),
          Row(
            children: [
              Expanded(
                  child: _OutlinePill(label: 'Cancel', onPressed: onCancel)),
              SizedBox(width: AppSize.w12),
              Expanded(child: _CyanPill(label: 'Start', onPressed: onStart)),
            ],
          ),
        ],
      ),
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
              color: const Color(0xFFFFD84D),
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
    final radius = BorderRadius.circular(AppSize.r100);
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
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9AE0FA), Color(0xFF5CCBF7)],
            ),
            border: Border.all(color: const Color(0xFFB8ECFF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5CCBF7).withValues(alpha: 0.4),
                blurRadius: AppSize.r16,
                offset: Offset(0, AppSize.h4),
              ),
            ],
          ),
          child: Text(
            label,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppSize.sp15,
              color: const Color(0xFF003A52),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

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
          height: AppSize.h48,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: context.themeColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: AppSize.sp15,
              color: context.themeTextColors.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
