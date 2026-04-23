import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/mx_gap.dart';
import 'mx_text.dart';
import 'mx_tappable.dart';

enum MxAvatarSize { sm, md, lg, xl }

/// Circular avatar with optional image, initials fallback, and an optional
/// "Plus"-style badge pill rendered to the right. Matches the Quizlet-style
/// profile/owner row used in study-set listings.
class MxAvatar extends StatelessWidget {
  const MxAvatar({
    this.imageUrl,
    this.initials,
    this.size = MxAvatarSize.md,
    this.badgeLabel,
    this.onTap,
    super.key,
  });

  final String? imageUrl;
  final String? initials;
  final MxAvatarSize size;

  /// Optional pill shown next to the avatar (e.g. `Plus`). Keep it short.
  final String? badgeLabel;
  final VoidCallback? onTap;

  double get _diameter => switch (size) {
    MxAvatarSize.sm => AppIconSizes.lg,
    MxAvatarSize.md => AppIconSizes.xl,
    MxAvatarSize.lg => AppIconSizes.xxl,
    MxAvatarSize.xl => AppIconSizes.xxxl,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final avatarContent = SizedBox(
      width: _diameter,
      height: _diameter,
      child: imageUrl != null
          ? Image.network(imageUrl!, fit: BoxFit.cover)
          : Center(
              child: MxText(_resolvedInitials, role: MxTextRole.avatarInitials),
            ),
    );

    final tappable = onTap == null
        ? ClipOval(
            child: ColoredBox(
              color: scheme.surfaceContainerHigh,
              child: avatarContent,
            ),
          )
        : MxTappable(
            shape: const CircleBorder(),
            onTap: onTap,
            backgroundColor: scheme.surfaceContainerHigh,
            child: avatarContent,
          );

    if (badgeLabel == null) return tappable;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tappable,
        const MxGap(AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderFull,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: MxText(badgeLabel!, role: MxTextRole.badge),
        ),
      ],
    );
  }

  String get _resolvedInitials {
    final value = (initials ?? '').trim();
    if (value.isEmpty) return '?';
    return value.length <= 2
        ? value.toUpperCase()
        : value.substring(0, 2).toUpperCase();
  }
}
