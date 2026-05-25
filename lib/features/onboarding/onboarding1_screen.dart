import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import 'onboarding_shell.dart';

class Onboarding1Screen extends StatefulWidget {
  const Onboarding1Screen({super.key});

  @override
  State<Onboarding1Screen> createState() => _Onboarding1ScreenState();
}

class _Onboarding1ScreenState extends State<Onboarding1Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'onboarding_1',
      screenClass: 'Onboarding1Screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      image: Assets.images.onboarding.onboarding1,
      title: 'Daily Rewards',
      subtitle:
          "You'll Get a Daily Points Reward, Which you can claim and increase you Points",
      buttonText: 'Next',
      onNext: () => context.goNamed('Onboarding2Screen'),
      onSkip: () => context.goNamed('LoginScreen'),
    );
  }
}
