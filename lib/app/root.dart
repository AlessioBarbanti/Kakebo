import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/backdrop.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/features/journal/thought.dart';
import 'package:kakebo/features/month_setup/month_start.dart';
import 'package:kakebo/features/onboarding/onboarding.dart';
import 'package:kakebo/state/kakebo.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  static String _back(String s, Kakebo app) => switch (s) {
    'review' => 'journal',
    'monthStart' when !app.onboarded => 'onboarding',
    _ => 'home',
  };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.screen;
    return PopScope(
      canPop: s == 'home' || (s == 'onboarding' && !app.onboarded),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) app.go(_back(s, app));
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Backdrop(),
            // Keeps screen animations from repainting the backdrop, and vice versa.
            RepaintBoundary(
              child: switch (s) {
                'onboarding' => const Onboarding(),
                'monthStart' => const MonthStart(),
                'thought' => const Thought(),
                _ => const Shell(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
