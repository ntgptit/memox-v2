import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_action_button.dart';

/// Consistent layout for card-level actions. Takes a [primary] action and an
/// optional [secondary] one and arranges them so the primary reads as the
/// stronger action while neither becomes an oversized full-width hero block.
///
/// - Wide enough: a trailing-aligned row (`secondary`, then `primary`).
/// - Narrow: stacks vertically, primary on top, both intrinsic-width and
///   trailing-aligned — never stretched edge to edge.
///
/// Use [MxActionIntent.cardPrimary] / [MxActionIntent.cardSecondary] for the
/// passed buttons. See `docs/ui-ux/action-hierarchy-contract.md`.
class MxCardActions extends StatelessWidget {
  const MxCardActions({required this.primary, this.secondary, super.key});

  final MxActionButton primary;
  final MxActionButton? secondary;

  @override
  Widget build(BuildContext context) {
    final secondaryAction = secondary;
    if (secondaryAction == null) {
      return Align(alignment: AlignmentDirectional.centerEnd, child: primary);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacks = AppLayout.stacksCardActions(
          hasBoundedWidth: constraints.hasBoundedWidth,
          maxWidth: constraints.maxWidth,
        );

        if (stacks) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              primary,
              const MxGap(AppSpacing.sm),
              secondaryAction,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            secondaryAction,
            const MxGap(AppSpacing.sm),
            primary,
          ],
        );
      },
    );
  }
}
