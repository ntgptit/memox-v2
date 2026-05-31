import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/srs_interval_policy.dart';

void main() {
  test('DT1 intervals: exposes the current runtime SRS ladder', () {
    expect(SrsIntervalPolicy.boxes, const <int>[1, 2, 3, 4, 5, 6, 7, 8]);
    expect(SrsIntervalPolicy.intervalForBox(1), Duration.zero);
    expect(SrsIntervalPolicy.intervalForBox(2), const Duration(days: 1));
    expect(SrsIntervalPolicy.intervalForBox(3), const Duration(days: 3));
    expect(SrsIntervalPolicy.intervalForBox(4), const Duration(days: 7));
    expect(SrsIntervalPolicy.intervalForBox(5), const Duration(days: 14));
    expect(SrsIntervalPolicy.intervalForBox(6), const Duration(days: 30));
    expect(SrsIntervalPolicy.intervalForBox(7), const Duration(days: 60));
    expect(SrsIntervalPolicy.intervalForBox(8), const Duration(days: 120));
  });

  test('DT2 intervals: rejects unsupported boxes', () {
    expect(() => SrsIntervalPolicy.intervalForBox(0), throwsArgumentError);
    expect(() => SrsIntervalPolicy.intervalForBox(9), throwsArgumentError);
  });
}
