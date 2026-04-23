import 'package:flutter/material.dart';

import '../../../core/theme/app_opacity.dart';
import '../../../core/theme/component_themes/focus_theme.dart';

/// Shared shaped tap surface for custom MemoX widgets.
///
/// Use this instead of hand-rolling `Material + InkWell` so hover, focus, and
/// pressed overlays always clip to the same shape that the user sees.
class MxTappable extends StatelessWidget {
  const MxTappable({
    required this.shape,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.semanticsLabel,
    this.backgroundColor,
    this.overlayBaseColor,
    super.key,
  });

  final ShapeBorder shape;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final String? semanticsLabel;
  final Color? backgroundColor;
  final Color? overlayBaseColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isButton = onTap != null || onLongPress != null;
    final canInteract = enabled && isButton;

    return Semantics(
      button: isButton,
      enabled: canInteract,
      label: semanticsLabel,
      child: Material(
        color:
            backgroundColor ??
            scheme.surface.withValues(alpha: AppOpacity.transparent),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: canInteract
            ? InkWell(
                customBorder: shape,
                focusNode: focusNode,
                autofocus: autofocus,
                overlayColor: AppFocus.overlayProperty(
                  overlayBaseColor ?? scheme.onSurface,
                ),
                onTap: onTap,
                onLongPress: onLongPress,
                child: child,
              )
            : child,
      ),
    );
  }
}
