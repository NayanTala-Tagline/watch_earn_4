import 'package:flutter/material.dart';

import '../utils/anaytics_manager.dart';
import '../utils/remote_config.dart';
import '../utils/reward_ad_helper.dart';

/// Central service for showing rewarded ads before coin claims.
/// Returns the coins to grant (defaultCoins), or null if the user cancelled.
class RewardAdService {
  RewardAdService._();

  // ── Ad-enabled checks (used by UI to show/hide disclaimer) ──────────────

  static bool get isDailyCheckinAdEnabled =>
      RemoteConfigService.instance.dailyClaimReward.enabled;

  static bool get isMathQuizAdEnabled =>
      RemoteConfigService.instance.mathQuizClaimReward.enabled;

  static bool get isScratchCardAdEnabled =>
      RemoteConfigService.instance.scratchCardClaimReward.enabled;

  static bool get isSpinWheelAdEnabled =>
      RemoteConfigService.instance.spinWheelClaimReward.enabled;

  static bool get isWebsiteRewardAdEnabled =>
      RemoteConfigService.instance.websiteReward.enabled;

  static bool get isPlayGameRewardAdEnabled =>
      RemoteConfigService.instance.playGameReward.enabled;

  // ── Show methods — return null if cancelled, coins to grant if watched ───

  static Future<int?> showDailyCheckin(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.dailyClaimReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_daily_claim');
      },
    );
    return completed ? defaultCoins : null;
  }

  static Future<int?> showMathQuiz(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.mathQuizClaimReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_math_quiz_claim');
      },
    );
    return completed ? defaultCoins : null;
  }

  static Future<int?> showScratchCard(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.scratchCardClaimReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_scratch_card_claim');
      },
    );
    return completed ? defaultCoins : null;
  }

  static Future<int?> showSpinWheel(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.spinWheelClaimReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_spin_wheel_claim');
      },
    );
    return completed ? defaultCoins : null;
  }

  static Future<int?> showWebsiteReward(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.websiteReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_website_reward');
      },
    );
    return completed ? defaultCoins : null;
  }

  static Future<int?> showPlayGameReward(
    BuildContext context, {
    required int defaultCoins,
  }) async {
    bool completed = false;
    await RewardAdHelper.showRewardAdWithBottomSheet(
      context: context,
      adData: RemoteConfigService.instance.playGameReward,
      onAdCompleted: () => completed = true,
      onAdCancelled: () {
        AnalyticsManager.instance.logEvent(name: 'cancel_play_game_reward');
      },
    );
    return completed ? defaultCoins : null;
  }
}
