import 'package:flutter/material.dart';

import 'package:kakebo/app/app_scope.dart';

/// Botanical paper gives Home, the diary and breathing a quiet, continuous backdrop.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key});

  static const _quiet = {'home', 'journal', 'thought'};

  @override
  Widget build(BuildContext context) {
    final app = AppScope.watch(context);
    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          // The paper is baked to the app's bg (tool/art.py): it can end mid-screen or fade out and only the plum branch goes.
          // Keep the branch visible, softening it behind the reading area.
          child: AnimatedOpacity(
            opacity: _quiet.contains(app.screen) ? .7 : 0,
            duration: const Duration(milliseconds: 400),
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, app.screen == 'thought' ? Colors.white : const Color(0x88FFFFFF)],
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
