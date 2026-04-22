/// App shell barrel file.
///
/// The concrete `MemoxApp` root widget lives in `lib/main.dart` so the
/// bootstrap layer carries the full MaterialApp + localization wiring.
/// This file re-exposes it for tests and downstream tooling that reach
/// the app through the standard `lib/app/app.dart` entrypoint.
library;

export '../main.dart' show MemoxApp;
