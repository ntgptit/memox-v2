import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../presentation/features/folders/screens/library_overview_screen.dart';
import '../presentation/shared/layouts/mx_adaptive_scaffold.dart';

/// Root navigation shell.
///
/// Owns the single [MxAdaptiveScaffold] for the whole app so every top-level
/// destination (Home / Library / Progress / Settings) shares the same
/// adaptive nav surface — bottom bar on compact, rail on medium+, extended
/// rail on large+.
class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const int _libraryTabIndex = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedIndex = navigationShell.currentIndex;

    return MxAdaptiveScaffold(
      destinations: [
        MxAdaptiveDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.homeTitle,
        ),
        MxAdaptiveDestination(
          icon: const Icon(Icons.folder_outlined),
          selectedIcon: const Icon(Icons.folder),
          label: l10n.libraryTitle,
        ),
        MxAdaptiveDestination(
          icon: const Icon(Icons.show_chart_outlined),
          selectedIcon: const Icon(Icons.show_chart),
          label: l10n.progressTitle,
        ),
        MxAdaptiveDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
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
      floatingActionButton: selectedIndex == _libraryTabIndex
          ? buildLibraryOverviewFab(context, ref)
          : null,
      body: navigationShell,
    );
  }
}
