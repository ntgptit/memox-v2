import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'app/config/app_config.dart';
import 'app/config/env.dart';
import 'app/di/providers.dart';
import 'app/logging/app_talker.dart';
import 'app/router/app_router.dart';
import 'core/theme/responsive/app_breakpoints.dart';
import 'core/theme/responsive/app_layout.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens/app_spacing.dart';
import 'core/theme/tokens/app_typography.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/features/settings/providers/locale_notifier.dart';
import 'presentation/features/settings/providers/theme_mode_notifier.dart';

/// Upper bound for OS-level text scaling applied to MemoX. Above ~1.2 the bold
/// display/headline roles start blowing past line constraints on 412 dp phones.
const double _kMaxTextScaleFactor = 1.2;

Future<void> main() async {
  final talker = createAppTalker();
  late ProviderContainer container;

  await AppBootstrap.bootstrap(
    reportError: (error, stackTrace) {
      reportAppErrorToTalker(talker, error, stackTrace);
    },
    beforeRun: () async {
      final env = AppEnv.fromEnvironment();
      final config = AppConfig.fromEnv(env);
      configureAppTalker(talker, config);

      container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(env),
          appConfigProvider.overrideWithValue(config),
          talkerProvider.overrideWithValue(talker),
        ],
        observers: createAppProviderObservers(talker: talker, config: config),
      );

      final database = container.read(appDatabaseProvider);
      await database.ensureOpen();
      talker.info('MemoX bootstrap completed');
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
        final scaledTextTheme = AppTypography.scaledTextTheme(
          theme.textTheme,
          size,
        );
        final scaledPrimaryTextTheme = AppTypography.scaledTextTheme(
          theme.primaryTextTheme,
          size,
        );
        // Clamp system text scaling so OEM accessibility defaults (e.g. Samsung
        // One UI ships a 1.0–1.3 ramp) don't compound with bold display roles
        // and make chrome feel oversized on phones.
        final mediaQuery = MediaQuery.of(context);
        final clampedTextScaler = mediaQuery.textScaler.clamp(
          maxScaleFactor: _kMaxTextScaleFactor,
        );
        // Density override: tighten ListTile vertical rhythm on phone-class
        // viewports where the M3 standard density wastes ~4–8 dp per row.
        final isCompactMobile = AppLayout.isCompactMobileWidth(
          mediaQuery.size.width,
        );
        final listTileTheme = isCompactMobile
            ? theme.listTileTheme.copyWith(
                visualDensity: const VisualDensity(
                  horizontal: 0,
                  vertical: -1,
                ),
                minVerticalPadding: AppSpacing.xs,
              )
            : theme.listTileTheme;
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedTextScaler),
          child: Theme(
            data: theme.copyWith(
              textTheme: scaledTextTheme,
              primaryTextTheme: scaledPrimaryTextTheme,
              listTileTheme: listTileTheme,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
