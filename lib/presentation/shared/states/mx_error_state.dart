import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../widgets/mx_secondary_button.dart';
import '../layouts/mx_gap.dart';
import '../widgets/mx_text.dart';

/// Error state with optional "Retry" action and collapsible detail.
class MxErrorState extends StatefulWidget {
  const MxErrorState({
    this.title,
    this.message,
    this.details,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final String? details;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  State<MxErrorState> createState() => _MxErrorStateState();
}

class _MxErrorStateState extends State<MxErrorState> {
  static const double _maxWidth = 420;

  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

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
                      color: scheme.errorContainer,
                      borderRadius: AppRadius.borderFull,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      size: AppIconSizes.xl,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const MxGap(AppSpacing.xl),
                  MxText(
                    widget.title ?? l10n.sharedErrorTitle,
                    role: MxTextRole.stateTitle,
                    textAlign: TextAlign.center,
                  ),
                  if (widget.message != null) ...[
                    const MxGap(AppSpacing.sm),
                    MxText(
                      widget.message!,
                      role: MxTextRole.stateMessage,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const MxGap(AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.sm,
                    alignment: WrapAlignment.center,
                    children: [
                      if (widget.onRetry != null)
                        MxSecondaryButton(
                          label: widget.retryLabel ?? l10n.sharedTryAgain,
                          variant: MxSecondaryVariant.outlined,
                          leadingIcon: Icons.refresh,
                          onPressed: widget.onRetry,
                        ),
                      if (widget.details != null)
                        MxSecondaryButton(
                          label: _showDetails
                              ? l10n.sharedHideDetails
                              : l10n.sharedShowDetails,
                          variant: MxSecondaryVariant.text,
                          onPressed: () =>
                              setState(() => _showDetails = !_showDetails),
                        ),
                    ],
                  ),
                  if (_showDetails && widget.details != null) ...[
                    const MxGap(AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: MxText(
                        widget.details!,
                        role: MxTextRole.formHelper,
                      ),
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
