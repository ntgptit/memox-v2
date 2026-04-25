import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/locale_notifier.dart';
import 'package:memox/presentation/features/settings/providers/theme_mode_notifier.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets('DT1 onOpen: renders settings page with default controls', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('DT1 onDisplay: shows theme and language sections', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('DT1 onUpdate: updates theme and locale providers from segmented controls', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _TestApp(child: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(find.text('Settings updated.'), findsOneWidget);

    await tester.tap(find.text('Vietnamese'));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('vi'));
  });

  testWidgets('DT2 onUpdate: compact text-scale fallback still updates providers', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.4),
            ),
            child: const SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);

    await tester.ensureVisible(find.text('Vietnamese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vietnamese'));
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('vi'));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
