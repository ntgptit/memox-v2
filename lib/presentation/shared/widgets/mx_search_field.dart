import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';

/// Rounded search input with leading search icon and optional clear affordance.
class MxSearchField extends StatefulWidget {
  const MxSearchField({
    this.controller,
    this.hintText,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.textInputAction = TextInputAction.search,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  @override
  State<MxSearchField> createState() => _MxSearchFieldState();
}

class _MxSearchFieldState extends State<MxSearchField> {
  TextEditingController? _internalController;
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final baseDecoration = const InputDecoration().applyDefaults(
      theme.inputDecorationTheme,
    );
    final focusedWidth =
        theme.inputDecorationTheme.focusedBorder is OutlineInputBorder
        ? (theme.inputDecorationTheme.focusedBorder as OutlineInputBorder)
              .borderSide
              .width
        : 2.0;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onChanged: (value) {
        widget.onChanged?.call(value);
        setState(() {});
      },
      onSubmitted: widget.onSubmitted,
      style: theme.textTheme.bodyLarge,
      decoration: baseDecoration.copyWith(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, size: AppIconSizes.lg),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                iconSize: AppIconSizes.md,
                tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                onPressed: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                  widget.onClear?.call();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderFull,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderFull,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderFull,
          borderSide: BorderSide(color: scheme.primary, width: focusedWidth),
        ),
        contentPadding:
            theme.inputDecorationTheme.contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
      ),
    );
  }
}
