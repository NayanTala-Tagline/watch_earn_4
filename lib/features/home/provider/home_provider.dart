import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../routes/app_router.dart';
import '../../../utils/anaytics_manager.dart';
import '../../../utils/remote_config.dart';
import '../../../utils/reward_ad_helper.dart';

class HomeProvider extends ChangeNotifier {
  final _db = Injector.instance<AppDB>();
  final _fireStore = FirebaseFirestore.instance;

  // Home-screen ads
  InlineAdManager? nativeAd1;
  InlineAdManager? nativeAd2;

  // Pre-loaded feature screen ads
  InlineAdManager? _quizNativeAd;
  InlineAdManager? _scratchNativeAd;
  InlineAdManager? _webVisitsNativeAd1;
  InlineAdManager? _webVisitsNativeAd2;
  InlineAdManager? _gameZoneNativeAd1;
  InlineAdManager? _gameZoneNativeAd2;
  InlineAdManager? _dailyCheckInNativeAd;
  InlineAdManager? _withdrawNativeAd;
  InlineAdManager? _achievementsNativeAd1;
  InlineAdManager? _achievementsNativeAd2;
  InlineAdManager? _howItWorksNativeAd;


  HomeProvider() {
    _checkAndShowDailyReminder();
    _loadAds();
  }

  Future<void> _loadAds() async {
    final rc = RemoteConfigService.instance;
    nativeAd1 = InlineAdManager(adData: rc.homeNative1);
    nativeAd2 = InlineAdManager(adData: rc.homeNative2);
    _quizNativeAd = InlineAdManager(adData: rc.quizMasterNative);
    _scratchNativeAd = InlineAdManager(adData: rc.scratchCardNative);
    _webVisitsNativeAd1 = InlineAdManager(adData: rc.webVisitsNative1);
    _webVisitsNativeAd2 = InlineAdManager(adData: rc.webVisitsNative2);
    _gameZoneNativeAd1 = InlineAdManager(adData: rc.gameZoneNative1);
    _gameZoneNativeAd2 = InlineAdManager(adData: rc.gameZoneNative2);
    _dailyCheckInNativeAd = InlineAdManager(adData: rc.dailyCheckInNative);
    _withdrawNativeAd = InlineAdManager(adData: rc.withdrawNative);
    _achievementsNativeAd1 = InlineAdManager(adData: rc.achievementsNative1);
    _achievementsNativeAd2 = InlineAdManager(adData: rc.achievementsNative2);
    _howItWorksNativeAd = InlineAdManager(adData: rc.howItWorksNative);

    unawaited(Future.wait([
      nativeAd1!.load(),
      nativeAd2!.load(),
      _quizNativeAd!.load(),
      _scratchNativeAd!.load(),
      _webVisitsNativeAd1!.load(),
      _webVisitsNativeAd2!.load(),
      _gameZoneNativeAd1!.load(),
      _gameZoneNativeAd2!.load(),
      _dailyCheckInNativeAd!.load(),
      _withdrawNativeAd!.load(),
      _achievementsNativeAd1!.load(),
      _achievementsNativeAd2!.load(),
      _howItWorksNativeAd!.load(),
    ]).then((_) => notifyListeners()));
  }

  // ── Accessors for feature screen ads (HomeProvider retains ownership) ────────

  InlineAdManager? get quizNativeAd => _quizNativeAd;
  InlineAdManager? get scratchNativeAd => _scratchNativeAd;
  ({InlineAdManager? ad1, InlineAdManager? ad2}) get webVisitsAds =>
      (ad1: _webVisitsNativeAd1, ad2: _webVisitsNativeAd2);
  ({InlineAdManager? ad1, InlineAdManager? ad2}) get gameZoneAds =>
      (ad1: _gameZoneNativeAd1, ad2: _gameZoneNativeAd2);
  InlineAdManager? get dailyCheckInNativeAd => _dailyCheckInNativeAd;
  InlineAdManager? get withdrawNativeAd => _withdrawNativeAd;
  ({InlineAdManager? ad1, InlineAdManager? ad2}) get achievementsAds =>
      (ad1: _achievementsNativeAd1, ad2: _achievementsNativeAd2);
  InlineAdManager? get howItWorksNativeAd => _howItWorksNativeAd;

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
    final coins = dailyRewardCoins;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: navCtx,
      adData: RemoteConfigService.instance.dailyClaimReward,
      onAdCompleted: () async {
        await _grantDailyReward(coins);
        notifyListeners();
      },
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_daily_claim');
      },
    );
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
    _quizNativeAd?.dispose();
    _scratchNativeAd?.dispose();
    _webVisitsNativeAd1?.dispose();
    _webVisitsNativeAd2?.dispose();
    _gameZoneNativeAd1?.dispose();
    _gameZoneNativeAd2?.dispose();
    _dailyCheckInNativeAd?.dispose();
    _withdrawNativeAd?.dispose();
    _achievementsNativeAd1?.dispose();
    _achievementsNativeAd2?.dispose();
    _howItWorksNativeAd?.dispose();
    super.dispose();
  }
}
