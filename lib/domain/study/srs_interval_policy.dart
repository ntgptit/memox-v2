abstract final class SrsIntervalPolicy {
  const SrsIntervalPolicy._();

  static const int minBox = 1;
  static const int maxBox = 8;

  static const List<int> boxes = <int>[1, 2, 3, 4, 5, 6, 7, 8];

  static Duration intervalForBox(int box) => switch (box) {
    1 => Duration.zero,
    2 => const Duration(days: 1),
    3 => const Duration(days: 3),
    4 => const Duration(days: 7),
    5 => const Duration(days: 14),
    6 => const Duration(days: 30),
    7 => const Duration(days: 60),
    8 => const Duration(days: 120),
    _ => throw ArgumentError.value(box, 'box', 'Unsupported SRS box.'),
  };
}
