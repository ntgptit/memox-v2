# Decision Tables: content_overview_metrics_test

Test file: `test/domain/content_overview_metrics_test.dart`

## Decision table: calculateMetrics

| ID | Branch / condition | Given | When | Then | Coverage |
| --- | --- | --- | --- | --- | --- |
| DT1 | library has no folder card counts | overview has no folders and no cards | aggregate metrics are read | deck count, card count, and mastery percent all return zero without dividing by zero | C0+C1 |
| DT2 | folders have different card counts and mastery percentages | overview has one folder with two cards at 25% mastery and another with six cards at 75% mastery | aggregate metrics are read | deck count sums to four, card count sums to eight, and weighted mastery rounds to 63% | C0+C1 |
