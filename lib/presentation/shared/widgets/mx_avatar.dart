import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/utils/string_utils.dart';
import '../layouts/mx_gap.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

enum MxAvatarSize { sm, md, lg, xl, profile }

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
    MxAvatarSize.profile => AppIconSizes.massive + AppSpacing.xl,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final avatarContent = SizedBox(
      width: _diameter,
      height: _diameter,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  _InitialsFallback(initials: _resolvedInitials),
            )
          : _InitialsFallback(initials: _resolvedInitials),
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
    final parts = StringUtils.normalizeSpaceToEmpty(
      initials,
    ).split(' ').where((part) => part.isNotEmpty).toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return StringUtils.uppercased(parts.first.substring(0, 1));
    }
    return StringUtils.uppercased(
      '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}',
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) =>
      Center(child: MxText(initials, role: MxTextRole.avatarInitials));
}
