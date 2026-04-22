import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'app/di/providers.dart';
import 'app/router/app_router.dart';
import 'core/theme/app_breakpoints.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/features/settings/providers/locale_notifier.dart';
import 'presentation/features/settings/providers/theme_mode_notifier.dart';

Future<void> main() async {
  final container = ProviderContainer();

  await AppBootstrap.bootstrap(
    beforeRun: () async {
      final database = container.read(appDatabaseProvider);
      await database.ensureOpen();
    },
    builder: () => UncontrolledProviderScope(
      container: container,
      child: const MemoxApp(),
    ),
  );
}

/// Root widget of the MemoX app.
///
/// Wires the theme (light + dark + reactive theme mode), the localization
/// delegates, the optional locale override, and the root router config.
class MemoxApp extends ConsumerWidget {
  const MemoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDebugBanner = ref.watch(
      appConfigProvider.select((config) => config.showDebugBanner),
    );
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: showDebugBanner,
      routerConfig: router,
      // Responsive typography: rescale display/headline for the active window
      // size. Done once here, not in features — every shared widget reading
      // `Theme.of(context).textTheme.*` picks up the scaled styles for free.
      builder: (context, child) {
        final size = context.windowSize;
        final theme = Theme.of(context);
        final scaled = AppTypography.scaledTextTheme(theme.textTheme, size);
        return Theme(
          data: theme.copyWith(textTheme: scaled),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
