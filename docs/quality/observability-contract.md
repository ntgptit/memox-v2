---
last_updated: 2026-05-26
status: contract
---

# Observability Contract

Logging and error reporting policy. MemoX is local-first with no remote telemetry. All logs are local, used for debugging only.

## Logging library

`package:logging` (Dart standard). One logger per feature, accessed via:

```dart
final _log = Logger('study.session');
```

Logger naming follows feature folder path with dots: `dashboard`, `library`, `library.search`, `study.session`, `study.srs`, `data.sync`, `core.tts`, `core.auth`.

## Levels

| Level | When |
| --- | --- |
| `Level.SEVERE` | `IntegrityFailure`, unrecoverable storage error, programmer error caught at boundary, uncaught exception in app shell |
| `Level.WARNING` | Unexpected `StorageFailure`, retry exhausted on network, token refresh failed, migration rollback |
| `Level.INFO` | Use case entry/exit for significant ops (session create, finalize, import commit, sync upload/restore), migration steps, app boot |
| `Level.FINE` | Use case entry/exit for routine ops (read flashcard list), provider invalidation |
| `Level.FINER` | Per-card grade attempt (in dev mode only) |
| `Level.FINEST` | Detailed loop trace (off by default) |

In production builds, level threshold is `Level.INFO`. In debug builds, `Level.FINE`. Configurable via `kReleaseMode` flag.

## What to log

| Event | Level | Content |
| --- | --- | --- |
| Use case entry | INFO/FINE | Use case name + non-PII params |
| Use case exit success | INFO/FINE | Use case name + result type |
| Use case exit failure | WARNING | Use case name + failure type (not user data) |
| Migration applied | INFO | From version → to version |
| App boot | INFO | Build flavor + app version |
| Provider invalidation | FINE | Provider name + reason |
| Drift transaction commit | FINE | Transaction tag |
| Sync upload start/end | INFO | Manifest size, duration |
| Sync restore start/end | INFO | Manifest device label + uploaded_at, duration |
| Snapshot creation | INFO | Path, size |
| Token refresh | INFO | Success/fail (no token value) |
| TTS engine init | INFO | Engine name, language |
| TTS playback start | FINE | Language, char count (NOT text content) |
| Uncaught exception (Zone) | SEVERE | Type, message, stack |

## PII rule (strict)

NEVER log:

- Flashcard `front` or `back` text content.
- Tag names (user-created could contain personal info).
- Folder/deck names.
- OAuth tokens, refresh tokens.
- Account email (log a hash/prefix if needed for cross-correlation).
- Fingerprint values.
- File system paths beyond app sandbox root.
- Note / example / pronunciation / hint fields.

Where size or count matters, log the count (e.g., "Imported 18 cards") not the content.

## What to log INSTEAD of PII

- IDs (UUIDs) are OK to log — they're opaque.
- Counts, sizes, durations.
- Failure type and code (`ValidationFailure code=tooLong field=tag`).
- Boolean states (`hasResumable=true`).
- Enum values (`AttemptResult.forgot`).

## Format

```
[YYYY-MM-DD HH:MM:SS.mmm][LEVEL][logger.name] message {key=value, key=value}
```

Example:

```
[2026-05-26 14:32:18.412][INFO][study.session] grade_attempt result=perfect boxBefore=3 boxAfter=4 mode=review duration_ms=42
```

## Error handling and logging interplay

| Situation | What to do |
| --- | --- |
| Catching expected `Failure` at notifier | Log WARNING with failure type, update state |
| Catching unexpected `Exception` at boundary | Log SEVERE with stack, map to `IntegrityFailure` or `StorageFailure` |
| Empty catch block | FORBIDDEN. Either log or rethrow. |
| Catch + ignore (intentional) | Log FINE with explicit comment explaining why |
| Catch + rethrow | Log FINE before rethrow if useful context, else just rethrow |

## Error reporting (no remote)

MemoX v1 does NOT send crash reports. Optional future: opt-in local dump exported when user taps "Report a bug" in About.

For now:

- Crashes during development go to console.
- Uncaught zones go to console + persistent log file (rotated).
- Persistent log file path: `{appSupportDir}/logs/memox-{date}.log`. Rotation: keep last 7 days.

## Talker integration (optional)

If/when integrating Talker:

- Use as a viewer for the same `package:logging` events (Talker can consume).
- Talker history MUST respect PII rule.
- Talker UI accessible via Settings → About → Show logs (developer mode only).
- Production builds: Talker MUST NOT be accessible to end users.

## Forbidden patterns

- ❌ `print()` or `debugPrint()` in production code paths.
- ❌ Log PII (see list above).
- ❌ Empty `catch {}` block.
- ❌ Catch + `print(e)`. Use logger.
- ❌ `Logger.severe` for any recoverable case.
- ❌ Same logger name across unrelated features (sharing).
- ❌ Logger as global mutable state. Use `Logger('name')` lookup per call site.

## Required patterns

- ✅ Setup root logger in `main.dart` with level threshold.
- ✅ Wrap `runApp` in `runZonedGuarded` to catch async uncaught errors → SEVERE log.
- ✅ Each use case has one INFO/FINE entry log and one INFO/FINE / WARNING exit log.
- ✅ Strip log file writes in test builds.

## Forbidden in tests

- ❌ Production logger writing to disk in tests. Use in-memory log capture if assertion needed.

## Agent rule

- When implementing a use case: add `_log.info('use_case_name entry params=...')` at start and one of:
  - `_log.fine('use_case_name success result=...')` on success
  - `_log.warning('use_case_name failure type=...')` on failure
- When catching exception in data layer: WARNING with failure type, never SEVERE unless `IntegrityFailure`.
- When adding a new log site: verify no PII in content.

## Related

**Repo-level:**

- `CLAUDE.md` — code style forbids print/debugPrint

**Contracts:**

- `docs/contracts/error-contract.md` — what to log per failure type
- `docs/contracts/code-style.md` — logger naming
- `docs/quality/performance-contract.md` — trace events for perf-sensitive ops

**Code paths:**

- `lib/core/logging/log_config.dart` — root setup
- `lib/main.dart` — runZonedGuarded
- `lib/core/logging/persistent_log_writer.dart` — file rotation
