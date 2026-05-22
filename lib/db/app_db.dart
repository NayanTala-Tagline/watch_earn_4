import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';
import '../utils/logger.dart';

/// to store local data
class AppDB {
  AppDB._(this._box);

  static const _appDbBox = '_appDbBox';
  final Box<dynamic> _box;

  /// to get instance
  static Future<AppDB> getInstance() async {
    try {
      final box = await Hive.openBox<dynamic>(_appDbBox);
      return AppDB._(box);
    } catch (e) {
      final appDir = await getApplicationDocumentsDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      final box = await Hive.openBox<dynamic>(_appDbBox);
      return AppDB._(box);
    }
  }

  /// save value
  T getValue<T>(String key, {T? defaultValue}) => _box.get(key, defaultValue: defaultValue) as T;

  /// save value
  Future<void> setValue<T>(String key, T value) => _box.put(key, value);

  /// to get user token
  String get token => getValue('token', defaultValue: '');

  ///to set user token
  set token(String update) => setValue('token', update);

  /// to get refresh token
  String get refreshToken => getValue('refreshToken', defaultValue: '');

  ///to set refresh token
  set refreshToken(String update) => setValue('refreshToken', update);

  /// Removes user session data on logout.
  /// Preserves device-level keys (visit-website locks, game locks,
  /// leaderboard timer, internet status, language) across logout/login cycles.
  Future<void> logoutUser() async {
    try {
      const preserved = {
        'leaderboardTimerExpiry',
        'internetStatus',
        'languageCode',
      };
      final keysToDelete = _box.keys
          .where((k) {
            final key = k.toString();
            if (preserved.contains(key)) return false;
            if (key.startsWith('vw_lock_')) return false;
            if (key.startsWith('gz_lock_')) return false;
            return true;
          })
          .toList();
      await _box.deleteAll(keysToDelete);
    } catch (e) {
      e.logFatal;
    }
  }

  /// to set internet status
  set internetStatus(String status) => setValue('internetStatus', status);

  /// to get internet status
  String get internetStatus => getValue('internetStatus', defaultValue: 'connected');

  /// to check internet connection status is connected or not
  bool get isInternetConnected {
    return internetStatus == 'connected';
  }

  /// get language preference
  String get languageCode => getValue('languageCode', defaultValue: '');

  /// set language preference
  set languageCode(String update) => setValue('languageCode', update);

  /// --- Mining Session Management ---
  /// get selected country
  String get selectedCountry => getValue('selectedCountry', defaultValue: '');

  /// set selected country
  set selectedCountry(String update) => setValue('selectedCountry', update);

  /// to get user data
  UserModel? get userModel => getValue<Map<dynamic, dynamic>?>('userModel') != null
      ? UserModel.fromLocalMap(Map<String, dynamic>.from(getValue('userModel')))
      : null;

  /// to set user data
  set userModel(UserModel? data) => setValue('userModel', data?.toLocalMap());

  /// notifies user on value change
  Stream<BoxEvent> userListenable() {
    return _box.watch(key: 'userModel').asBroadcastStream();
  }

  bool get isOnBoardingComplete => getValue('isOnBoardingComplete', defaultValue: false);
  set isOnBoardingComplete(bool value) => setValue('isOnBoardingComplete', value);

  bool? get isOnboardingCompleted => getValue('isOnboardingCompleted');
  set isOnboardingCompleted(bool? value) => setValue('isOnboardingCompleted', value);

  String get currencyCode => getValue('currencyCode', defaultValue: 'USD');
  set currencyCode(String value) => setValue('currencyCode', value);

  String get currencySymbol => getValue('currencySymbol', defaultValue: r'$');
  set currencySymbol(String value) => setValue('currencySymbol', value);

  // ── Leaderboard ──────────────────────────────────────────────────────────

  int? get leaderboardTimerExpiry => getValue<int?>('leaderboardTimerExpiry');
  set leaderboardTimerExpiry(int? value) =>
      setValue('leaderboardTimerExpiry', value);

  // ── Spin wheel ────────────────────────────────────────────────────────────

  /// Number of spins used on [lastSpinDate].
  int get spinCountToday => getValue('spinCountToday', defaultValue: 0);
  set spinCountToday(int value) => setValue('spinCountToday', value);

  /// Date (yyyy-MM-dd) of the last spin session — used to reset daily count.
  String get lastSpinDate => getValue('lastSpinDate', defaultValue: '');
  set lastSpinDate(String value) => setValue('lastSpinDate', value);

  /// Returns remaining spins today, resetting the count if the date changed.
  int getRemainingSpins(int maxPerDay) {
    final today = _todayStr();
    if (lastSpinDate != today) {
      spinCountToday = 0;
      lastSpinDate = today;
    }
    return (maxPerDay - spinCountToday).clamp(0, maxPerDay);
  }

  /// Records one spin used (daily quota + lifetime total).
  void recordSpin() {
    final today = _todayStr();
    if (lastSpinDate != today) {
      spinCountToday = 0;
      lastSpinDate = today;
    }
    spinCountToday = spinCountToday + 1;
    totalSpinCount = totalSpinCount + 1;
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ── Profile settings ──────────────────────────────────────────────────────

  bool get soundEffects => getValue('soundEffects', defaultValue: true);
  set soundEffects(bool value) => setValue('soundEffects', value);

  bool get hapticFeedback => getValue('hapticFeedback', defaultValue: true);
  set hapticFeedback(bool value) => setValue('hapticFeedback', value);

  // ── Achievement tracking ───────────────────────────────────────────────────

  /// Lifetime quiz completions (incremented once per successful reward claim).
  int get totalQuizCount => getValue('totalQuizCount', defaultValue: 0);
  set totalQuizCount(int value) => setValue('totalQuizCount', value);
  void recordQuizCompletion() => setValue('totalQuizCount', totalQuizCount + 1);

  /// Lifetime spin-wheel spins (also bumped inside [recordSpin]).
  int get totalSpinCount => getValue('totalSpinCount', defaultValue: 0);
  set totalSpinCount(int value) => setValue('totalSpinCount', value);

  /// Lifetime scratch-card completions.
  int get totalScratchCount => getValue('totalScratchCount', defaultValue: 0);
  set totalScratchCount(int value) => setValue('totalScratchCount', value);
  void recordScratchCard() => setValue('totalScratchCount', totalScratchCount + 1);

  /// Lifetime successful web-visit completions.
  int get totalWebVisitCount => getValue('totalWebVisitCount', defaultValue: 0);
  set totalWebVisitCount(int value) => setValue('totalWebVisitCount', value);
  void recordWebVisit() => setValue('totalWebVisitCount', totalWebVisitCount + 1);
}
