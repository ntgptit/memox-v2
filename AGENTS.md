# AGENTS.md

## Scope

MemoX is a Flutter full-app for flashcard learning and spaced repetition.
Primary stack: Flutter 3.11+, Dart 3.11, Riverpod Annotation, Drift, Material 3.

Use this file as the repository router for Codex work in this workspace.
Nên viết code thật cẩn thận, tuân thủ mọi quy định đã đặt ra, code sau khi thực hiện sẽ được Claude code và ChatGPT phiên bản web review.

## Skill Routing

- Use `flutter-full-app` for Flutter feature, architecture, local-state, and local-data work.
- Use `markdown-spec-to-code` when implementing from `docs/business/**` or `docs/database/**`.
- Use `flutter-app-development` as supporting context when a task spans app shell, routing, theme, and feature structure.
- Only use sub-agents if the user explicitly asks for delegation or parallel agent work.

## Working Convention

- Use Vietnamese for discussion with the user.
- Use English for code, comments, identifiers, and commit messages.
- Prefer minimal, structurally correct changes over broad refactors.
- Do not edit generated files manually:
  - `**/*.g.dart`
  - `**/*.freezed.dart`
  - `lib/l10n/generated/**`
  - platform-generated Flutter files unless the task explicitly requires it

## Repo Routing

### `docs/business/**`

- Source of truth for business behavior.
- If product behavior changes, update the relevant business doc first or in the same change.
- If a capability becomes part of the main app scope, also update `docs/business/system/overview.md`.

### `docs/database/**`

- Source of truth for local persistence design.
- Any Drift schema change under `lib/data/datasources/local/**` must stay aligned with:
  - `docs/database/schema-v1.md`
  - `docs/database/implementation-notes.md`
  - `docs/database/storage-boundaries.md`

### `lib/app/**`

- App bootstrap, DI, router, global config only.
- Do not place feature business logic here.
- `lib/main.dart` is the canonical app shell entrypoint.

### `lib/core/**`

- Shared non-feature building blocks only.
- `lib/core/theme/**` is the design-system source of truth.
- Do not add ad hoc feature helpers here unless they are genuinely cross-feature.

### `lib/data/**`

- DTOs, mappers, datasources, repository implementations.
- Drift code stays in `lib/data/datasources/local/**`.
- Keep transactions and persistence details in `data`, not in `presentation`.

### `lib/domain/**`

- Pure domain layer.
- Must not import Flutter UI libraries, Drift, or data-layer implementations.

### `lib/presentation/**`

- Feature UI, providers, viewmodels, and shared UI.
- Must not import Drift or concrete data-layer implementations.
- Prefer `presentation/shared/**` widgets before building one-off UI patterns inside a feature.

### `test/**`

- Add or update targeted tests for the area touched.
- Prefer tests near the affected layer and feature.

### `tools/guard/**`

- Repo-local architectural guardrail.
- Treat `tools/guard/policies/memox/**` as enforceable repo contract, not optional guidance.

## Architecture Contract

- Use Riverpod Annotation providers for app state and dependency wiring.
- Widgets should `ref.watch(...)` for render state and `ref.read(...)` inside callbacks.
- Do not put multi-step business logic, query orchestration, or persistence logic inside widgets.
- Keep feature boundaries explicit. Do not import screens or widgets directly from another feature.
- Promote reused UI patterns into `lib/presentation/shared/**` instead of duplicating them across features.

## UI And Theme Contract

- UI code should consume colors from `Theme.of(context).colorScheme` or theme extensions, not raw palette files.
- UI code should consume typography from `Theme.of(context).textTheme`, not custom inline `TextStyle(...)` unless there is a strong repo-local reason.
- Prefer shared layout primitives such as `MxAdaptiveScaffold`, `MxScaffold`, and `MxContentShell`.
- Use spacing, radius, and sizing tokens from `lib/core/theme/**` instead of raw literals when a token already exists.

## Database Contract

- Local database is SQLite via Drift.
- Current entrypoint: `lib/data/datasources/local/app_database.dart`.
- Keep:
  - `TEXT` ids for entities
  - `TEXT` values for enums
  - UTC epoch milliseconds for timestamps
  - foreign keys enabled
  - WAL mode enabled
- Do not change schema table names, enum semantics, or lifecycle states casually. Update docs and tests in the same change.
- Generated Drift files must come from codegen, never by manual edits.

## Localization Contract

- User-facing strings belong in `lib/l10n/*.arb`.
- Keep `flutter.generate: true` and `flutter_localizations` enabled in `pubspec.yaml`.
- `lib/main.dart` must preserve:
  - `AppLocalizations.localizationsDelegates`
  - `AppLocalizations.supportedLocales`
  - `onGenerateTitle: (context) => AppLocalizations.of(context).appName`

## Verification

For Dart or Flutter code changes, run the strongest relevant checks in this order:

1. `dart run build_runner build --delete-conflicting-outputs` when touching Drift tables, Riverpod annotations, Freezed, or JSON-serializable models
2. `python tools/guard/run.py --policy memox`
3. `flutter analyze`
4. Targeted `flutter test` commands for the affected area

Examples:

- Database changes: run the build step, guard, analyze, and the relevant test under `test/data/**`
- UI or feature changes: run guard, analyze, and targeted tests under `test/` when present
- Docs-only changes: manually verify consistency across `docs/business/**`, `docs/database/**`, and any code contract affected by the doc change

Do not claim completion if a relevant verification step was skipped or failed. State exactly what was not run.

## Generated And Review-Sensitive Files

- If codegen is required, include the generated outputs in the workspace result.
- Do not hand-edit:
  - `lib/app/di/providers.g.dart`
  - `lib/app/router/*.g.dart`
  - `lib/presentation/**/providers/*.g.dart`
  - `lib/data/datasources/local/app_database.g.dart`
- If a generated file changes unexpectedly, inspect the source file first instead of patching the generated output.

## Docs Sync Rules

- If a task changes study/session/SRS semantics, sync both `docs/business/**` and `docs/database/**` when the persistence contract is affected.
- If a task changes only implementation detail without changing business meaning, keep docs unchanged.
- If docs and code disagree, do not silently choose one. Either sync them in the same change or call out the mismatch explicitly.
