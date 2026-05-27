import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/cupertino.dart';

import '../../../utils/remote_config.dart';

/// Owns the interstitial for the current onboarding screen and pre-loads the
/// native ad for the NEXT screen. The current screen's native is passed in
/// pre-loaded from the previous screen (or splash).
///
/// Button loading state reflects whether the next screen's native is still
/// loading. No overlay loader is used — only the button's [isLoading] flag.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    required InlineAdManager? preloadedNative,
    AdData? nextNativeAdData,
    required AdData interAdData,
    bool preloadLanguageAds = false,
  }) {
    nativeAd = preloadedNative;
    _trackCurrentNativeLoad();
    _loadAds(nextNativeAdData, interAdData);
    if (preloadLanguageAds) _loadLanguageAds();
  }

  bool isLoading = false;
  bool _disposed = false;

  /// Native ad shown on THIS screen (pre-loaded by previous screen / splash).
  InlineAdManager? nativeAd;

  /// Native ad pre-loaded for the NEXT screen.
  InlineAdManager? _nextNativeAd;
  bool _nextNativeTransferred = false;

  InterstitialAdManager? interAd;

  /// Language-screen ads (only pre-loaded on onboarding 3).
  NativeAdManager? _languageNativeAd1;
  NativeAdManager? _languageNativeAd2;
  bool _languageAdsTransferred = false;

  // ── Internal helpers ─────────────────────────────────────────────────────────

  void _trackCurrentNativeLoad() {
    if (nativeAd != null && nativeAd!.isLoading) {
      nativeAd!.future().then((_) {
        if (!_disposed) notifyListeners();
      });
    }
  }

  void _loadAds(AdData? nextNativeAdData, AdData interAdData) {
    if (nextNativeAdData != null) {
      _nextNativeAd = InlineAdManager(adData: nextNativeAdData);
      unawaited(_nextNativeAd!.load());
    }
    interAd = InterstitialAdManager(adData: interAdData);
    unawaited(interAd!.load());
  }

  void _loadLanguageAds() {
    final ad1Data = RemoteConfigService.instance.languageNative;
    if (ad1Data.enabled || ad1Data.adType == AdType.custom) {
      _languageNativeAd1 = NativeAdManager(adData: ad1Data);
      unawaited(_languageNativeAd1!.load());
    }

    final ad2Data = RemoteConfigService.instance.languageNative2;
    if (ad2Data.enabled || ad2Data.adType == AdType.custom) {
      _languageNativeAd2 = NativeAdManager(adData: ad2Data);
      unawaited(_languageNativeAd2!.load());
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Waits for the next screen's native ad if it is still loading.
  /// Sets [isLoading] = true (button shows loader), clears it when done.
  /// On failure it returns immediately so the user is never blocked.
  Future<void> waitForNextAd() async {
    // Onboarding 3: wait for language native 1.
    final langAd = _languageNativeAd1;
    if (langAd != null && langAd.isLoading) {
      isLoading = true;
      notifyListeners();
      await langAd.future();
      isLoading = false;
      notifyListeners();
      return;
    }

    // Onboarding 1 / 2: wait for inline next native.
    final nextAd = _nextNativeAd;
    if (nextAd != null && nextAd.isLoading) {
      isLoading = true;
      notifyListeners();
      await nextAd.future();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Transfers ownership of the next inline native ad to the caller.
  /// Call before navigating to the next onboarding screen.
  InlineAdManager? takeNextNativeAd() {
    _nextNativeTransferred = true;
    return _nextNativeAd;
  }

  /// Transfers ownership of the pre-loaded language ads to the caller.
  /// Call before navigating to the language screen (onboarding 3 only).
  ({NativeAdManager? ad1, NativeAdManager? ad2}) takeLanguageAds() {
    _languageAdsTransferred = true;
    return (ad1: _languageNativeAd1, ad2: _languageNativeAd2);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    nativeAd?.dispose();
    if (!_nextNativeTransferred) _nextNativeAd?.dispose();
    interAd?.dispose();
    if (!_languageAdsTransferred) {
      _languageNativeAd1?.dispose();
      _languageNativeAd2?.dispose();
    }
    super.dispose();
  }
}
