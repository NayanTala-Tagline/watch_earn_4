import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../db/app_db.dart';
import '../../../di/injector.dart';
import '../../../models/user_model.dart';
import '../../../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final _db = Injector.instance<AppDB>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;
  String? _errorMessage;

  bool get isGoogleLoading => _isGoogleLoading;
  bool get isGuestLoading => _isGuestLoading;
  String? get errorMessage => _errorMessage;

  // ── Device ID ──────────────────────────────────────────────────────────────

  Future<String> _getDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        return (await info.androidInfo).id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        return (await info.iosInfo).identifierForVendor ?? 'unknown_ios';
      }
    } catch (e) {
      e.logFatal;
    }
    return 'unknown_device';
  }

  // ── Firestore helpers ──────────────────────────────────────────────────────

  Future<void> _saveToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.userId)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      final deviceId = await _getDeviceId();

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final UserModel user;
      if (doc.exists) {
        user = UserModel.fromMap(doc.data()!);
      } else {
        user = UserModel(
          userId: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email,
          photoUrl: firebaseUser.photoURL,
          deviceId: deviceId,
          xp: 0,
          level: 1,
          coin: 0,
          createdAt: DateTime.now(),
          isGuest: false,
        );
        await _saveToFirestore(user);
      }

      _db.userModel = user;
      _isGoogleLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // User dismissed the picker — not an error, just stop loading silently.
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        _isGoogleLoading = false;
        notifyListeners();
        return false;
      }
      e.logFatal;
      _errorMessage = 'Google sign-in failed. Please try again.';
      _isGoogleLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Guest Sign-In ──────────────────────────────────────────────────────────

  Future<bool> continueAsGuest() async {
    _isGuestLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deviceId = await _getDeviceId();
      final docRef = _firestore.collection('users').doc();

      final user = UserModel(
        userId: docRef.id,
        name: 'Guest User',
        deviceId: deviceId,
        xp: 0,
        level: 1,
        coin: 0,
        createdAt: DateTime.now(),
        isGuest: true,
      );

      await docRef.set(user.toMap());
      _db.userModel = user;

      _isGuestLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      e.logFatal;
      _errorMessage = 'Could not continue as guest. Please try again.';
      _isGuestLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Sign-Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _db.logoutUser();
    notifyListeners();
  }
}
