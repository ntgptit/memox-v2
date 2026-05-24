import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// Compact destination chip showing which deck a new card belongs to.
///
/// Per Design System "05 · Create card", the pill confirms the routing target
/// (read-only when [onTap] is null) so the author always knows where the card
/// is being saved.
class MxDeckPill extends StatelessWidget {
  const MxDeckPill({
    required this.deckName,
    this.icon = Icons.layers_outlined,
    this.onTap,
    super.key,
  });

  final String deckName;
  final IconData icon;

  /// When non-null, renders a trailing chevron and routes taps. Leave null for
  /// a read-only badge.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isInteractive = onTap != null;
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderFull,
      side: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: AppOpacity.ghostBorder),
      ),
    );

    return MxTappable(
      shape: shape,
      backgroundColor: scheme.surfaceContainerLowest,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: MxText(
                deckName,
                role: MxTextRole.tileTrailing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isInteractive) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: AppIconSizes.sm,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: AppIconSizes.lg,
      height: AppIconSizes.lg,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: AppOpacity.disabledSurface),
        borderRadius: AppRadius.borderSm,
      ),
      child: Icon(icon, size: AppIconSizes.sm, color: scheme.primary),
    );
  }
}
