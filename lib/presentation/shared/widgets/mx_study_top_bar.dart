import 'package:flutter/material.dart';

import '../../../core/utils/string_utils.dart';
import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';

/// Accent palette for [MxStudyTopBar] driven by the active study mode.
enum MxStudyTopBarTone { primary, mastery, accent }

/// Top bar used by Match / Guess / Recall / Fill study screens.
///
/// Layout per Design System UI kit (`StudyTopBar`):
/// `[close] [MODE-pill] [progress] [n/total]`.
class MxStudyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MxStudyTopBar({
    required this.mode,
    required this.current,
    required this.total,
    this.tone = MxStudyTopBarTone.primary,
    this.onClose,
    super.key,
  });

  /// Short uppercase label, e.g. `MATCH`, `RECALL`.
  final String mode;
  final int current;
  final int total;
  final MxStudyTopBarTone tone;
  final VoidCallback? onClose;

  /// guard:raw-size-reviewed Top bar height matches Material AppBar tonal
  /// behaviour while keeping the lighter feel from the Design System.
  static const double _height = 48;

  /// guard:raw-size-reviewed Progress track height per Design System spec.
  static const double _progressHeight = 4;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  Color _accent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mx = context.mxColors;
    return switch (tone) {
      MxStudyTopBarTone.primary => scheme.primary,
      MxStudyTopBarTone.mastery => mx.mastery,
      MxStudyTopBarTone.accent => mx.streak,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _accent(context);
    final progress = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                iconSize: AppIconSizes.md,
                onPressed: onClose,
                color: scheme.onSurface,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
              const MxGap(AppSpacing.xs),
              _ModePill(label: mode, accent: accent),
              const MxGap(AppSpacing.sm),
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.borderFull,
                  child: LinearProgressIndicator(
                    value: progress,
                    color: accent,
                    backgroundColor: scheme.surfaceContainer,
                    minHeight: _progressHeight,
                  ),
                ),
              ),
              const MxGap(AppSpacing.sm),
              Text(
                '$current / $total',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: AppOpacity.disabledSurface),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          StringUtils.upperCaseToEmpty(label),
          style: textTheme.labelSmall?.copyWith(
            color: accent,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
