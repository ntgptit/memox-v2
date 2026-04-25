import 'package:flutter/material.dart';

import '../../../../../../core/theme/extensions/theme_extensions.dart';

enum MatchTileSide { left, right }

enum MatchTileState { idle, selected, error, success, matched }

final class MatchTileVisual {
  const MatchTileVisual({
    required this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
  });

  final Color foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  static MatchTileVisual resolve(
    BuildContext context,
    MatchTileState state,
    MatchTileSide side,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final mxColors = context.mxColors;
    return switch (state) {
      MatchTileState.idle => MatchTileVisual(
        foregroundColor: side == MatchTileSide.left
            ? scheme.onSurface
            : scheme.onSurfaceVariant,
      ),
      MatchTileState.selected => MatchTileVisual(
        backgroundColor: scheme.primaryContainer,
        borderColor: scheme.primary,
        foregroundColor: scheme.onPrimaryContainer,
      ),
      MatchTileState.error => MatchTileVisual(
        backgroundColor: scheme.errorContainer,
        borderColor: scheme.error,
        foregroundColor: scheme.onErrorContainer,
      ),
      MatchTileState.success => MatchTileVisual(
        backgroundColor: mxColors.successContainer,
        borderColor: mxColors.ratingEasy,
        foregroundColor: mxColors.onSuccessContainer,
      ),
      MatchTileState.matched => MatchTileVisual(
        backgroundColor: mxColors.successContainer,
        borderColor: mxColors.ratingEasy,
        foregroundColor: mxColors.onSuccessContainer,
      ),
    };
  }
}
