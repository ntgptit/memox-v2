import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/locale_notifier.dart';
import 'package:memox/presentation/features/settings/providers/theme_mode_notifier.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/study/providers/study_settings_defaults_notifier.dart';
import 'package:memox/presentation/features/tts/providers/tts_settings_notifier.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _speechPreviewButtonKey = ValueKey<String>(
  'settings-speech-preview-button',
);
const _speechVoiceOptionsButtonKey = ValueKey<String>(
  'settings-speech-voice-options-button',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DT1 onOpen: renders settings page with default controls', (
    tester,
  ) async {
    final harness = await _pumpSettings(tester);

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    expect(find.text('English'), findsWidgets);
    expect(find.text('Study defaults'), findsOneWidget);
    expect(harness.tts.availableVoiceRequests, isEmpty);
  });

  testWidgets('DT1 onDisplay: shows theme and language sections', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets(
    'DT2 onDisplay: renders speech settings with Korean and English only',
    (tester) async {
      await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Speech'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Speech'), findsOneWidget);
      expect(find.text('Auto-play in study'), findsOneWidget);
      expect(find.text('Front language'), findsOneWidget);
      expect(find.text('Back language'), findsNothing);
      expect(find.text('Voice options'), findsOneWidget);
      expect(find.text('Front voice'), findsNothing);
      expect(find.text('Back voice'), findsNothing);

      final speechLanguageControls = tester
          .widgetList<MxSegmentedControl<TtsLanguage>>(
            find.byType(MxSegmentedControl<TtsLanguage>),
          )
          .toList();
      expect(speechLanguageControls, hasLength(1));
      for (final control in speechLanguageControls) {
        expect(
          control.segments.map((segment) => segment.value),
          orderedEquals(TtsLanguage.values),
        );
      }
    },
  );

  testWidgets('DT3 onDisplay: renders study defaults before speech settings', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(find.text('Study defaults'), findsOneWidget);
    expect(find.text('New Study batch size'), findsOneWidget);
    expect(find.text('Review batch size'), findsOneWidget);
    expect(find.text('5-20 cards'), findsOneWidget);
    expect(find.text('5-50 cards'), findsOneWidget);
    expect(find.text('Shuffle flashcards'), findsOneWidget);
    expect(find.text('Shuffle answers'), findsOneWidget);
    expect(find.text('Prioritize overdue cards'), findsOneWidget);
  });

  testWidgets(
    'DT4 onDisplay: clamps persisted study defaults before rendering',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.sharedPrefsDefaultNewBatchSizeKey: 100,
        AppConstants.sharedPrefsDefaultReviewBatchSizeKey: 1,
      });

      final harness = await _pumpSettings(tester);
      final settings = await harness.container.read(
        studyDefaultsSettingsProvider.future,
      );
      final store = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(settings.newStudyDefaults.batchSize, 20);
      expect(settings.reviewDefaults.batchSize, 5);
      expect(store.loadNewStudyDefaults().batchSize, 20);
      expect(store.loadReviewDefaults().batchSize, 5);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onUpdate: updates theme and locale providers from segmented controls',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);
      expect(find.text('Settings updated.'), findsOneWidget);

      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT2 onUpdate: compact text-scale fallback still updates providers',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        mediaQueryData: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.4),
        ),
      );

      expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);

      await tester.ensureVisible(find.text('Vietnamese'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT3 onUpdate: speech controls persist settings and preview selected language',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Auto-play in study'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();

      final languageControls = tester
          .widgetList<MxSegmentedControl<TtsLanguage>>(
            find.byType(MxSegmentedControl<TtsLanguage>),
          )
          .toList();
      languageControls.first.onChanged({TtsLanguage.english});
      await tester.pumpAndSettle();

      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(0.7);
      await tester.pumpAndSettle();

      final settings = await harness.container.read(ttsSettingsProvider.future);
      expect(settings.autoPlay, isTrue);
      expect(settings.frontLanguage, TtsLanguage.english);
      expect(settings.rate, 0.7);

      await tester.scrollUntilVisible(
        find.byKey(_speechPreviewButtonKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechPreviewButtonKey));
      await tester.pumpAndSettle();

      expect(harness.tts.speakCalls, hasLength(1));
      expect(harness.tts.speakCalls.single.language, TtsLanguage.english);
      expect(harness.tts.speakCalls.single.rate, 0.7);
    },
  );

  testWidgets(
    'DT4 onUpdate: speech voice options stay collapsed until requested',
    (tester) async {
      final harness = await _pumpSettings(tester);

      expect(find.text('Front voice'), findsNothing);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, isEmpty);

      await tester.scrollUntilVisible(
        find.byKey(_speechVoiceOptionsButtonKey),
        300,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey<String>('settings_content')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceOptionsButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Hide voice options'), findsOneWidget);
      expect(find.text('Front voice'), findsOneWidget);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, [TtsLanguage.korean]);
    },
  );

  testWidgets(
    'DT5 onUpdate: study default controls persist batch sizes and shared toggles',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('settings-study-new-batch-increase')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('settings-study-new-batch-increase')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-study-review-batch-decrease'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-study-review-batch-decrease'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(SwitchListTile, 'Shuffle flashcards'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Shuffle flashcards'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SwitchListTile, 'Shuffle answers'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Prioritize overdue cards'),
      );
      await tester.pumpAndSettle();

      final settings = await harness.container.read(
        studyDefaultsSettingsProvider.future,
      );
      final store = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(settings.newStudyDefaults.batchSize, 11);
      expect(settings.reviewDefaults.batchSize, 19);
      expect(settings.shuffleFlashcards, isFalse);
      expect(settings.shuffleAnswers, isFalse);
      expect(settings.prioritizeOverdue, isFalse);
      expect(store.loadNewStudyDefaults().batchSize, 11);
      expect(store.loadReviewDefaults().batchSize, 19);
      expect(store.loadNewStudyDefaults().shuffleFlashcards, isFalse);
    },
  );
}

