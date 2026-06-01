import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/tag_management_notifier.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/study_settings_defaults_viewmodel.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: renders V1 study defaults, intervals, and tags', (
    tester,
  ) async {
    await _pumpLearning(tester);

    expect(find.text('Learning experience'), findsWidgets);
    expect(find.text('New Study batch size'), findsWidgets);
    expect(find.text('Review batch size'), findsWidgets);
    expect(find.text('Shuffle flashcards'), findsOneWidget);
    expect(find.text('SRS intervals'), findsOneWidget);
    expect(find.text('Current runtime schedule'), findsOneWidget);
    expect(find.text('Box 1'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Box 8'), findsOneWidget);
    expect(find.text('120 days'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('settings-learning-manage-tags-row')),
      findsOneWidget,
    );
    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(find.textContaining('Daily goal'), findsNothing);
    expect(find.textContaining('Streak'), findsNothing);
    expect(find.textContaining('Reminder'), findsNothing);
  });

  testWidgets('DT2 onOpen: loading state is user-facing', (tester) async {
    final completer = Completer<StudyDefaultsSettingsState>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_settingsState);
      }
    });

    await _pumpLearning(
      tester,
      notifierFactory: () => _LoadingStudyDefaultsSettings(completer.future),
      settle: false,
    );
    await tester.pump();

    expect(find.text('Loading study defaults'), findsOneWidget);
    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('DT3 onOpen: error state hides technical storage detail', (
    tester,
  ) async {
    await _pumpLearning(
      tester,
      notifierFactory: _FailingBuildStudyDefaultsSettings.new,
    );
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.textContaining('SharedPreferences'), findsNothing);
    expect(find.textContaining('disk-secret'), findsNothing);
  });

  testWidgets('DT3b onUpdate: save failure hides technical storage detail', (
    tester,
  ) async {
    await _pumpLearning(
      tester,
      notifierFactory: _FailingSaveStudyDefaultsSettings.new,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.textContaining('SharedPreferences'), findsNothing);
    expect(find.textContaining('write-secret'), findsNothing);
  });

  testWidgets('DT4 onUpdate: stepper edges enforce min and max', (
    tester,
  ) async {
    await _pumpLearning(
      tester,
      notifierFactory: () => _StaticStudyDefaultsSettings(
        const StudyDefaultsSettingsState(
          newStudyDefaults: StudySettingsSnapshot(
            batchSize: 5,
            shuffleFlashcards: true,
            shuffleAnswers: true,
            prioritizeOverdue: true,
          ),
          reviewDefaults: StudySettingsSnapshot(
            batchSize: 50,
            shuffleFlashcards: true,
            shuffleAnswers: true,
            prioritizeOverdue: true,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('settings-study-new-batch-row')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MxIconButton>(
            find.byKey(
              const ValueKey<String>('settings-study-new-batch-decrease'),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings-study-review-batch-row')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('settings-study-review-batch-row')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MxIconButton>(
            find.byKey(
              const ValueKey<String>('settings-study-review-batch-increase'),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('DT5 onNavigate: Manage tags row opens tag route owner', (
    tester,
  ) async {
    await _pumpLearningRouter(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings-learning-manage-tags-row')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('settings-learning-manage-tags-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsTagManagementScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(LearningSettingsScreen), findsOneWidget);
    expect(find.byType(SettingsTagManagementScreen), findsNothing);
  });
}

Future<void> _pumpLearning(
  WidgetTester tester, {
  StudyDefaultsSettings Function()? notifierFactory,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studyDefaultsSettingsProvider.overrideWith(
          notifierFactory ?? _StaticStudyDefaultsSettings.new,
        ),
      ],
      child: const _TestApp(child: LearningSettingsScreen()),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _pumpLearningRouter(WidgetTester tester) async {
  const learningPath =
      '${RoutePaths.settings}/${RoutePaths.settingsLearningSegment}';
  const tagsPath =
      '${RoutePaths.settings}/${RoutePaths.settingsLearningTagsSegment}';
  final router = GoRouter(
    initialLocation: learningPath,
    routes: [
      GoRoute(
        path: learningPath,
        name: RouteNames.settingsLearning,
        builder: (context, state) => const LearningSettingsScreen(),
      ),
      GoRoute(
        path: tagsPath,
        name: RouteNames.settingsLearningTags,
        builder: (context, state) => const SettingsTagManagementScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studyDefaultsSettingsProvider.overrideWith(
          _StaticStudyDefaultsSettings.new,
        ),
        tagListProvider.overrideWith(
          (_) => Stream<List<TagWithCount>>.value(const <TagWithCount>[]),
        ),
      ],
      child: _RouterTestApp(router: router),
    ),
  );
  await tester.pumpAndSettle();
}

const _settingsState = StudyDefaultsSettingsState(
  newStudyDefaults: StudySettingsSnapshot(
    batchSize: 10,
    shuffleFlashcards: true,
    shuffleAnswers: true,
    prioritizeOverdue: true,
  ),
  reviewDefaults: StudySettingsSnapshot(
    batchSize: 20,
    shuffleFlashcards: true,
    shuffleAnswers: true,
    prioritizeOverdue: true,
  ),
);

class _StaticStudyDefaultsSettings extends StudyDefaultsSettings {
  _StaticStudyDefaultsSettings([this.settings = _settingsState]);

  final StudyDefaultsSettingsState settings;

  @override
  Future<StudyDefaultsSettingsState> build() async => settings;
}

class _LoadingStudyDefaultsSettings extends StudyDefaultsSettings {
  _LoadingStudyDefaultsSettings(this.settingsFuture);

  final Future<StudyDefaultsSettingsState> settingsFuture;

  @override
  Future<StudyDefaultsSettingsState> build() => settingsFuture;
}

class _FailingBuildStudyDefaultsSettings extends StudyDefaultsSettings {
  @override
  Future<StudyDefaultsSettingsState> build() async {
    throw Exception('SharedPreferences disk-secret read failed');
  }
}

class _FailingSaveStudyDefaultsSettings extends _StaticStudyDefaultsSettings {
  @override
  Future<void> setShuffleFlashcards(bool value) async {
    throw Exception('SharedPreferences write-secret failed');
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}
