import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_opacity.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/widgets/mx_tappable.dart';

/// Compact indigo-tinted info banner for the Bulk add screen.
///
/// The shared [MxBanner] uses the larger teal `info` container; Bulk add 05d
/// asks for a smaller primary-tinted strip, so this is a screen-specific
/// composite rather than a global banner tone change.
class BulkAddInfoBanner extends StatelessWidget {
  const BulkAddInfoBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: AppOpacity.hover),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: scheme.primary.withValues(alpha: AppOpacity.disabledSurface),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: AppIconSizes.sm,
            color: scheme.primary,
          ),
          const MxGap(AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stadium-shaped separator pill used by the Bulk add paste tab.
class BulkAddSeparatorPill extends StatelessWidget {
  const BulkAddSeparatorPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// guard:raw-size-reviewed pill height matches Design System mock 05d.
  static const double _pillHeight = 32;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bg = selected ? scheme.primary : scheme.surfaceContainerLowest;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return MxTappable(
      shape: selected
          ? const StadiumBorder()
          : StadiumBorder(
              side: BorderSide(
                color: scheme.outlineVariant.withValues(
                  alpha: AppOpacity.disabledSurface,
                ),
              ),
            ),
      backgroundColor: bg,
      onTap: onTap,
      child: SizedBox(
        height: _pillHeight,
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// guard:raw-size-reviewed minimum tab pill width per Design mock 05d.
/// Fits "Preview" + 2-digit count badge with breathing room and keeps the
/// Paste tab visually equal-width to the Preview tab.
const double _kBulkAddTabBaseSize = 96;

/// Custom pill tab bar for Bulk add (mock `05d`).
///
/// Material's [SegmentedButton] fills both segments with a tonal background in
/// dark theme, which fights the mock's "single primary pill in a tonal track"
/// language. This composite renders the exact shape.
class BulkAddTabs extends StatelessWidget {
  const BulkAddTabs({
    required this.pasteLabel,
    required this.previewLabel,
    required this.previewCount,
    required this.selectedPaste,
    required this.onChanged,
    super.key,
  });

  final String pasteLabel;
  final String previewLabel;
  final int previewCount;
  final bool selectedPaste;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: _kBulkAddTabBaseSize),
            child: _TabPill(
              label: pasteLabel,
              selected: selectedPaste,
              onTap: () => onChanged(true),
            ),
          ),
          const MxGap(AppSpacing.xxs),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: _kBulkAddTabBaseSize),
            child: _TabPill(
              label: previewLabel,
              count: previewCount,
              selected: !selectedPaste,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fg = selected ? scheme.onSurface : scheme.onSurfaceVariant;
    return MxTappable(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      backgroundColor: selected ? scheme.surfaceContainerLowest : null,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count != null) ...[
              const MxGap(AppSpacing.sm),
              _CountBadge(count: count!, selected: selected),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  /// guard:raw-size-reviewed badge vertical padding for tabular count chip.
  static const double _vPad = 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fg = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: _vPad,
      ),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: AppOpacity.ghostBorder)
            : scheme.onSurfaceVariant.withValues(alpha: AppOpacity.hover),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        count.toString(),
        style: textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
