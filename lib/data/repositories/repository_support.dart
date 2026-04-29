import '../../core/errors/error_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/services/clock.dart';
import '../../core/utils/string_utils.dart';

Future<Result<T>> runRepositoryAction<T>(Future<T> Function() action) async {
  try {
    return Success<T>(await action());
  } catch (error, stackTrace) {
    return FailureResult<T>(ErrorMapper.map(error, stackTrace));
  }
}

int computeMasteryPercent(Iterable<int> currentBoxes) {
  final boxes = currentBoxes.toList(growable: false);
  if (boxes.isEmpty) {
    return 0;
  }

  final total = boxes
      .map((box) => ((box - 1).clamp(0, 7) / 7) * 100)
      .reduce((a, b) => a + b);
  return (total / boxes.length).round();
}

int startOfTodayEpochMillis(Clock clock) {
  final localNow = clock.nowUtc().toLocal();
  final startOfTodayLocal = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
  );
  return startOfTodayLocal.toUtc().millisecondsSinceEpoch;
}

int endOfTodayEpochMillis(Clock clock) {
  final localNow = clock.nowUtc().toLocal();
  final endOfTodayLocal = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
    23,
    59,
    59,
    999,
  );
  return endOfTodayLocal.toUtc().millisecondsSinceEpoch;
}

String sanitizeFileName(String raw) {
  final sanitized = StringUtils.trimmed(raw)
      .replaceAll(RegExp(r'[^\w\-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (sanitized.isEmpty) {
    return 'memox_export';
  }
  return sanitized;
}

String escapeCsvCell(String? value) {
  final raw = value ?? '';
  final escaped = raw.replaceAll('"', '""');
  return '"$escaped"';
}
