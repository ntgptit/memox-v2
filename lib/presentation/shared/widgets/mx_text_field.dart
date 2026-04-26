import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import 'mx_text.dart';

enum MxTextFieldVariant { outlined, borderless }

/// Themed text input with label, helper text, error state, and optional
/// leading/trailing icons.
class MxTextField extends StatelessWidget {
  const MxTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.validator,
    this.textCapitalization = TextCapitalization.sentences,
    this.variant = MxTextFieldVariant.outlined,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textRole,
    this.expands = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final MxTextFieldVariant variant;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final MxTextRole? textRole;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = textRole == null
        ? textTheme.bodyLarge
        : MxTextStyles.resolve(context, textRole!);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      expands: expands,
      maxLines: expands ? null : (obscureText ? 1 : maxLines),
      minLines: expands ? null : minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      style: style,
      decoration: _decoration(),
    );
  }

  InputDecoration _decoration() {
    if (variant == MxTextFieldVariant.borderless) {
      return InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppIconSizes.md)
            : null,
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: AppIconSizes.md)
          : null,
      suffixIcon: suffixIcon,
    );
  }
}
