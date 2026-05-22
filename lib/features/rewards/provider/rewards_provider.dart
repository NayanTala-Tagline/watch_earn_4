import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../extension/ext_string_alert.dart';
import '../../../models/user_model.dart';
import '../../../utils/logger.dart';
import '../../../utils/remote_config.dart';

class RewardsProvider extends ChangeNotifier {
  RewardsProvider() {
    _fetchReferralStats();
  }

  final AppDB _db = Injector.instance<AppDB>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int referralReward = RemoteConfigService.instance.referralRewardAmount;

  final TextEditingController referralController = TextEditingController();

  bool _isApplyingReferral = false;
  bool get isApplyingReferral => _isApplyingReferral;

  String? _errorText;
  String? get errorText => _errorText;

  int _friendsInvited = 0;
  int get friendsInvited => _friendsInvited;
  int get coinsEarned => _friendsInvited * referralReward;

  UserModel? get _currentUser => _db.userModel;
  String get referralCode => _currentUser?.userId ?? '';

  Future<void> _fetchReferralStats() async {
    final userId = _currentUser?.userId;
    if (userId == null || userId.isEmpty) return;
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('referred_by', isEqualTo: userId)
          .count()
          .get();
      _friendsInvited = snapshot.count ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> validateReferralCode(BuildContext context) async {
    if (_isApplyingReferral) return;

    final user = _currentUser;
    if (user == null) {
      'Something went wrong. Please try again.'.showErrorAlert();
      return;
    }

    if (user.isGuest) {
      'Please link your account first.'.showErrorAlert();
      return;
    }

    if (user.referredBy != null && user.referredBy!.isNotEmpty) {
      'You have already used a referral code.'.showInfoAlert();
      return;
    }

    final code = referralController.text.trim();
    if (code.isEmpty) {
      _errorText = 'Please enter a referral code.';
      notifyListeners();
      return;
    }

    if (code == user.userId) {
      _errorText = "You can't use your own referral code.";
      notifyListeners();
      _errorText!.showErrorAlert();
      return;
    }

    _errorText = null;
    _isApplyingReferral = true;
    notifyListeners();

    try {
      final referrerRef = _firestore.collection('users').doc(code);
      final selfRef = _firestore.collection('users').doc(user.userId);

      late double newSelfCoins;
      await _firestore.runTransaction((tx) async {
        final referrerSnap = await tx.get(referrerRef);
        if (!referrerSnap.exists) throw _ReferralException('Invalid referral code.');

        final selfSnap = await tx.get(selfRef);
        if (!selfSnap.exists) throw _ReferralException('Something went wrong. Please try again.');

        final selfData = selfSnap.data()!;
        final referrerData = referrerSnap.data()!;

        final existingRef = selfData['referred_by'] as String?;
        if (existingRef != null && existingRef.isNotEmpty) {
          throw _ReferralException('You have already used a referral code.');
        }

        final selfCoins = (selfData['coin'] as num).toDouble() + referralReward;
        final referrerCoins = (referrerData['coin'] as num).toDouble() + referralReward;
        newSelfCoins = selfCoins;

        tx.update(selfRef, {'referred_by': code, 'coin': selfCoins});
        tx.update(referrerRef, {'coin': referrerCoins});
      });

      _db.userModel = user.copyWith(referredBy: code, coin: newSelfCoins);
      referralController.clear();
      unawaited(_fetchReferralStats());
      'Referral applied! You earned $referralReward coins.'.showSuccessAlert();
    } on _ReferralException catch (e) {
      _errorText = e.message;
      e.message.showErrorAlert();
    } catch (e) {
      e.logE;
      _errorText = 'Could not apply referral code. Please try again.';
      _errorText!.showErrorAlert();
    } finally {
      _isApplyingReferral = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    referralController.dispose();
    super.dispose();
  }
}

class _ReferralException implements Exception {
  final String message;
  _ReferralException(this.message);
}
