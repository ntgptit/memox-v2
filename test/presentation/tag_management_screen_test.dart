import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/content/tag_providers.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/tag_management_notifier.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository(
    this.tags, {
    this.existsWhenChecked = false,
    Stream<List<TagWithCount>>? tagStream,
    this.renameResult = const Success<void>(null),
    this.mergeResult = const Success<TagMergeResult>(
      TagMergeResult(movedCards: 1),
    ),
    this.deleteResult = const Success<int>(1),
  }) : tagStream = tagStream ?? Stream<List<TagWithCount>>.value(tags);

  final List<TagWithCount> tags;
  final Stream<List<TagWithCount>> tagStream;

  /// When true, [existsCaseInsensitive] returns true — simulating a collision.
  final bool existsWhenChecked;
  final Result<void> renameResult;
  final Result<TagMergeResult> mergeResult;
  final Result<int> deleteResult;

  ({String oldName, String newName})? renamed;
  ({String source, String destination})? merged;
  String? deleted;

  @override
  Stream<List<TagWithCount>> watchAllWithCount() => tagStream;

  @override
  Future<bool> existsCaseInsensitive(String lowerName) async =>
      existsWhenChecked;

  @override
  Future<Result<void>> addTagToCard({
    required String flashcardId,
    required String tag,
  }) async => const Success<void>(null);

  @override
  Future<Result<void>> removeTagFromCard({
    required String flashcardId,
    required String tag,
  }) async => const Success<void>(null);

  @override
  Future<Result<void>> rename({
    required String oldName,
    required String newName,
  }) async {
    renamed = (oldName: oldName, newName: newName);
    return renameResult;
  }

  @override
  Future<Result<TagMergeResult>> merge({
    required String sourceName,
    required String destinationName,
  }) async {
    merged = (source: sourceName, destination: destinationName);
    return mergeResult;
  }

  @override
  Future<Result<int>> delete(String name) async {
    deleted = name;
    return deleteResult;
  }
}

