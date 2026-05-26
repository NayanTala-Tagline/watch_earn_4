import 'dart:async';

import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/cupertino.dart';

import '../../../utils/remote_config.dart';
import '../../../widgets/loading_overlay/loading_overlay.dart';

/// Owns one inline (native/banner) ad and one interstitial for a single
/// onboarding screen. Each screen creates its own instance via
/// [ChangeNotifierProvider] and passes the correct [AdData] pair.
///
/// Language-screen ads are pre-loaded here in the background and handed off
/// via [takeLanguageAds] before navigating, so [dispose] doesn't destroy them.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    required AdData nativeAdData,
    required AdData interAdData,
  }) {
    _load(nativeAdData, interAdData);
    _loadLanguageAds();
  }

  bool isLoading = false;

  InlineAdManager? nativeAd;
  InterstitialAdManager? interAd;

  NativeAdManager? _languageNativeAd1;
  NativeAdManager? _languageNativeAd2;
  bool _languageAdsTransferred = false;

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> _load(AdData nativeAdData, AdData interAdData) async {
    nativeAd = InlineAdManager(adData: nativeAdData);
    interAd = InterstitialAdManager(adData: interAdData);
    await Future.wait([nativeAd!.load(), interAd!.load()]);
    await Future.wait([nativeAd!.future(), interAd!.future()]);
    notifyListeners();
  }

  // ── Wait / show helpers ─────────────────────────────────────────────────────

  /// Shows a loading overlay, waits for both ads to finish loading, then hides
  /// it. Call before showing the interstitial.
  Future<void> wait(BuildContext context) async {
    if (nativeAd == null || interAd == null) return;
    isLoading = true;
    notifyListeners();

    final overlay = LoadingOverlay.instance();
    overlay.show(context: context);

    await Future.wait([nativeAd!.future(), interAd!.future()]);

    overlay.hide();
    isLoading = false;
    notifyListeners();
  }

  // ── Language page ad pre-loading ────────────────────────────────────────────

  Future<void> _loadLanguageAds() async {
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

  /// Transfers ownership of pre-loaded language ads to the caller.
  /// Call before navigating to the language screen.
  ({NativeAdManager? ad1, NativeAdManager? ad2}) takeLanguageAds() {
    _languageAdsTransferred = true;
    return (ad1: _languageNativeAd1, ad2: _languageNativeAd2);
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    nativeAd?.dispose();
    interAd?.dispose();
    if (!_languageAdsTransferred) {
      _languageNativeAd1?.dispose();
      _languageNativeAd2?.dispose();
    }
    super.dispose();
  }
}
