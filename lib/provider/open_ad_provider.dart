import 'package:ad_manager/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../routes/app_router.dart';
import '../utils/logger.dart';
import '../utils/remote_config.dart';
import '../widgets/ad_loading_overlay.dart';

class OpenAdProvider extends ChangeNotifier {
  OpenAdProvider();

  OpenAppAdManager? _openAppAd;
  AppLifecycleListener? _listener;

  void startOpenAdListener() {
    // Skip the very first resume (app cold start → foreground transition).
    ignoreNextEvent = true;
    _loadOpenAppAd();
    _startStateListener();
  }

  Future<void> _loadOpenAppAd() async {
    _openAppAd = OpenAppAdManager(
      adData: RemoteConfigService.instance.applicationAppOpen,
      fullScreenContentCallback: FullScreenContentCallback(
        onAdWillDismissFullScreenContent: (_) => _loadOpenAppAd(),
        onAdFailedToShowFullScreenContent: (_, _) => _loadOpenAppAd(),
      ),
    );
    await _openAppAd?.load();
    'OpenAdProvider: ad loaded'.logD;
  }

  void _startStateListener() {
    _listener = AppLifecycleListener(
      onResume: () async {
        final adData = RemoteConfigService.instance.applicationAppOpen;

        // Skip if both normal ad AND custom ad are disabled.
        if (!adData.enabled && adData.adType != AdType.custom) return;

        if (ignoreNextEvent) {
          ignoreNextEvent = false;
          'OpenAdProvider: skipping resume (ignoreNextEvent)'.logD;
          return;
        }

        final context = rootNavKey.currentContext;
        if (context == null || !context.mounted) return;

        'OpenAdProvider: showing on resume'.logD;
        AdLoadingOverlay.show(context);

        try {
          if (adData.adType == AdType.custom) {
            ignoreNextEvent = true;
            await Future.delayed(const Duration(milliseconds: 500));
            await launchUrlString(adData.customAdUrl);
          } else {
            await _openAppAd?.future();
            await _openAppAd?.show();
          }
        } finally {
          AdLoadingOverlay.hide();
        }
      },
    );
  }

  @override
  void dispose() {
    _openAppAd?.dispose();
    _listener?.dispose();
    super.dispose();
  }
}