Future<_FakeTagRepository> _pump(
  WidgetTester tester,
  List<TagWithCount> tags, {
  bool existsWhenChecked = false,
  Stream<List<TagWithCount>>? tagStream,
  Result<void> renameResult = const Success<void>(null),
  Result<TagMergeResult> mergeResult = const Success<TagMergeResult>(
    TagMergeResult(movedCards: 1),
  ),
  Result<int> deleteResult = const Success<int>(1),
  bool settle = true,
}) async {
  final fake = _FakeTagRepository(
    tags,
    existsWhenChecked: existsWhenChecked,
    tagStream: tagStream,
    renameResult: renameResult,
    mergeResult: mergeResult,
    deleteResult: deleteResult,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tagRepositoryProvider.overrideWithValue(fake)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SettingsTagManagementScreen(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return fake;
}

const _storageFailure = FailureResult<void>(
  AppFailure(
    type: FailureType.storage,
    message: 'SQLite disk-secret stack trace',
    code: FailureCodes.unknown,
  ),
);

void main() {
  testWidgets('renders empty state when there are no tags', (tester) async {
    await _pump(tester, const []);
    expect(find.text('No tags yet'), findsOneWidget);
    expect(find.text('Go to library'), findsOneWidget);
  });

  testWidgets('renders loading state while tags are loading', (tester) async {
    final controller = StreamController<List<TagWithCount>>();
    addTearDown(controller.close);

    await _pump(tester, const [], tagStream: controller.stream, settle: false);

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('renders safe error state without raw exception detail', (
    tester,
  ) async {
    await _pump(
      tester,
      const [],
      tagStream: Stream<List<TagWithCount>>.error(
        Exception('SQLite disk-secret stack trace'),
      ),
    );

    expect(find.text('A local storage problem occurred.'), findsOneWidget);
    expect(find.textContaining('SQLite'), findsNothing);
    expect(find.textContaining('disk-secret'), findsNothing);
  });

  testWidgets('renders populated tag rows with counts', (tester) async {
    await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
      TagWithCount(tag: 'noun', cardCount: 1),
    ]);

    expect(find.text('#verb'), findsOneWidget);
    expect(find.text('#noun'), findsOneWidget);
    expect(find.text('3 cards'), findsOneWidget);
    expect(find.text('2 tags'), findsOneWidget);
  });

  testWidgets('search filters locally and empty query restores all tags', (
    tester,
  ) async {
    await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
      TagWithCount(tag: 'noun', cardCount: 1),
    ]);

    await tester.enterText(find.byType(TextField).first, 'nou');
    await tester.pumpAndSettle();

    expect(find.text('#noun'), findsOneWidget);
    expect(find.text('#verb'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    expect(find.text('#noun'), findsOneWidget);
    expect(find.text('#verb'), findsOneWidget);
  });

  testWidgets('search no-results is distinct from true empty state', (
    tester,
  ) async {
    await _pump(tester, const [TagWithCount(tag: 'verb', cardCount: 3)]);

    await tester.enterText(find.byType(TextField).first, 'missing');
    await tester.pumpAndSettle();

    expect(find.text('No matching tags'), findsOneWidget);
    expect(find.text('No tags yet'), findsNothing);
  });

  test('filterAndSortTags applies documented V1 sort modes', () {
    const tags = [
      TagWithCount(tag: 'verb', cardCount: 1),
      TagWithCount(tag: 'adj', cardCount: 3),
      TagWithCount(tag: 'noun', cardCount: 3),
    ];

    expect(
      filterAndSortTags(
        tags,
        const TagManagementFilterState(sortMode: TagSortMode.mostCards),
      ).map((tag) => tag.tag),
      ['adj', 'noun', 'verb'],
    );
    expect(
      filterAndSortTags(
        tags,
        const TagManagementFilterState(sortMode: TagSortMode.nameAsc),
      ).map((tag) => tag.tag),
      ['adj', 'noun', 'verb'],
    );
    expect(
      filterAndSortTags(
        tags,
        const TagManagementFilterState(sortMode: TagSortMode.nameDesc),
      ).map((tag) => tag.tag),
      ['verb', 'noun', 'adj'],
    );
  });

  testWidgets('delete flow detaches the tag after confirmation', (
    tester,
  ) async {
    final fake = await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
    ]);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete tag (keeps cards)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(fake.deleted, 'verb');
  });

  testWidgets('delete cancel path does not mutate data', (tester) async {
    final fake = await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
    ]);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete tag (keeps cards)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(fake.deleted, isNull);
  });

  testWidgets('delete failure shows safe localized feedback', (tester) async {
    await _pump(
      tester,
      const [TagWithCount(tag: 'verb', cardCount: 3)],
      deleteResult: const FailureResult<int>(
        AppFailure(
          type: FailureType.storage,
          message: 'SQLite disk-secret stack trace',
        ),
      ),
    );

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete tag (keeps cards)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('A local storage problem occurred.'), findsOneWidget);
    expect(find.textContaining('SQLite'), findsNothing);
    expect(find.textContaining('disk-secret'), findsNothing);
  });

  testWidgets('rename flow renames the tag', (tester) async {
    final fake = await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
    ]);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'verbs');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(fake.renamed?.oldName, 'verb');
    expect(fake.renamed?.newName, 'verbs');
  });

  testWidgets('rename failure shows safe localized feedback', (tester) async {
    await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
    ], renameResult: _storageFailure);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'verbs');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(find.text('A local storage problem occurred.'), findsOneWidget);
    expect(find.textContaining('SQLite'), findsNothing);
    expect(find.textContaining('disk-secret'), findsNothing);
  });

  testWidgets('merge flow merges source into the chosen destination', (
    tester,
  ) async {
    final fake = await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
      TagWithCount(tag: 'noun', cardCount: 1),
    ]);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merge into another tag'));
    await tester.pumpAndSettle();
    // Pick destination "#noun" in the merge target sheet (rendered on top of
    // the background list, so the last match is the sheet item).
    await tester.tap(find.text('#noun').last);
    await tester.pumpAndSettle();
    // Confirm in the merge dialog.
    await tester.tap(find.text('Merge'));
    await tester.pumpAndSettle();

    expect(fake.merged?.source, 'verb');
    expect(fake.merged?.destination, 'noun');
  });

  testWidgets('merge cancel path does not mutate data', (tester) async {
    final fake = await _pump(tester, const [
      TagWithCount(tag: 'verb', cardCount: 3),
      TagWithCount(tag: 'noun', cardCount: 1),
    ]);

    await tester.tap(find.text('#verb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merge into another tag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#noun').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(fake.merged, isNull);
  });

  testWidgets(
    'rename collision shows merge confirmation and merges when confirmed',
    (tester) async {
      // existsWhenChecked = true → RenameTagUseCase returns tagNameConflict →
      // screen shows merge-confirm dialog → user confirms → merge executes.
      final fake = await _pump(tester, const [
        TagWithCount(tag: 'verb', cardCount: 3),
      ], existsWhenChecked: true);

      await tester.tap(find.text('#verb'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Enter a name that exists (collision).
      await tester.enterText(find.byType(TextField).last, 'verbs');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Merge-confirm dialog must appear (not rename snackbar).
      expect(find.text('Merge tags?'), findsOneWidget);
      expect(fake.merged, isNull); // not merged yet

      await tester.tap(find.text('Merge'));
      await tester.pumpAndSettle();

      // After confirm, merge is executed with the right names.
      expect(fake.merged?.source, 'verb');
      expect(fake.merged?.destination, 'verbs');
      expect(fake.renamed, isNull); // rename was not called
    },
  );
}
