import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';

/// Botanical paper behind every screen, still while the content scrolls over it (the intro covers it with its own prints).
class Backdrop extends StatelessWidget {
  const Backdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final thought = AppScope.watch(context).screen == 'thought';
    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          // The paper is baked to the app's bg (tool/art.py), so only the plum branch shows. It stays whole behind the
          // evening thought and softens behind the reading area everywhere else, lists and grids included.
          child: Opacity(
            opacity: .7,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, thought ? Colors.white : const Color(0x88FFFFFF)],
                stops: const [0.1, 0.5],
              ).createShader(bounds),
              child: Image.asset('assets/art/paper.webp', fit: BoxFit.fitWidth, alignment: Alignment.topCenter),
            ),
          ),
        ),
      ),
    );
  }
}
