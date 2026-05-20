import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import 'onboarding_shell.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      image: Assets.images.onboarding.onboarding3,
      title: 'Track Achievements',
      subtitle:
          'See your achievements and Track it with other user through Leatherboard',
      buttonText: 'Start Earning',
      onNext: () => context.goNamed('language'),
      onSkip: () => context.goNamed('language'),
    );
  }
}
