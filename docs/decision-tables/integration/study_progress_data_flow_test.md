# Decision Tables: study_progress_data_flow_test

Test file: `test/integration/study_progress_data_flow_test.dart`

## Decision table: onOpen

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Progress route opens with one in-progress session | database contains one deck New Study session still in Review mode | user opens `/progress` directly | Progress renders the active list with in-progress status, current card, and Review round data | C0+C1 |
| DT2 | Result route opens with one completed session | database contains one finalized SRS Review session with a correct attempt | user opens the session result route directly | Result renders completed status and persisted summary sections for attempts and correct answers | C0+C1 |
| DT3 | Study Entry route opens without a resume candidate | database contains an eligible deck but no active session for that deck | user opens the deck Study Entry route directly | Study Entry shows the start state and does not show resume or restart controls | C0+C1 |

## Decision table: onNavigate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | deck flashcard data is carried across routed study surfaces | app runs with an in-memory database containing a deck with two new flashcards | user opens the deck flashcard list, starts a deck New Study session, switches to Progress, then continues the session | flashcard list, Review session, Progress session card, and resumed Review session all show the same current card data and active session progress | C0+C1 |
| DT2 | Study Entry has an active resume candidate for the same deck | database already contains an in-progress deck study session for the requested deck | user opens the deck Study Entry screen and taps the resume action | Study Entry shows the resume card progress and Continue opens the Review screen with the same current card data | C0+C1 |
| DT3 | folder entry creates a folder-scoped study session | app runs with an in-memory database containing a folder with a deck and flashcards | user opens folder Study Entry, starts New Study, then switches to Progress | Review and Progress show the same current card and Progress labels the active session as a Folder entry | C0+C1 |
| DT4 | Progress Continue is tapped for an in-progress session | database contains one active New Study session in Review mode | user opens Progress and taps Continue | the routed Study Session screen opens Review mode with the same current card front/back | C0+C1 |
| DT5 | Progress Continue is tapped for a ready-to-finalize session | database contains one SRS Review session in ready-to-finalize state | user opens Progress and taps the secondary Continue action | the routed Study Session screen opens the ready-to-finalize panel and exposes Finalize | C0+C1 |
| DT6 | Review mode back button has no previous route to pop | app is opened directly on a Review session route | user taps the Review screen back button | navigation falls back to Library overview with the seeded folder visible | C0+C1 |
| DT7 | Result Study Again uses the completed session entry | database contains one completed deck study session | user opens Result and taps Study | the same deck Study Entry route opens in start state without resume | C0+C1 |
| DT8 | Progress empty state action navigates to Library | database contains a library folder but no active sessions | user opens Progress and taps `View library` | Library overview opens and displays the seeded folder | C0+C1 |
| DT9 | Continue is selected after the user stops with Review completed and Match pending | deck New Study was started from Study Entry, Review auto-submitted two cards, and stored session now has two mode queues | user reopens Study Entry and taps Continue | Study Session resumes the existing session at Match with the original first card still current | C0+C1 |
| DT10 | Continue is selected after the user stops with Match completed and Guess pending | deck New Study was started from Study Entry, Review and Match were completed, and stored session now has three mode queues | user reopens Study Entry and taps Continue | Study Session resumes the existing session at Guess with the original first card still current | C0+C1 |
| DT11 | Continue is selected after the user stops with Guess completed and Recall pending | deck New Study was started from Study Entry, Review, Match, and Guess were completed, and stored session now has four mode queues | user reopens Study Entry and taps Continue | Study Session resumes the existing session at Recall with the original first card still current | C0+C1 |
| DT12 | Continue is selected after the user stops with Recall completed and Fill pending | deck New Study was started from Study Entry, Review, Match, Guess, and Recall were completed, and stored session now has five mode queues | user reopens Study Entry and taps Continue | Study Session resumes the existing session at Fill with the original first card still current | C0+C1 |
| DT13 | Progress was cached before Review advanced and Continue is selected after Match becomes pending | user opened Progress while the same deck New Study was still in Review, returned to the session, Review auto-submitted, and stored session now has two mode queues | user opens Progress again and taps Continue | Progress reflects Match round data before navigation and Study Session resumes at Match with the original first card still current | C0+C1 |
| DT14 | Progress was cached before Review advanced and Continue is selected after Guess becomes pending | user opened Progress while the same deck New Study was still in Review, returned to the session, Review and Match completed, and stored session now has three mode queues | user opens Progress again and taps Continue | Progress reflects Guess round data before navigation and Study Session resumes at Guess with the original first card still current | C0+C1 |
| DT15 | Progress was cached before Review advanced and Continue is selected after Recall becomes pending | user opened Progress while the same deck New Study was still in Review, returned to the session, Review, Match, and Guess completed, and stored session now has four mode queues | user opens Progress again and taps Continue | Progress reflects Recall round data before navigation and Study Session resumes at Recall with the original first card still current | C0+C1 |
| DT16 | Progress was cached before Review advanced and Continue is selected after Fill becomes pending | user opened Progress while the same deck New Study was still in Review, returned to the session, Review, Match, Guess, and Recall completed, and stored session now has five mode queues | user opens Progress again and taps Continue | Progress reflects Fill round data before navigation and Study Session resumes at Fill with the original first card still current | C0+C1 |
| DT17 | Review auto-submit enters the new Match board | deck New Study has two review cards and Match is the next mode | user reaches the final Review page and waits for auto-submit | Study Session opens the Match full board with back texts on the left, front texts on the right, and zero Match attempts written before any tile selection | C0+C1 |

