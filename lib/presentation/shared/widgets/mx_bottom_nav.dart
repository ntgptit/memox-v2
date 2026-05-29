import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import '../layouts/mx_space.dart';
import '../motion/mx_motion.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// Floating bottom navigation bar per Design System.
///
/// Mock spec:
/// - Wrapper aligns to the page gutter + bottom inset so the bar floats
///   above the page rather than running edge-to-edge.
/// - Bar itself: rounded surface with a ghost outline.
/// - Active destination renders the icon inside a tonal "pill" — the label
///   below it tints to primary. Inactive items stay onSurfaceVariant.
///
/// Use this through [MxAdaptiveScaffold] — feature screens should not embed
/// the bar directly.
class MxBottomNav extends StatelessWidget {
  const MxBottomNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<MxBottomNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: MxSpace.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          MxSpace.xs,
          AppSpacing.lg,
          MxSpace.xs,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderXl,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _mxBottomNavBlurSigma,
              sigmaY: _mxBottomNavBlurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(
                  alpha: AppOpacity.surfaceGlass,
                ),
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: scheme.outlineVariant.withValues(
                    alpha: AppOpacity.ghostBorder,
                  ),
                ),
              ),
              child: SizedBox(
                key: const ValueKey('mx-bottom-nav-bar'),
                height: _mxBottomNavBarHeight,
                child: Row(
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Expanded(
                        child: _MxBottomNavItem(
                          destination: destinations[i],
                          isSelected: i == selectedIndex,
                          onTap: () => onDestinationSelected(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Destination payload for [MxBottomNav].
@immutable
class MxBottomNavDestination {
  const MxBottomNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

// guard:raw-size-reviewed bar height matches Design System mock (64 dp)
const double _mxBottomNavBarHeight = 64;

// guard:raw-size-reviewed glass chrome blur mirrors the Design System preview.
const double _mxBottomNavBlurSigma = 18;

class _MxBottomNavItem extends StatelessWidget {
  const _MxBottomNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final MxBottomNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isSelected ? scheme.primary : scheme.onSurfaceVariant;
    return MxTappable(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      onTap: onTap,
      semanticsLabel: destination.label,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MxBottomNavIconPill(
            icon: isSelected ? destination.selectedIcon : destination.icon,
            isActive: isSelected,
            color: foreground,
          ),
          const MxGap(MxSpace.xxs),
          MxText(
            destination.label,
            role: MxTextRole.badge,
            color: foreground,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

class _MxBottomNavIconPill extends StatelessWidget {
  const _MxBottomNavIconPill({
    required this.icon,
    required this.isActive,
    required this.color,
  });

  final IconData icon;
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pillColor = isActive
        ? scheme.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? AppOpacity.navigationSelectedPillDark
                : AppOpacity.navigationSelectedPillLight,
          )
        : null;
    return AnimatedContainer(
      duration: MxDurations.stateChange,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: AppRadius.borderFull,
      ),
      child: Icon(icon, color: color, size: AppIconSizes.md),
    );
  }
}
