import 'dart:math';

import 'package:memox/core/utils/string_utils.dart';

import '../entities/study_models.dart';

/// Maximum number of decoy (incorrect) options surfaced by Guess mode.
const int kGuessDecoyLimit = 4;

/// Domain model for a single Guess-mode option.
final class GuessOption {
  const GuessOption({
    required this.id,
    required this.front,
    required this.back,
    required this.isCorrect,
  });

  final String id;
  final String front;
  final String back;
  final bool isCorrect;
}

/// Deterministic set of Guess options for one card.
final class GuessOptionSet {
  const GuessOptionSet({
    required this.currentCardId,
    required this.options,
    required this.correctOptionId,
  });

  final String currentCardId;
  final List<GuessOption> options;
  final String correctOptionId;

  bool get hasDecoys => options.length > 1;
}

/// Domain-level deterministic builder for Guess-mode options.
///
/// Given the current card and a candidate pool, produces a `GuessOptionSet`
/// with the correct answer included exactly once and up to [decoyLimit]
/// valid decoys (default 4 → 5 options total).
///
/// Determinism: the same `seed` + same ordered inputs always yields the same
/// option order. No `DateTime.now()` or unseeded `Random` is used.
abstract final class GuessOptionBuilder {
  static GuessOptionSet build({
    required StudyFlashcardRef currentCard,
    required List<StudyFlashcardRef> candidateCards,
    required String seed,
    int decoyLimit = kGuessDecoyLimit,
    bool shuffle = true,
  }) {
    final correct = GuessOption(
      id: currentCard.id,
      front: currentCard.front,
      back: currentCard.back,
      isCorrect: true,
    );

    final correctBackKey = _normalize(currentCard.back);
    final correctFrontKey = _normalize(currentCard.front);

    final seenIds = <String>{currentCard.id};
    final seenBackKeys = <String>{
      if (correctBackKey.isNotEmpty) correctBackKey,
    };

    final decoyCandidates = <StudyFlashcardRef>[];
    for (final candidate in candidateCards) {
      if (candidate.id == currentCard.id) continue;
      if (!seenIds.add(candidate.id)) continue;
      final backKey = _normalize(candidate.back);
      if (backKey.isEmpty) continue;
      if (backKey == correctBackKey) continue;
      if (backKey == correctFrontKey) continue;
      if (!seenBackKeys.add(backKey)) continue;
      decoyCandidates.add(candidate);
    }
    final selectedDecoys = decoyCandidates.toList(growable: true);
    if (selectedDecoys.length > 1) {
      selectedDecoys.shuffle(Random(_stableSeed('$seed:decoys')));
    }
    final validDecoys = selectedDecoys.take(decoyLimit).toList(growable: false);

    final options = <GuessOption>[
      correct,
      for (final decoy in validDecoys)
        GuessOption(
          id: decoy.id,
          front: decoy.front,
          back: decoy.back,
          isCorrect: false,
        ),
    ];

    if (shuffle && options.length > 1) {
      options.shuffle(Random(_stableSeed('$seed:options')));
    }

    return GuessOptionSet(
      currentCardId: currentCard.id,
      options: List<GuessOption>.unmodifiable(options),
      correctOptionId: currentCard.id,
    );
  }
}

String _normalize(String value) => StringUtils.normalizedForComparison(value);

int _stableSeed(String raw) {
  var hash = 0;
  for (final codeUnit in raw.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  return hash;
}
