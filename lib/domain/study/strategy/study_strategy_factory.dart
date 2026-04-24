import '../../enums/study_enums.dart';
import 'study_strategy.dart';

final class StudyStrategyFactory {
  StudyStrategyFactory(Iterable<StudyStrategy> strategies)
    : _byType = _buildMap(strategies);

  final Map<StudyType, StudyStrategy> _byType;

  StudyStrategy of(StudyType type) {
    final strategy = _byType[type];
    if (strategy == null) {
      throw StateError('No StudyStrategy registered for $type.');
    }
    return strategy;
  }

  static Map<StudyType, StudyStrategy> _buildMap(
    Iterable<StudyStrategy> strategies,
  ) {
    final byType = <StudyType, StudyStrategy>{};
    for (final strategy in strategies) {
      final previous = byType[strategy.handleType];
      if (previous != null) {
        throw StateError('Duplicate StudyStrategy for ${strategy.handleType}.');
      }
      byType[strategy.handleType] = strategy;
    }
    return Map.unmodifiable(byType);
  }
}
