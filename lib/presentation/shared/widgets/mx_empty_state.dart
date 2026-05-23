import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_primary_button.dart';
import 'mx_text.dart';

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
    final illustrationSize = AppLayout.stateIllustrationSize(context);
    final majorGap = context.isCompactMobile ? AppSpacing.lg : AppSpacing.xl;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? math.min(constraints.maxWidth, _maxWidth)
              : _maxWidth;

          return SizedBox(
            width: width,
            child: Padding(
              padding: AppLayout.usesDenseEmptyStatePadding(width)
                  ? AppSpacing.screenVertical
                  : AppSpacing.screen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: illustrationSize,
                    height: illustrationSize,
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
                  MxGap(majorGap),
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
                    MxGap(majorGap),
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
