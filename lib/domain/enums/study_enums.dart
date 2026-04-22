enum StudyType {
  newCards('new'),
  due('due'),
  mixed('mixed');

  const StudyType(this.storageValue);

  final String storageValue;
}

enum StudyMode {
  review('review'),
  match('match'),
  guess('guess'),
  recall('recall');

  const StudyMode(this.storageValue);

  final String storageValue;
}

enum SessionStatus {
  inProgress('in_progress'),
  completed('completed'),
  endedEarly('ended_early'),
  restarted('restarted');

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
