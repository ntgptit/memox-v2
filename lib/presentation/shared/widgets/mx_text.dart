import 'package:flutter/material.dart';

enum MxTextRole {
  displayLarge,
  pageTitle,
  pageGreeting,
  heroAccent,
  sectionTitle,
  sectionSubtitle,
  tileTitle,
  tileMeta,
  tileTrailing,
  listTitle,
  listSubtitle,
  badge,
  reviewProgress,
  stateTitle,
  stateMessage,
  formLabel,
  formHelper,
  breadcrumb,
  contentBody,
  reviewFront,
  reviewBack,
  avatarInitials,
}

abstract final class MxTextStyles {
  static TextStyle resolve(BuildContext context, MxTextRole role) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return switch (role) {
      MxTextRole.displayLarge => textTheme.displayMedium!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.pageTitle => textTheme.titleLarge!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.pageGreeting => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.heroAccent => textTheme.titleMedium!.copyWith(
        color: scheme.primary,
      ),
      MxTextRole.sectionTitle => textTheme.titleMedium!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.sectionSubtitle => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.tileTitle => textTheme.titleMedium!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.tileMeta => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.tileTrailing => textTheme.labelLarge!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.listTitle => textTheme.titleMedium!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.listSubtitle => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.badge => textTheme.labelSmall!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.reviewProgress => textTheme.labelLarge!.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      MxTextRole.stateTitle => textTheme.titleLarge!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.stateMessage => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.formLabel => textTheme.labelLarge!.copyWith(
        color: scheme.onSurface,
      ),
      MxTextRole.formHelper => textTheme.bodySmall!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.breadcrumb => textTheme.labelLarge!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.contentBody => textTheme.bodyMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      MxTextRole.reviewFront => textTheme.headlineMedium!.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      MxTextRole.reviewBack => textTheme.titleLarge!.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      MxTextRole.avatarInitials => textTheme.labelMedium!.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    };
  }
}

class MxText extends StatelessWidget {
  const MxText(
    this.data, {
    required this.role,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    super.key,
  });

  final String data;
  final MxTextRole role;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    var style = MxTextStyles.resolve(context, role);
    if (color != null) {
      style = style.copyWith(color: color);
    }

    return Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
