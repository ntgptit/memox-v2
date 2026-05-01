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

  static const List<String> studyTypes = <String>['new', 'srs_review'];

  static const List<String> studyFlows = <String>[
    'new_full_cycle',
    'srs_fill_review',
  ];

  static const List<String> studyModes = <String>[
    'review',
    'match',
    'guess',
    'recall',
    'fill',
  ];

  static const List<String> sessionStatuses = <String>[
    'draft',
    'in_progress',
    'ready_to_finalize',
    'completed',
    'failed_to_finalize',
    'cancelled',
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

  static const List<String> rawStudyResults = <String>['correct', 'incorrect'];

  static const List<String> reviewResults = <String>[
    'initial_passed',
    'perfect',
    'recovered',
    'forgot',
  ];
}
