import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/app/backdrop.dart';
import 'package:kakebo/app/shell.dart';
import 'package:kakebo/features/journal/thought.dart';
import 'package:kakebo/features/month_setup/month_start.dart';
import 'package:kakebo/features/onboarding/onboarding.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.screen;
    return PopScope(
      canPop: s == 'home' || (s == 'onboarding' && !app.onboarded),
      onPopInvokedWithResult: (didPop, _) {
        // The month review closes to the Diario, as its "← Diario" says; a tab other than Today goes to Today.
        if (!didPop) s == 'review' ? app.go('journal') : app.back();
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
