import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/extensions/theme_extensions.dart';
import 'mx_card.dart';
import '../layouts/mx_gap.dart';

/// Daily-streak surface with the flame icon, streak count, encouragement
/// line, and a compact 7-day row. Used on the profile tab.
class MxStreakCard extends StatelessWidget {
  const MxStreakCard({
    required this.streakCount,
    required this.streakUnit,
    required this.encouragement,
    required this.weekDays,
    required this.weekDates,
    required this.activeIndices,
    super.key,
  });

  /// Numeric streak count (e.g. `11`).
  final int streakCount;

  /// Localized unit noun, e.g. `tuần` or `days`.
  final String streakUnit;

  /// Pre-localized encouragement line (e.g. "Hãy học vào tuần tới...").
  final String encouragement;

  /// Labels for the 7 columns, in order (`S M T W T F S`).
  final List<String> weekDays;

  /// Day-of-month numbers for each column.
  final List<int> weekDates;

  /// Indices (0..6) of days that should render as "active" (studied).
  final Set<int> activeIndices;

  @override
  Widget build(BuildContext context) {
    assert(weekDays.length == 7 && weekDates.length == 7);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final custom = context.mxColors;
    final l10n = AppLocalizations.of(context);

    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(
            '${l10n.sharedStreakLabel} $streakCount $streakUnit',
            style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
          ),
          const MxGap(AppSpacing.lg),
          Icon(
            Icons.local_fire_department,
            size: AppIconSizes.xxxl,
            color: custom.streak,
          ),
          const MxGap(AppSpacing.lg),
          Text(
            encouragement,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const MxGap(AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in weekDays)
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const MxGap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.borderFull,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  _StreakDay(
                    date: weekDates[i],
                    active: activeIndices.contains(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.date, required this.active});

  final int date;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$date',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        ),
        const MxGap(AppSpacing.xxs),
        SizedBox(
          width: AppSpacing.xs, // guard:raw-size-reviewed streak dot slot width
          height:
              AppSpacing.xs, // guard:raw-size-reviewed streak dot slot height
          child: active
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.mxColors.streak,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
