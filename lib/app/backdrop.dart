import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/shared/theme/color.dart';
import 'package:kakebo/shared/theme/seasons.dart';

/// Seasonal wash behind every screen: a soft sun, an ink plum branch, two petals.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    final s = app.season;
    Widget circle(double size, Color c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c),
    );
    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Stack(
            children: [
              Positioned(top: -150, right: -130, child: circle(400, s.soft.withValues(alpha: .85))),
              // Pre-baked by tool/wash.dart: grayscale, contrast, radial fade and 22% opacity.
              Positioned(top: -30, right: -70, width: 320, height: 460, child: Image.asset('assets/art/ink_plum_wash.png', fit: BoxFit.fill)),
              Positioned(top: 150, right: 70, child: circle(16, s.bloom.withValues(alpha: .8))),
              Positioned(top: 200, right: 36, child: circle(8, s.bloom.withValues(alpha: .8))),
              Positioned(bottom: -190, left: -170, child: circle(440, ok(.93, .04, 150, .7))),
            ],
          ),
        ),
      ),
    );
  }
}
