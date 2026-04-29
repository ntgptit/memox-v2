import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../widgets/mx_primary_button.dart';
import '../layouts/mx_gap.dart';
import '../widgets/mx_text.dart';

/// Standardized empty-state placeholder with illustration slot, title, body,
/// and an optional call-to-action.
class MxEmptyState extends StatelessWidget {
  const MxEmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.actionLeadingIcon,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionLeadingIcon;

  static const double _maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? math.min(constraints.maxWidth, _maxWidth)
              : _maxWidth;

          return SizedBox(
            width: width,
            child: Padding(
              padding: AppSpacing.screen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, // guard:raw-size-reviewed illustration circle
                    height: 72, // guard:raw-size-reviewed illustration circle
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: AppRadius.borderFull,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: AppIconSizes.xl,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const MxGap(AppSpacing.xl),
                  MxText(
                    title,
                    role: MxTextRole.stateTitle,
                    textAlign: TextAlign.center,
                  ),
                  if (message != null) ...[
                    const MxGap(AppSpacing.sm),
                    MxText(
                      message!,
                      role: MxTextRole.stateMessage,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (actionLabel != null && onAction != null) ...[
                    const MxGap(AppSpacing.xl),
                    MxPrimaryButton(
                      label: actionLabel!,
                      leadingIcon: actionLeadingIcon,
                      onPressed: onAction,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
