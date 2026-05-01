abstract interface class AppLogger {
  void error(String message, Object error, StackTrace stackTrace);
}

final class NoopAppLogger implements AppLogger {
  const NoopAppLogger();

  @override
  void error(String message, Object error, StackTrace stackTrace) {}
}
