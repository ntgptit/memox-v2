# Decision Tables: study_entry_notifier_test

Test file: `test/presentation/study_entry_notifier_test.dart`

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected study type is New Study but repository returns an empty eligible batch | action controller uses `_EmptyStudyRepo` where both new and due loaders return empty lists | `start(studyType: newStudy, settings: ...)` is called | result has null session id, result error is `ValidationException`, and controller state remains a non-error value | C0+C1 |
| DT2 | starting a new session must refresh cached Progress sessions | Progress active-session provider has already loaded from the same fake repo and New Study start succeeds | `start(studyType: newStudy, settings: ...)` is called and Progress sessions are read again | result returns the new session id and fake repo active-session load count increases from one to two, proving cached Progress data was invalidated | C0+C1 |