Future<_SettingsHarness> _pumpSettings(
  WidgetTester tester, {
  MediaQueryData? mediaQueryData,
}) async {
  final fakeTts = _FakeTtsService();
  final container = ProviderContainer(
    overrides: [ttsServiceProvider.overrideWithValue(fakeTts)],
  );
  addTearDown(container.dispose);
  addTearDown(fakeTts.dispose);

  final child = mediaQueryData == null
      ? const SettingsScreen()
      : MediaQuery(data: mediaQueryData, child: const SettingsScreen());

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _TestApp(child: child),
    ),
  );
  await tester.pumpAndSettle();

  return _SettingsHarness(container: container, tts: fakeTts);
}

final class _SettingsHarness {
  const _SettingsHarness({required this.container, required this.tts});

  final ProviderContainer container;
  final _FakeTtsService tts;
}

final class _SpeakCall {
  const _SpeakCall({
    required this.text,
    required this.language,
    required this.rate,
    this.voiceName,
  });

  final String text;
  final TtsLanguage language;
  final double rate;
  final String? voiceName;
}

final class _FakeTtsService implements TtsService {
  final StreamController<TtsState> _states =
      StreamController<TtsState>.broadcast();

  final List<TtsLanguage> availableVoiceRequests = <TtsLanguage>[];
  final List<_SpeakCall> speakCalls = <_SpeakCall>[];
  int stopCount = 0;

  @override
  Stream<TtsState> get state => _states.stream;

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    availableVoiceRequests.add(language);
    return [
      TtsVoice(name: '${language.name} system voice', language: language),
    ];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {
    speakCalls.add(
      _SpeakCall(
        text: text,
        language: language,
        rate: rate,
        voiceName: voiceName,
      ),
    );
    if (!_states.isClosed) {
      _states.add(TtsState.speaking);
    }
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    if (!_states.isClosed) {
      _states.add(TtsState.idle);
    }
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }
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
