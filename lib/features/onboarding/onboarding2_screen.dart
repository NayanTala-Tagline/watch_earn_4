import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import 'onboarding_shell.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      image: Assets.images.onboarding.onboarding2,
      title: 'Ultimate Games',
      subtitle: 'Get Multiple options for Games to Play and Get More Points.',
      buttonText: 'Next',
      onNext: () => context.goNamed('Onboarding3Screen'),
      onSkip: () => context.goNamed('LoginScreen'),
    );
  }
}
