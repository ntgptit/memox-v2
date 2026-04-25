import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_motion.dart';

/// MemoX-flavored [AnimatedSwitcher].
///
/// Centralises the duration + curve choice so features get consistent fade
/// behaviour and never need to import `app_motion.dart` directly (the guard
/// rule `feature_theme_token_imports` keeps tokens out of feature code).
class MxAnimatedSwitcher extends StatelessWidget {
  const MxAnimatedSwitcher({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.stateChange,
      switchInCurve: AppCurves.standardDecelerate,
      switchOutCurve: AppCurves.standardAccelerate,
      child: child,
    );
  }
}
