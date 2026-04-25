import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';

/// Themed modal bottom sheet with a centered drag handle, a title row, and
/// an optional action area.
class MxBottomSheet extends StatelessWidget {
  const MxBottomSheet({
    required this.child,
    this.title,
    this.trailing,
    this.padding = AppSpacing.sheet,
    super.key,
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: (_) =>
          MxBottomSheet(title: title, trailing: trailing, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const MxGap(AppSpacing.lg),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
