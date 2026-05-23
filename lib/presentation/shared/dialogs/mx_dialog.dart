import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';

/// Base MemoX dialog — consistent padding, title + optional icon, scrollable
/// content area, and a row of action buttons at the bottom.
class MxDialog extends StatelessWidget {
  const MxDialog({
    required this.title,
    required this.child,
    this.icon,
    this.actions = const [],
    this.maxWidth,
    super.key,
  });

  final String title;
  final IconData? icon;
  final Widget child;
  final List<Widget> actions;
  final double? maxWidth;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    IconData? icon,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) =>
          MxDialog(title: title, icon: icon, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dialogTheme = theme.dialogTheme;
    final titleStyle = dialogTheme.titleTextStyle ?? textTheme.headlineSmall;
    final contentStyle =
        dialogTheme.contentTextStyle ??
        textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant) ??
        DefaultTextStyle.of(
          context,
        ).style.copyWith(color: scheme.onSurfaceVariant);
    final titleWidget = icon != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(icon, size: AppIconSizes.xl, color: scheme.primary),
              ),
              const MxGap(AppSpacing.lg),
              Text(title, style: titleStyle, textAlign: TextAlign.center),
            ],
          )
        : Text(title, style: titleStyle);

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedMaxWidth = _resolveMaxWidth(context, constraints);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleWidget,
                    const MxGap(AppSpacing.md),
                    Flexible(
                      child: SingleChildScrollView(
                        child: DefaultTextStyle(
                          style: contentStyle,
                          child: child,
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const MxGap(AppSpacing.xxl),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        spacing: AppSpacing.sm,
                        overflowSpacing: AppSpacing.sm,
                        children: actions,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _resolveMaxWidth(BuildContext context, BoxConstraints constraints) {
    final themeInset = Theme.of(context).dialogTheme.insetPadding;
    final inset = themeInset ?? EdgeInsets.zero;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final viewportMaxWidth = math.max(0.0, viewportWidth - inset.horizontal);
    final availableWidth = constraints.hasBoundedWidth
        ? math.min(constraints.maxWidth, viewportMaxWidth)
        : viewportMaxWidth;
    final themeMaxWidth = maxWidth ?? context.dialogMaxWidth;
    if (!themeMaxWidth.isFinite) return availableWidth;
    return math.min(themeMaxWidth, availableWidth);
  }
}
