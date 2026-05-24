import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/utils/string_utils.dart';
import '../layouts/mx_gap.dart';
import '../layouts/mx_space.dart';
import 'mx_icon_button.dart';
import 'mx_text.dart';

/// Visual accent role for the [MxStudyTopBar] mode badge + progress bar.
///
/// Mirrors the mock's two-tone scheme: indigo primary for Review/Match/Guess,
/// mastery-green for Recall/Fill (study modes that exercise recall).
enum MxStudyTopBarAccent { primary, mastery }

const _studyTopBarBadgeRadius = AppRadius.borderFull;
const _studyTopBarProgressHeight = AppSpacing.xs;
const _studyTopBarBadgeFillAlpha = AppOpacity.disabledSurface;

/// Slim study-mode top bar.
///
/// Mock 06–10: a close (X) button, an uppercase mode badge pill, a thin
/// progress track filling the remaining width, and a "current / total"
/// counter on the right. Replaces the standard `AppBar` title+actions for
/// the study session shell so the experience reads as immersive practice.
class MxStudyTopBar extends StatelessWidget {
  const MxStudyTopBar({
    required this.modeLabel,
    required this.accent,
    required this.progressValue,
    required this.counterLabel,
    required this.onClose,
    this.closeTooltip,
    super.key,
  });

  final String modeLabel;
  final MxStudyTopBarAccent accent;
  final double progressValue;
  final String counterLabel;
  final VoidCallback? onClose;
  final String? closeTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentColor = switch (accent) {
      MxStudyTopBarAccent.primary => scheme.primary,
      MxStudyTopBarAccent.mastery => context.mxColors.mastery,
    };
    final accentFill = accentColor.withValues(alpha: _studyTopBarBadgeFillAlpha);
    final trackColor = scheme.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.md,
        vertical: MxSpace.xs,
      ),
      child: Row(
        children: [
          MxIconButton.toolbar(
            icon: Icons.close_rounded,
            tooltip: closeTooltip,
            onPressed: onClose,
          ),
          const MxGap(MxSpace.xs),
          _MxStudyModeBadge(
            label: modeLabel,
            accentColor: accentColor,
            background: accentFill,
          ),
          const MxGap(MxSpace.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: _studyTopBarBadgeRadius,
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                minHeight: _studyTopBarProgressHeight,
                color: accentColor,
                backgroundColor: trackColor,
              ),
            ),
          ),
          const MxGap(MxSpace.sm),
          MxText(
            counterLabel,
            role: MxTextRole.studyProgress,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _MxStudyModeBadge extends StatelessWidget {
  const _MxStudyModeBadge({
    required this.label,
    required this.accentColor,
    required this.background,
  });

  final String label;
  final Color accentColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: _studyTopBarBadgeRadius,
        border: Border.all(
          color: accentColor.withValues(alpha: AppOpacity.ghostBorder),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: MxText(
          StringUtils.uppercased(label),
          role: MxTextRole.overline,
          color: accentColor,
        ),
      ),
    );
  }
}
