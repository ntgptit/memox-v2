import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/guess/guess_option_builder.dart';

StudyFlashcardRef _card(String id, {String? front, String? back}) =>
    StudyFlashcardRef(
      id: id,
      deckId: 'deck-1',
      front: front ?? 'front-$id',
      back: back ?? 'back-$id',
      sourcePool: SessionItemSourcePool.due,
    );

void main() {
  group('GuessOptionBuilder', () {
    test('includes the correct answer exactly once', () {
      final current = _card('c1');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [
          current,
          _card('c2'),
          _card('c3'),
          _card('c4'),
          _card('c5'),
        ],
        seed: 'seed-1',
      );
      final correct = set.options.where((o) => o.isCorrect).toList();
      expect(correct, hasLength(1));
      expect(correct.single.id, 'c1');
      expect(set.correctOptionId, 'c1');
    });

    test('returns 5 options when at least 4 valid decoys exist', () {
      final current = _card('c1');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [
          _card('c2'),
          _card('c3'),
          _card('c4'),
          _card('c5'),
          _card('c6'),
        ],
        seed: 'seed-2',
      );
      expect(set.options, hasLength(5));
    });

    test('excludes the current card from decoys', () {
      final current = _card('c1');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [current, _card('c2'), _card('c3')],
        seed: 'seed-3',
      );
      final decoyIds = set.options
          .where((o) => !o.isCorrect)
          .map((o) => o.id)
          .toList();
      expect(decoyIds, isNot(contains('c1')));
    });

    test('excludes decoys with back matching the correct back', () {
      final current = _card('c1', back: 'library');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [
          _card('c2', back: 'Library'),
          _card('c3', back: ' library '),
          _card('c4', back: 'school'),
          _card('c5', back: 'hospital'),
        ],
        seed: 'seed-4',
        shuffle: false,
      );
      final backs = set.options.map((o) => o.back).toList();
      expect(backs, ['library', 'school', 'hospital']);
    });

    test('excludes blank/whitespace backs', () {
      final current = _card('c1', back: 'library');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [
          _card('c2', back: ''),
          _card('c3', back: '   '),
          _card('c4', back: 'school'),
        ],
        seed: 'seed-5',
        shuffle: false,
      );
      expect(set.options.map((o) => o.id), ['c1', 'c4']);
    });

    test('no duplicate option text', () {
      final current = _card('c1', back: 'library');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [
          _card('c2', back: 'school'),
          _card('c3', back: 'school'),
          _card('c4', back: 'office'),
          _card('c5', back: 'hospital'),
        ],
        seed: 'seed-6',
      );
      final normalized = set.options
          .map((o) => o.back.trim().toLowerCase())
          .toList();
      expect(normalized.toSet().length, normalized.length);
    });

    test('deterministic order with same seed', () {
      final current = _card('c1');
      final candidates = [
        _card('c2'),
        _card('c3'),
        _card('c4'),
        _card('c5'),
        _card('c6'),
      ];
      final a = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: candidates,
        seed: 'stable-seed',
      );
      final b = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: candidates,
        seed: 'stable-seed',
      );
      expect(
        a.options.map((o) => o.id).toList(),
        b.options.map((o) => o.id).toList(),
      );
    });

    test('different seed may produce different order when enough options', () {
      final current = _card('c1');
      final candidates = [
        _card('c2'),
        _card('c3'),
        _card('c4'),
        _card('c5'),
        _card('c6'),
        _card('c7'),
        _card('c8'),
      ];
      bool sameOrderEverywhere = true;
      final base = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: candidates,
        seed: 'seed-A',
      ).options.map((o) => o.id).toList();
      for (final seed in ['seed-B', 'seed-C', 'seed-D', 'seed-E']) {
        final order = GuessOptionBuilder.build(
          currentCard: current,
          candidateCards: candidates,
          seed: seed,
        ).options.map((o) => o.id).toList();
        if (order.join(',') != base.join(',')) {
          sameOrderEverywhere = false;
          break;
        }
      }
      expect(sameOrderEverywhere, isFalse);
    });

    test(
      'fewer than 4 valid decoys returns available decoys without crashing',
      () {
        final current = _card('c1');
        final set = GuessOptionBuilder.build(
          currentCard: current,
          candidateCards: [_card('c2'), _card('c3')],
          seed: 'seed-fewer',
        );
        expect(set.options, hasLength(3));
        expect(
          set.options.where((o) => o.isCorrect).map((o) => o.id),
          ['c1'],
        );
      },
    );

    test('no valid decoys returns only the correct option', () {
      final current = _card('c1', back: 'library');
      final set = GuessOptionBuilder.build(
        currentCard: current,
        candidateCards: [_card('c2', back: ''), _card('c3', back: 'library')],
        seed: 'seed-empty',
      );
      expect(set.options, hasLength(1));
      expect(set.options.single.isCorrect, isTrue);
      expect(set.hasDecoys, isFalse);
    });

    test('options list is unmodifiable', () {
      final set = GuessOptionBuilder.build(
        currentCard: _card('c1'),
        candidateCards: [_card('c2'), _card('c3')],
        seed: 'seed-unmod',
      );
      expect(
        () => set.options.add(
          const GuessOption(id: 'x', front: 'x', back: 'x', isCorrect: false),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
