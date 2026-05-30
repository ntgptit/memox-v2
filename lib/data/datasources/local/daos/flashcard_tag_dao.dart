import 'package:drift/drift.dart';

import '../../../../core/utils/string_utils.dart';
import '../app_database.dart';

/// A distinct (lowercased) tag plus how many cards carry it.
final class TagCountRow {
  const TagCountRow({required this.tag, required this.cardCount});

  final String tag;
  final int cardCount;
}

/// Data-access for the `flashcard_tags` join table.
///
/// All tag matching is case-insensitive (`LOWER(tag)`); writes store the
/// lowercased form. Mutating operations that span multiple statements MUST be
/// invoked inside a transaction by the repository.
final class FlashcardTagDao {
  const FlashcardTagDao(this._database);

  final AppDatabase _database;

  Stream<List<TagCountRow>> watchAllWithCount() {
    final statement = _database.customSelect(
      'SELECT LOWER(tag) AS tag, '
      'COUNT(DISTINCT flashcard_id) AS card_count '
      'FROM flashcard_tags '
      'GROUP BY LOWER(tag) '
      'ORDER BY card_count DESC, tag ASC',
      readsFrom: {_database.flashcardTags},
    );
    return statement.watch().map(
      (rows) => rows
          .map(
            (row) => TagCountRow(
              tag: row.read<String>('tag'),
              cardCount: row.read<int>('card_count'),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<bool> existsCaseInsensitive(String name) async {
    final rows = await _database.select(_database.flashcardTags).get();
    return rows.any((row) => StringUtils.equalsNormalized(row.tag, name));
  }

  Future<void> addToCard({
    required String flashcardId,
    required String tag,
  }) => _database
      .into(_database.flashcardTags)
      .insert(
        FlashcardTagsCompanion.insert(flashcardId: flashcardId, tag: tag),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> removeFromCard({
    required String flashcardId,
    required String lowerTag,
  }) => _database.customStatement(
    'DELETE FROM flashcard_tags '
    'WHERE flashcard_id = ?1 AND LOWER(tag) = ?2',
    [flashcardId, lowerTag],
  );

  Future<void> rename({
    required String lowerOldName,
    required String newName,
  }) => _database.customStatement(
    'UPDATE flashcard_tags SET tag = ?1 WHERE LOWER(tag) = ?2',
    [newName, lowerOldName],
  );

  Future<int> countCardsWithTag(String lowerTag) async {
    final table = _database.flashcardTags;
    final countExpr = table.flashcardId.count(distinct: true);
    final query = _database.selectOnly(table)
      ..addColumns([countExpr])
      ..where(table.tag.lower().equals(lowerTag));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Inserts the destination tag onto every card currently carrying the source
  /// tag, deduping via `INSERT OR IGNORE` against the `(flashcard_id, tag)`
  /// primary key.
  Future<void> attachDestinationToSourceCards({
    required String lowerSource,
    required String destination,
  }) => _database.customStatement(
    'INSERT OR IGNORE INTO flashcard_tags (flashcard_id, tag) '
    'SELECT flashcard_id, ?1 FROM flashcard_tags WHERE LOWER(tag) = ?2',
    [destination, lowerSource],
  );

  Future<void> deleteTag(String lowerTag) => _database.customStatement(
    'DELETE FROM flashcard_tags WHERE LOWER(tag) = ?1',
    [lowerTag],
  );
}
