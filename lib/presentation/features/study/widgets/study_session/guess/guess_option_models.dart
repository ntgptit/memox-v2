import 'package:flutter/material.dart';

import '../../../../../../core/theme/extensions/theme_extensions.dart';

enum GuessOptionState { idle, error, success }

final class GuessOptionVisual {
  const GuessOptionVisual({
    required this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
  });

  final Color foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  static GuessOptionVisual resolve(
    BuildContext context,
    GuessOptionState state,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final mxColors = context.mxColors;
    return switch (state) {
      GuessOptionState.idle => GuessOptionVisual(
        foregroundColor: scheme.onSurfaceVariant,
      ),
      GuessOptionState.error => GuessOptionVisual(
        backgroundColor: scheme.errorContainer,
        borderColor: scheme.error,
        foregroundColor: scheme.onErrorContainer,
      ),
      GuessOptionState.success => GuessOptionVisual(
        backgroundColor: mxColors.successContainer,
        borderColor: mxColors.ratingEasy,
        foregroundColor: mxColors.onSuccessContainer,
      ),
    };
  }
}
