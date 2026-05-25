import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../gen/assets.gen.dart';
import '../../utils/anaytics_manager.dart';
import 'onboarding_shell.dart';

class Onboarding2Screen extends StatefulWidget {
  const Onboarding2Screen({super.key});

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> {
  @override
  void initState() {
    super.initState();
    AnalyticsManager.instance.logScreenView(
      screenName: 'onboarding_2',
      screenClass: 'Onboarding2Screen',
    );
  }

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
