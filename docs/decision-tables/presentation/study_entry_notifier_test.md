# Decision Tables: study_entry_notifier_test

Test file: `test/presentation/study_entry_notifier_test.dart`

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected study type is New Study but repository returns an empty eligible batch | action controller uses `_EmptyStudyRepo` where both new and due loaders return empty lists | `start(studyType: newStudy, settings: ...)` is called | result has null session id, result error is `ValidationException`, and controller state remains a non-error value | C0+C1 |
