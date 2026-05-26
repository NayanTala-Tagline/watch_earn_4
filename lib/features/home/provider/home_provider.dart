import 'package:ad_manager/ad_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../routes/app_router.dart';
import '../../../services/reward_ad_service.dart';
import '../../../utils/remote_config.dart';

class HomeProvider extends ChangeNotifier {
  final _db = Injector.instance<AppDB>();
  final _fireStore = FirebaseFirestore.instance;

  InlineAdManager? nativeAd1;
  InlineAdManager? nativeAd2;

  HomeProvider() {
    _checkAndShowDailyReminder();
    _loadAds();
  }

  Future<void> _loadAds() async {
    nativeAd1 = InlineAdManager(
      adData: RemoteConfigService.instance.homeNative1,
    );
    nativeAd2 = InlineAdManager(
      adData: RemoteConfigService.instance.homeNative2,
    );
    await Future.wait([nativeAd1!.load(), nativeAd2!.load()]);
    notifyListeners();
  }

  void _checkAndShowDailyReminder() {
    // Post-frame so the navigator is ready; used by callers if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavKey.currentContext;
      if (ctx == null) return;
      // No auto-dialog here — the HomeScreen card handles it inline.
    });
  }

  // ── Computed state ────────────────────────────────────────────────────────

  int get totalCoins => _db.userModel?.coin.toInt() ?? 0;
  int get xp => _db.userModel?.xp.toInt() ?? 0;
  int get level => _db.userModel?.level.toInt() ?? 1;
  int get totalClaimDays => _db.userModel?.totalClaimDays ?? 0;

  /// Dollar balance string, e.g. "\$12.34"
  String get balanceDollars {
    final coins = _db.userModel?.coin ?? 0;
    return (coins / 1000).toStringAsFixed(2);
  }

  /// The day slot the user is on (1–7). Resets if they missed a day or
  /// completed the 7-day cycle.
  int get currentCheckInDay {
    final user = _db.userModel;
    if (user == null || user.lastCheckInDate == null) return 1;
    final today = _dateOnly(DateTime.now());
    final last = _dateOnly(user.lastCheckInDate!);
    final diff = today.difference(last).inDays;
    if (diff == 0) return user.checkInStreak;
    if (diff == 1) return user.checkInStreak == 7 ? 1 : user.checkInStreak + 1;
    return 1;
  }

  bool get isRewardClaimed {
    final lastDate = _db.userModel?.lastCheckInDate;
    if (lastDate == null) return false;
    return _dateOnly(DateTime.now()) == _dateOnly(lastDate);
  }

  int get dailyRewardCoins => currentCheckInDay * 10;

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> claimDailyReward(BuildContext context) async {
    if (isRewardClaimed) return;
    final navCtx = rootNavKey.currentContext ?? context;
    final earned = await RewardAdService.showDailyCheckin(
      navCtx,
      defaultCoins: dailyRewardCoins,
    );
    if (earned == null) return;
    await _grantDailyReward(earned);
    notifyListeners();
  }

  Future<void> _grantDailyReward(int coins) async {
    final user = _db.userModel;
    if (user == null) return;
    final day = currentCheckInDay;
    final newCoin = user.coin + coins;
    final newXp = (newCoin / 10).roundToDouble();
    final newLevel = ((newXp / 200).floor() + 1).toDouble();

    final updated = user.copyWith(
      coin: newCoin,
      xp: newXp,
      level: newLevel,
      checkInStreak: day,
      lastCheckInDate: DateTime.now(),
      totalClaimDays: user.totalClaimDays + 1,
    );
    _db.userModel = updated;

    try {
      await _fireStore.collection('users').doc(user.userId).update({
        'coin': updated.coin,
        'xp': updated.xp,
        'level': updated.level,
        'check_in_streak': updated.checkInStreak,
        'last_check_in_date': Timestamp.fromDate(updated.lastCheckInDate!),
        'total_claim_days': updated.totalClaimDays,
      });
    } catch (_) {}
  }

  void refresh() => notifyListeners();

  @override
  void dispose() {
    nativeAd1?.dispose();
    nativeAd2?.dispose();
    super.dispose();
  }
}
