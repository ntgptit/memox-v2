# Sub-Agent Orchestration — MemoX

How the main Claude session should delegate work to the sub-agents under `.claude/agents/`. Goal: preserve context budget and improve precision on a repo with strict guard rules.

---

## Agent roster

| Agent | Model | When | Returns |
|---|---|---|---|
| `flutter-code-searcher` | haiku | Locate files/snippets for a concept | JSON files + snippets |
| `flutter-ui-reviewer` | sonnet | Review ONE widget/screen for theme/responsive/a11y/guard | JSON issues + score |
| `flutter-architecture-reviewer` | sonnet | Review layer boundaries / Riverpod / DI wiring | JSON findings |
| `dart-refactor-planner` | sonnet | Produce a refactor plan, no edits | JSON steps + risks |
| `git-workflow-helper` | haiku | Non-trivial Git flows (rebase, recovery, force-push) | JSON commands + rollback |
| `test-runner` | haiku | Run `flutter test`, parse output | JSON pass/fail report |

---

## Decision tree

Start here for any user task on this repo:

1. **User asks "where is X / which file does Y"** → `flutter-code-searcher`. Do NOT read files yourself first.
2. **User says "review this screen/widget"** (UI-only concern) → `flutter-ui-reviewer` on the target file.
3. **User says "review this feature / state flow / provider wiring"** → `flutter-architecture-reviewer`.
4. **User asks to plan a refactor / migration / split without doing it** → `dart-refactor-planner`.
5. **User asks for Git help beyond `status`/`log`/basic `commit`** → `git-workflow-helper`.
6. **User asks to run tests / surface failures** → `test-runner`.
7. **Edit tasks (add feature, fix bug, change theme)**: do it in the main session. Sub-agents review/plan, they do not edit.

### Concrete MemoX examples

| Task | Agent sequence |
|---|---|
| "Review `deck_list_screen.dart`" | `flutter-ui-reviewer(deck_list_screen.dart)` |
| "Where is flashcard review logic?" | `flutter-code-searcher("flashcard review")` |
| "Plan extracting study scheduling into a use case" | `flutter-code-searcher("study scheduling")` → `dart-refactor-planner(goal + files from step 1)` |
| "Add a new `MxStatChip` shared widget" | main session edits (follow `presentation/shared/` pattern); optional `flutter-ui-reviewer` on the new file |
| "Is the decks feature crossing layers?" | `flutter-architecture-reviewer(scope=presentation/features/decks + data + domain)` |
| "Run the study tests" | `test-runner("test/features/study")` |
| "Rebase and squash last 4 commits" | `git-workflow-helper` |

---

## Anti-patterns — do NOT spawn an agent for

- Single-file reads already in context. Just use `Read` in the main session.
- Trivial greps (one keyword, one directory). Use `Grep` directly.
- Edits of fewer than ~3 files when you already know the files. Edit directly.
- "Does the build pass?" when you can just run `flutter analyze` inline.
- Design/architecture questions with obvious answers from `CLAUDE.md`.
- Stacking UI reviewer AND architecture reviewer on the same small widget change — pick one based on the dominant concern.
- Running `flutter-code-searcher` then re-reading all the files it already excerpted. Trust its snippets and only open files you truly need to modify.

---

## Token budget guidelines

- One UI review on one file: ~1 `flutter-ui-reviewer` call. Cheap.
- Reviewing a whole feature (5+ files): `flutter-code-searcher` once, then 1–2 `flutter-ui-reviewer` on the highest-risk widgets + 1 `flutter-architecture-reviewer` on the feature scope. Do NOT call `flutter-ui-reviewer` for every file — pick the screens and the one or two most complex widgets.
- Refactor planning: exactly one `dart-refactor-planner`. Re-invoke only if the plan is rejected and scope changes.
- Code search: one call per distinct concept. Don't chain searches for slight rewordings — ask the user to clarify instead.
- Tests: one `test-runner` call per scope. Don't re-run without reason.
- Git help: one `git-workflow-helper` per flow. Execute commands in the main session after the user approves.

Rule of thumb: if the main session can finish the task in under ~3 tool calls, don't delegate.

---

## Composition patterns

### Review a screen end-to-end ("review `deck_detail_screen`")

1. `flutter-ui-reviewer(lib/presentation/features/decks/screens/deck_detail_screen.dart)` — theme, responsive, a11y.
2. If the screen uses non-trivial providers: `flutter-architecture-reviewer(scope=that screen + its providers + any repo it reaches)`.
3. Main session consolidates both JSON outputs into a prioritized list and proposes fixes. Do NOT edit yet — ask the user.

### Plan + land a refactor

1. `flutter-code-searcher` → get the file set.
2. `dart-refactor-planner(goal, files)` → plan.
3. User approves plan.
4. Main session edits.
5. Main session runs `python tools/guard/run.py --policy memox` and `flutter analyze` (both must be clean).
6. `test-runner` for affected scope.
7. Optional `flutter-ui-reviewer` on touched UI.

### Cross-layer feature audit

1. `flutter-architecture-reviewer(scope=feature)` first — boundary issues are the most expensive to fix later.
2. Only if clean: `flutter-ui-reviewer` on screens.

---

## Non-negotiables for every agent invocation

- Pass absolute or repo-relative paths, not vague descriptions.
- Tell the agent the scope up front; don't expect it to discover the full repo.
- Trust the JSON output as source of truth for the delegated task. If it's wrong, fix the agent prompt, don't silently redo its work.
- Guard-policy (`tools/guard/run.py --policy memox`) and `flutter analyze` are the authoritative gates — sub-agent opinions never override them.
