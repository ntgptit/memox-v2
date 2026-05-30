/// A distinct tag plus the number of cards it is attached to.
///
/// Source: `SELECT LOWER(tag), COUNT(DISTINCT flashcard_id) FROM
/// flashcard_tags GROUP BY LOWER(tag)`. The [tag] is the lowercased storage
/// form (display form in V1; see `docs/business/tags/tag-system.md`).
class TagWithCount {
  const TagWithCount({required this.tag, required this.cardCount});

  final String tag;
  final int cardCount;

  @override
  bool operator ==(Object other) =>
      other is TagWithCount &&
      other.tag == tag &&
      other.cardCount == cardCount;

  @override
  int get hashCode => Object.hash(tag, cardCount);
}

/// Outcome of merging one tag into another.
///
/// [movedCards] is the number of distinct cards that carried the source tag
/// before the merge (cards already carrying the destination tag are deduped,
/// not double-counted as new attachments).
class TagMergeResult {
  const TagMergeResult({required this.movedCards});

  final int movedCards;

  @override
  bool operator ==(Object other) =>
      other is TagMergeResult && other.movedCards == movedCards;

  @override
  int get hashCode => movedCards.hashCode;
}
