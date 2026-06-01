import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import '../motion/mx_motion.dart';
import '../widgets/mx_tappable.dart';
import '../widgets/mx_text.dart';

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

  static const double _handleWidth = 40;
  static const double _handleHeight = 4;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (_) =>
        MxBottomSheet(title: title, trailing: trailing, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = AppLocalizations.of(context);

    return AnimatedPadding(
      duration: MxDurations.quickTransition,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MxBottomSheetDragHandle(
                  label: l10n.bottomSheetDragHandleLabel,
                ),
                if (title != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: MxText(
                          title!,
                          role: MxTextRole.sheetTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                  const MxGap(AppSpacing.lg),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    child: SizedBox(width: double.infinity, child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MxBottomSheetDragHandle extends StatelessWidget {
  const _MxBottomSheetDragHandle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: MxTappable(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderFull),
        semanticsLabel: label,
        showOverlay: false,
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: MxBottomSheet._handleWidth,
          height: MxBottomSheet._handleHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(
                alpha: AppOpacity.handle,
              ),
              borderRadius: AppRadius.borderFull,
            ),
          ),
        ),
      ),
    );
  }
}
