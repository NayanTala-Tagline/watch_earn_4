import 'dart:async';

import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../routes/app_router.dart';
import '../../../services/coin_service.dart';
import '../../../utils/remote_config.dart';
import '../../../utils/reward_ad_helper.dart';

class GameZoneProvider extends ChangeNotifier {
  static int get lockMinutes =>
      RemoteConfigService.instance.gameVisitAgainLockTimeMinutes;
  static int get coinsPerGame => RemoteConfigService.instance.gameVisitRewardCoins;

  final _db = Injector.instance<AppDB>();
  Timer? _refreshTimer;

  GameZoneProvider() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  String _lockKey(int index) {
    final uid = _db.userModel?.userId ?? 'guest';
    return 'gz_lock_${uid}_$index';
  }

  bool isLocked(int index) {
    final expiry = _db.getValue<int?>(_lockKey(index));
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  String lockCountdown(int index) {
    final expiry = _db.getValue<int?>(_lockKey(index));
    if (expiry == null) return '';
    final diff = expiry - DateTime.now().millisecondsSinceEpoch;
    if (diff <= 0) return '';
    final total = (diff / 1000).ceil();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Shows reward ad, grants coins, and locks the item.
  Future<bool> claimReward(int index) async {
    final navCtx = rootNavKey.currentContext;
    if (navCtx == null) return false;

    bool rewarded = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: navCtx,
      adData: RemoteConfigService.instance.playGameReward,
      onAdCompleted: () => rewarded = true,
      onAdCancelled: () => rewarded = false,
    );
    if (!rewarded) return false;

    await CoinService.addCoins(coinsPerGame);

    final expiry = DateTime.now()
        .add(Duration(minutes: lockMinutes))
        .millisecondsSinceEpoch;
    await _db.setValue(_lockKey(index), expiry);
    notifyListeners();
    return true;
  }

  /// Sets the lock only — used by InAppWebViewPage which handles ad + coins.
  Future<void> setLock(int index) async {
    final expiry = DateTime.now()
        .add(Duration(minutes: lockMinutes))
        .millisecondsSinceEpoch;
    await _db.setValue(_lockKey(index), expiry);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
