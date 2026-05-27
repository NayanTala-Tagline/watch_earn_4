import 'package:ad_manager/ad_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../models/achievement_model.dart';
import '../../../services/coin_service.dart';
import '../../../utils/logger.dart';
import '../../../utils/remote_config.dart';

class AchievementProvider extends ChangeNotifier {
  AchievementProvider() {
    _init();
    _loadAds();
  }

  final _db = Injector.instance<AppDB>();
  final _firestore = FirebaseFirestore.instance;

  InlineAdManager? nativeAd1;
  InlineAdManager? nativeAd2;

  Future<void> _loadAds() async {
    nativeAd1 = InlineAdManager(
      adData: RemoteConfigService.instance.achievementsNative1,
    );
    nativeAd2 = InlineAdManager(
      adData: RemoteConfigService.instance.achievementsNative2,
    );
    await Future.wait([nativeAd1!.load(), nativeAd2!.load()]);
    notifyListeners();
  }

  @override
  void dispose() {
    nativeAd1?.dispose();
    nativeAd2?.dispose();
    super.dispose();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isClaiming = false;
  bool get isClaiming => _isClaiming;

  /// IDs of achievements that have already been claimed.
  final Set<String> _claimed = {};

  Future<void> _init() async {
    final userId = _db.userModel?.userId;
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final snap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .where('claimed', isEqualTo: true)
          .get();

      for (final doc in snap.docs) {
        _claimed.add(doc.id);
      }
    } catch (e) {
      'AchievementProvider._init: $e'.logD;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Current progress for [def], clamped to [def.goal].
  int getProgress(AchievementDef def) {
    final user = _db.userModel;
    final raw = switch (def.category) {
      AchievementCategory.quiz => _db.totalQuizCount,
      AchievementCategory.spin => _db.totalSpinCount,
      AchievementCategory.checkIn => user?.totalClaimDays ?? 0,
      AchievementCategory.streak => user?.checkInStreak ?? 0,
      AchievementCategory.coins => user?.coin.toInt() ?? 0,
      AchievementCategory.scratch => _db.totalScratchCount,
      AchievementCategory.webVisit => _db.totalWebVisitCount,
    };
    return raw.clamp(0, def.goal);
  }

  bool isCompleted(AchievementDef def) => getProgress(def) >= def.goal;
  bool isClaimed(AchievementDef def) => _claimed.contains(def.id);
  bool canClaim(AchievementDef def) => isCompleted(def) && !isClaimed(def);

  /// Awards [def.reward] coins and records the claim in Firestore.
  /// Returns true on success.
  Future<bool> claimAchievement(AchievementDef def) async {
    if (!canClaim(def) || _isClaiming) return false;
    final userId = _db.userModel?.userId;
    if (userId == null) return false;

    _isClaiming = true;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(def.id)
          .set({'claimed': true, 'claimedAt': Timestamp.now()});

      await CoinService.addCoins(def.reward);
      _claimed.add(def.id);
    } catch (e) {
      'AchievementProvider.claimAchievement: $e'.logD;
      _isClaiming = false;
      notifyListeners();
      return false;
    }

    _isClaiming = false;
    notifyListeners();
    return true;
  }

  Future<void> refresh() async {
    _isLoading = true;
    _claimed.clear();
    notifyListeners();
    await _init();
  }
}
