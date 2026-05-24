import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../presentation/shared/layouts/mx_adaptive_scaffold.dart';

/// Root navigation shell.
///
/// Owns the single [MxAdaptiveScaffold] for the whole app so every top-level
/// destination (Home / Library / Progress / Settings) shares the same
/// adaptive nav surface — bottom bar on compact, rail on medium+, extended
/// rail on large+.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    this.hideNavigation = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool hideNavigation;

  @override
  Widget build(BuildContext context) {
    if (hideNavigation) {
      return navigationShell;
    }

    final l10n = AppLocalizations.of(context);
    final selectedIndex = navigationShell.currentIndex;

    return MxAdaptiveScaffold(
      destinations: [
        MxAdaptiveDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.homeTitle,
        ),
        MxAdaptiveDestination(
          icon: Icons.folder_outlined,
          selectedIcon: Icons.folder,
          label: l10n.libraryTitle,
        ),
        MxAdaptiveDestination(
          icon: Icons.show_chart_outlined,
          selectedIcon: Icons.show_chart,
          label: l10n.progressTitle,
        ),
        MxAdaptiveDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: l10n.settingsTitle,
        ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == selectedIndex,
        );
      },
      constrainBody: false,
      body: navigationShell,
    );
  }
}
