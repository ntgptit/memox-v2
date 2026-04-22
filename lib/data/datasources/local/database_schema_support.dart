abstract final class DatabaseEnumValues {
  const DatabaseEnumValues._();

  static const List<String> folderContentModes = <String>[
    'unlocked',
    'subfolders',
    'decks',
  ];

  static const List<String> studyEntryTypes = <String>[
    'deck',
    'folder',
    'today',
  ];

  static const List<String> studyTypes = <String>['new', 'due', 'mixed'];

  static const List<String> studyModes = <String>[
    'review',
    'match',
    'guess',
    'recall',
  ];

  static const List<String> sessionStatuses = <String>[
    'in_progress',
    'completed',
    'ended_early',
    'restarted',
  ];

  static const List<String> sessionItemSourcePools = <String>[
    'new',
    'due',
    'overdue',
    'retry',
  ];

  static const List<String> sessionItemStatuses = <String>[
    'pending',
    'completed',
    'abandoned',
  ];

  static const List<String> rawStudyResults = <String>[
    'correct',
    'incorrect',
    'remembered',
    'forgot',
  ];
}
