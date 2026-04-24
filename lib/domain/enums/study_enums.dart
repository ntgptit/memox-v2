enum StudyType {
  newStudy('new'),
  srsReview('srs_review');

  const StudyType(this.storageValue);

  final String storageValue;
}

enum StudyEntryType {
  deck('deck'),
  folder('folder'),
  today('today');

  const StudyEntryType(this.storageValue);

  final String storageValue;
}

enum StudyFlow {
  newFullCycle('new_full_cycle'),
  srsFillReview('srs_fill_review');

  const StudyFlow(this.storageValue);

  final String storageValue;
}

enum StudyMode {
  review('review'),
  match('match'),
  guess('guess'),
  recall('recall'),
  fill('fill');

  const StudyMode(this.storageValue);

  final String storageValue;
}

enum SessionStatus {
  draft('draft'),
  inProgress('in_progress'),
  readyToFinalize('ready_to_finalize'),
  completed('completed'),
  failedToFinalize('failed_to_finalize'),
  cancelled('cancelled');

  const SessionStatus(this.storageValue);

  final String storageValue;
}

enum SessionItemSourcePool {
  newCards('new'),
  due('due'),
  overdue('overdue'),
  retry('retry');

  const SessionItemSourcePool(this.storageValue);

  final String storageValue;
}

enum SessionItemStatus {
  pending('pending'),
  completed('completed'),
  abandoned('abandoned');

  const SessionItemStatus(this.storageValue);

  final String storageValue;
}

enum RawStudyResult {
  correct('correct'),
  incorrect('incorrect'),
  remembered('remembered'),
  forgot('forgot');

  const RawStudyResult(this.storageValue);

  final String storageValue;
}

enum AttemptGrade {
  correct('correct'),
  incorrect('incorrect'),
  remembered('remembered'),
  forgot('forgot');

  const AttemptGrade(this.storageValue);

  final String storageValue;

  bool get isPassing => this == correct || this == remembered;

  bool get isFailing => !isPassing;
}

enum ReviewResult {
  perfect('perfect'),
  recovered('recovered'),
  forgot('forgot');

  const ReviewResult(this.storageValue);

  final String storageValue;
}
