# Decision Tables

Decision Table markdown files are the source of truth for behavior test coverage.

Each `*_test.dart` file must have one matching markdown document under this
directory. The document must declare its executable test file:

```markdown
Test file: `test/presentation/example_screen_test.dart`
```

Each event table must use this shape:

```markdown
## Decision table: onDelete

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | selected item exists | delete action is available | user confirms deletion | item is removed | C0+C1 |
```

Executable tests must use matching names:

```dart
testWidgets('DT1 onDelete: removes selected item after confirmation succeeds', ...)
```

The MemoX guard reads these markdown files and compares them with the Dart test
case names. Test-file comments are not treated as Decision Table coverage.

Rows must describe the real decision branch, concrete setup, concrete trigger,
and concrete assertion. Generated filler such as `test fixture creates ...`,
`command under test`, `assertions verify ...`, `branch for ...`, or
`observable result proves ...` is invalid and should fail review.

Each event table must declare coverage intent:

- `C0`: statement or line path coverage.
- `C1`: branch or decision path coverage.
- `C0+C1`: the row covers both the executed path and the decision branch.

Every event table must cover both `C0` and `C1` across its rows.

## CRUD Flow Coverage

For a persistent entity flow, the Decision Table is incomplete if it only
documents the happy-path create case. Folder, deck, flashcard, item, record, and
similar CRUD surfaces must declare rows and executable tests for the full CRUD
contract exposed by the UI:

- `onInsert`: create or add the entity.
- `onDisplay`: open and render an existing entity or list row.
- `onUpdate`: edit, rename, save, move, reorder, or otherwise mutate it.
- `onDelete`: delete it through the destructive path and confirmation UI when
  the product requires confirmation.

If a CRUD operation is intentionally unavailable, the markdown must say that
explicitly before the executable case is omitted. Do not treat a single create
test as coverage for the flow.
