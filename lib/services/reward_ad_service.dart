import '../utils/remote_config.dart';

/// Convenience getters used by AdDisclaimerText to show/hide the disclaimer.
class RewardAdService {
  RewardAdService._();

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
}
