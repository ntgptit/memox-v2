import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/content/tag_providers.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/repositories/tag_repository.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';

class _FakeTagRepository implements TagRepository {
  _FakeTagRepository(this.tags, {this.existsWhenChecked = false});

  final List<TagWithCount> tags;

  /// When true, [existsCaseInsensitive] returns true — simulating a collision.
  final bool existsWhenChecked;

  ({String oldName, String newName})? renamed;
  ({String source, String destination})? merged;
  String? deleted;

  @override
  Stream<List<TagWithCount>> watchAllWithCount() =>
      Stream<List<TagWithCount>>.value(tags);

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
    return const Success<void>(null);
  }

  @override
  Future<Result<TagMergeResult>> merge({
    required String sourceName,
    required String destinationName,
  }) async {
    merged = (source: sourceName, destination: destinationName);
    return const Success<TagMergeResult>(TagMergeResult(movedCards: 1));
  }

  @override
  Future<Result<int>> delete(String name) async {
    deleted = name;
    return const Success<int>(1);
  }
}

Future<_FakeTagRepository> _pump(
  WidgetTester tester,
  List<TagWithCount> tags, {
  bool existsWhenChecked = false,
}) async {
  final fake = _FakeTagRepository(tags, existsWhenChecked: existsWhenChecked);
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
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('renders empty state when there are no tags', (tester) async {
    await _pump(tester, const []);
    expect(find.text('No tags yet'), findsOneWidget);
    expect(find.text('Go to library'), findsOneWidget);
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

  testWidgets('delete flow detaches the tag after confirmation',
      (tester) async {
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

  testWidgets('merge flow merges source into the chosen destination',
      (tester) async {
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

  testWidgets(
    'rename collision shows merge confirmation and merges when confirmed',
    (tester) async {
      // existsWhenChecked = true → RenameTagUseCase returns tagNameConflict →
      // screen shows merge-confirm dialog → user confirms → merge executes.
      final fake = await _pump(
        tester,
        const [TagWithCount(tag: 'verb', cardCount: 3)],
        existsWhenChecked: true,
      );

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
