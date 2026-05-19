import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import 'onboarding_shell.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

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
