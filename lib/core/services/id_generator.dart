import 'dart:math';

abstract interface class IdGenerator {
  String nextId();
}

final class RandomIdGenerator implements IdGenerator {
  RandomIdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String nextId() {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch
        .toRadixString(36);
    final entropy = List<int>.generate(
      6,
      (_) => _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
    );
    return '$timestamp-${String.fromCharCodes(entropy)}';
  }

  static const String _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
}