## Decision table: onUpdate

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | active session is cancelled from Progress | database contains one in-progress deck study session visible in Progress | user confirms Cancel from the Progress card | Progress no longer lists the session, the stored status is cancelled, and the same deck Study Entry no longer exposes a resume candidate | C0+C1 |
| DT2 | ready-to-finalize session is finalized from Progress | database contains one SRS Review session in ready-to-finalize state with a correct attempt | user taps Finalize from the Progress card | Progress removes the session, stored status becomes completed, SRS box increases, and the Result screen reports Completed | C0+C1 |
| DT3 | failed-finalize session is retried from Progress | database contains one failed-to-finalize SRS Review session with a correct attempt | user taps Retry from the Progress card | Progress removes the retry card, stored status becomes completed, and the Result screen no longer shows the failed-finalize message | C0+C1 |
| DT4 | Progress cancel confirmation is dismissed | database contains one in-progress deck study session visible in Progress | user opens the cancel dialog and taps the neutral Cancel action | stored status remains in progress and Progress still shows the active card | C0+C1 |
| DT5 | ready session is cancelled from Study Session screen | database contains one ready-to-finalize SRS Review session | user opens the Study Session route, taps close, and confirms cancellation | stored status becomes cancelled and the Result screen shows Cancelled | C0+C1 |
| DT6 | ready session is finalized from Study Session screen | database contains one ready-to-finalize SRS Review session | user opens the Study Session route and taps Finalize | stored status becomes completed and Result screen shows Completed | C0+C1 |
| DT7 | Review mode auto-submit advances persisted mode data | database contains one-card New Study session in Review mode | user opens Review mode and waits for the two-second auto-submit | Study Session advances to Match and Progress shows Match round data for the same card | C0+C1 |
| DT8 | start-new confirmation replaces the old active session after user confirms | database contains one in-progress deck session and eligible cards | user opens Study Entry, taps `Start`, then confirms the warning | old session is cancelled, exactly one active replacement remains, and Review opens with the same card data | C0+C1 |
| DT9 | Start is selected after the user stops with Review completed and Match pending | deck New Study was started from Study Entry, Review auto-submitted two cards, and stored session now has two mode queues | user reopens Study Entry, taps `Start`, then confirms the warning | previous session is cancelled, one replacement session remains active, replacement links to the previous session, and fresh Review opens | C0+C1 |
| DT10 | Start is selected after the user stops with Match completed and Guess pending | deck New Study was started from Study Entry, Review and Match were completed, and stored session now has three mode queues | user reopens Study Entry, taps `Start`, then confirms the warning | previous session is cancelled, one replacement session remains active, replacement links to the previous session, and fresh Review opens | C0+C1 |
| DT11 | Start is selected after the user stops with Guess completed and Recall pending | deck New Study was started from Study Entry, Review, Match, and Guess were completed, and stored session now has four mode queues | user reopens Study Entry, taps `Start`, then confirms the warning | previous session is cancelled, one replacement session remains active, replacement links to the previous session, and fresh Review opens | C0+C1 |
| DT12 | Start is selected after the user stops with Recall completed and Fill pending | deck New Study was started from Study Entry, Review, Match, Guess, and Recall were completed, and stored session now has five mode queues | user reopens Study Entry, taps `Start`, then confirms the warning | previous session is cancelled, one replacement session remains active, replacement links to the previous session, and fresh Review opens | C0+C1 |
| DT13 | Match mismatch then board completion persists a retry round | deck New Study is in Match with two pending pairs | user mismatches one pair once, then completes all visible pairs | database stores no attempt at mismatch time, then stores one `incorrect` and one `correct` attempt at board completion and leaves current mode in Match retry round 2 | C0+C1 |
| DT14 | Completing Match retry advances to Guess | deck New Study has a Match retry round containing one previously incorrect flashcard | user completes the retry pair correctly | database stores a second Match attempt for that flashcard and current mode advances to Guess | C0+C1 |
| DT15 | Progress Continue after partial Match opens the persisted retry round | deck New Study completed a mixed Match board and is left in Match retry round 2 | user opens Progress and taps Continue | Progress shows Match round 2 and Study Session opens the retry board containing only the failed flashcard | C0+C1 |

