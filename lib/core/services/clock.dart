abstract interface class Clock {
  DateTime nowUtc();

  int nowEpochMillis();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  int nowEpochMillis() => nowUtc().millisecondsSinceEpoch;
}
