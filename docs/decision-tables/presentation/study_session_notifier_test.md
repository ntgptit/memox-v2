# Decision Tables: study_session_notifier_test

Test file: `test/presentation/study_session_notifier_test.dart`

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | `studyAnswerOptions` sees `shuffleAnswers=false` and must preserve source order | match-mode snapshot has current card `card-2`, four session cards, and answer shuffle disabled | `studyAnswerOptions(snapshot)` is evaluated | returned option ids are `card-1`, `card-2`, `card-3`, `card-4` | C0+C1 |
| DT2 | session action controller cancel succeeds and must not leave provider in error state | study repo fake increments `cancelCount` and returns a snapshot | `studySessionActionControllerProvider('session-1').cancel()` is called | result is true and controller state has no error | C0+C1 |
| DT3 | cancel toolbar action must ask for confirmation before mutating the session | study session screen is rendered with a cancellable in-progress session | user taps tooltip `Cancel session` | `Cancel this session?` dialog appears and fake repo `cancelCount` remains zero | C0+C1 |
| DT4 | fill-mode input controller must reset when the current item id changes | first fill snapshot has `item-1`, second fill snapshot has `item-2` | user types `stale answer`, then host rebuilds with the second snapshot | text field controller text becomes empty | C0+C1 |
| DT5 | answering in guess mode produces feedback first and does not immediately continue | guess-mode snapshot has one current card and continue callback count starts at zero | user taps `Correct` | `Continue` and correct answer feedback are visible, while continue callback count stays zero | C0+C1 |
| DT6 | feedback Continue submits once, then disabled loading state blocks duplicate submit | feedback for current item is correct and continue callback count starts at zero | user taps `Continue`, then widget rebuilds with `isSubmitting=true` and user taps the last elevated button | continue callback count is one after both taps | C0+C1 |
| DT7 | fill mode has an empty answer and Submit must be blocked | fill-mode snapshot has one current card and answer callback count starts at zero | user taps `Submit` without entering text | answer callback count remains zero | C0+C1 |
| DT8 | match mode renders long-answer cards through `MxAnswerOptionCard`, not one-line secondary buttons | match-mode snapshot has three answer options and answer shuffle disabled | `StudyModePanel` renders match mode | three `MxAnswerOptionCard`s are present and `MxSecondaryButton` is absent for each answer text | C0+C1 |
| DT9 | incorrect feedback exposes Mark correct and converts the pending grade before continue | fill-mode feedback has `selectedGrade=incorrect` and `isCorrect=false` | user taps `Mark correct` | callback receives feedback with `selectedGrade=correct` and `isCorrect=true` | C0+C1 |
| DT10 | fill feedback includes both submitted answer and correct answer | fill-mode feedback contains submitted answer `anser 1` and correct answer `answer 1` | feedback panel renders | `Your answer: anser 1` and `Correct answer: answer 1` are visible | C0+C1 |
| DT11 | review batch controller path uses the current study strategy and fixed correct grade | repo fake returns a New Study review snapshot and records batch calls | `answerCurrentReviewModeAsCorrect()` is called | repo receives one batch call with grade `correct`, the New Study mode list, and controller state has no error | C0+C1 |
| DT12 | study session mutation must refresh cached Progress sessions | Progress active-session provider has already loaded from the same fake repo and Review batch submission succeeds | `answerCurrentReviewModeAsCorrect()` is called and Progress sessions are read again | fake repo active-session load count increases from one to two, proving the cached Progress provider was invalidated | C0+C1 |
| DT13 | terminal study session mutation must refresh cached Study Entry resume state | Study Entry provider has cached an active deck resume candidate and the same session can be cancelled | `cancel()` is called and Study Entry state is read again | result is true, fake repo resume-candidate load count increases from one to two, and refreshed Study Entry state has no resume candidate | C0+C1 |
| DT14 | generic mode batch controller forwards the board item grade map | repo fake returns a New Study Match snapshot and records match batch calls | `answerCurrentModeItemGradesBatch({item-1: correct, item-2: incorrect})` is called | repo receives one Match batch call with the exact item-grade map, the New Study mode list, and controller state has no error | C0+C1 |
| DT15 | `studyGuessAnswerOptions` sees five session cards and answer shuffle disabled | guess-mode snapshot has current card `card-1`, four distractors, and answer shuffle disabled | `studyGuessAnswerOptions(snapshot)` is evaluated | returned option ids are `card-1`, `card-2`, `card-3`, `card-4`, and `card-5` | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selecting a long wrong match option must stay readable and show incorrect feedback | match-mode snapshot has correct answer and a long distractor option | user scrolls to the long distractor and taps it | `Not quite`, `Correct answer: correct answer`, and `Continue` are visible | C0+C1 |
