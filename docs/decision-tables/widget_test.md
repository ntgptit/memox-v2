# Decision Tables: widget_test

Test file: `test/widget_test.dart`

## Decision table: onDisplay

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | root smoke test renders a simple `MxTermRow` | material app contains `MxTermRow(term: Greeting, definition: Hello -> Xin chao, caption: Basic greeting)` | widget test pumps the app | term, definition, and caption texts are all visible | C0+C1 |
