/// Initial SRS state chosen by the author when creating a flashcard.
///
/// Maps to the Leitner box used by the SRS pipeline at insert time
/// (`new` → box 1, `learning` → box 3, `reviewing` → box 6). The mapping
/// lives in the data layer so domain remains transport-agnostic.
enum FlashcardStartingStatus {
  newCard('new'),
  learning('learning'),
  reviewing('reviewing');

  const FlashcardStartingStatus(this.storageValue);

  final String storageValue;

  static FlashcardStartingStatus fromStorage(String value) {
    for (final status in FlashcardStartingStatus.values) {
      if (status.storageValue == value) return status;
    }
    return FlashcardStartingStatus.newCard;
  }
}
