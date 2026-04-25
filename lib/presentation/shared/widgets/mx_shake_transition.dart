import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Horizontal shake transition driven by an animation value from 0 to 1.
class MxShakeTransition extends StatelessWidget {
  const MxShakeTransition({
    required this.animation,
    required this.child,
    this.distance = 8,
    this.cycles = 3,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final double distance;
  final int cycles;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final dx =
            math.sin(animation.value * math.pi * cycles * 2) *
            distance *
            (1 - animation.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