## Decision table: onExternalChange

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Study Entry has cached a resume candidate that later becomes completed from Study Session | Study Entry is open for a deck with a ready-to-finalize SRS session and has rendered its resume card | user navigates to that Study Session, finalizes it, then returns to the same Study Entry route | Study Entry refetches the resume state, hides `Session in progress`, and shows the normal start action instead of routing to an ended session | C0+C1 |

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | all study sessions are terminal | database contains only completed and cancelled study sessions | user opens Progress | Progress shows the empty state and excludes terminal session labels from active data | C0+C1 |
| DT2 | no study sessions exist | database contains no study sessions | user opens Progress | Progress shows the empty state and `View library` action instead of the active-session list | C0+C1 |
| DT3 | active sessions span all managed statuses | database contains one in-progress, one ready-to-finalize, and one failed-to-finalize session | user opens Progress | overview labels and all three status badges are visible together | C0+C1 |
| DT4 | in-progress card has current item data | database contains one New Study session in Review mode | user opens Progress | card shows Review round, current card front, and started-at metadata | C0+C1 |
| DT5 | ready card has completed progress | database contains one SRS Review session with no remaining items | user opens Progress | card shows ready status, Finalize and Continue actions, and `1 of 1 study steps · 0 remaining` | C0+C1 |
| DT6 | failed card has retry affordance | database contains one failed-to-finalize session | user opens Progress | card shows failed status, Retry, Cancel, and no Finalize action | C0+C1 |
| DT7 | multiple active sessions are ordered by recency | database contains an older in-progress session and a newer failed-finalize session | user opens Progress | newer failed-finalize status appears above the older in-progress status | C0+C1 |
| DT8 | ready result screen reflects unfinalized session data | database contains one ready-to-finalize SRS Review session | user opens Result directly | Result shows Ready to finalize status and persisted metric rows | C0+C1 |

## Decision table: onSelect

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | Progress cancel action is selected but not confirmed | database contains one in-progress session | user taps Cancel in Progress | confirmation copy appears and stored status is still in progress before confirmation | C0+C1 |
| DT2 | ready Progress card action set is selected for inspection | database contains one ready-to-finalize SRS Review session | user opens Progress | card exposes Finalize and Continue choices and does not expose Retry | C0+C1 |
| DT3 | failed Progress card action set is selected for inspection | database contains one failed-to-finalize SRS Review session | user opens Progress | card exposes Retry and Cancel choices and does not expose Finalize | C0+C1 |
