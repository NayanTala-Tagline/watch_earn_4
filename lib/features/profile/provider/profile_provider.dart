import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../models/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider() : _db = Injector.instance<AppDB>();

  final AppDB _db;

  static const _levelNames = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro',
    'Expert',
  ];

  UserModel? get user => _db.userModel;

  bool get soundEffects => _db.soundEffects;
  bool get hapticFeedback => _db.hapticFeedback;

  void toggleSoundEffects(bool value) {
    _db.soundEffects = value;
    notifyListeners();
  }

  void toggleHapticFeedback(bool value) {
    _db.hapticFeedback = value;
    notifyListeners();
  }

  /// Returns the tier name for the given level (cycles every 5 levels).
  String levelName(double level) {
    final idx = ((level.toInt() - 1) % 5).clamp(0, 4);
    return _levelNames[idx];
  }

  /// Returns the name of the next tier (wraps back to Beginner after Expert).
  String nextLevelName(double level) {
    final idx = level.toInt() % 5;
    return _levelNames[idx];
  }

  /// Progress within the current level (0.0 – 1.0), based on 1000 XP/level.
  double levelProgress(double xp) {
    const xpPerLevel = 1000.0;
    return (xp % xpPerLevel) / xpPerLevel;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _db.logoutUser();
  }
}
