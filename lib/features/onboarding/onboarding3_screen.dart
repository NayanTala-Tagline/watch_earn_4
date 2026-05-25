import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import 'onboarding_shell.dart';

class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'onboarding_3',
      screenClass: 'Onboarding3Screen',
    );
  }

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
