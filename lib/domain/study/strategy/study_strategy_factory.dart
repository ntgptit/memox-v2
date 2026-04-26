import '../../enums/study_enums.dart';
import 'study_strategy.dart';

class StudyFlowStrategyFactory {
  StudyFlowStrategyFactory(Iterable<StudyFlowStrategy> strategies)
    : _byType = _buildMap(strategies);

  final Map<StudyType, StudyFlowStrategy> _byType;

  StudyFlowStrategy of(StudyType type) {
    final strategy = _byType[type];
    if (strategy == null) {
      throw StateError('No StudyFlowStrategy registered for $type.');
    }
    return strategy;
  }

  static Map<StudyType, StudyFlowStrategy> _buildMap(
    Iterable<StudyFlowStrategy> strategies,
  ) {
    final byType = <StudyType, StudyFlowStrategy>{};
    for (final strategy in strategies) {
      final previous = byType[strategy.handleType];
      if (previous != null) {
        throw StateError(
          'Duplicate StudyFlowStrategy for ${strategy.handleType}.',
        );
      }
      byType[strategy.handleType] = strategy;
    }
    final missingTypes = StudyType.values.where(
      (type) => !byType.containsKey(type),
    );
    if (missingTypes.isNotEmpty) {
      throw StateError(
        'Missing StudyFlowStrategy for ${missingTypes.join(', ')}.',
      );
    }
    return Map.unmodifiable(byType);
  }
}

final class StudyStrategyFactory extends StudyFlowStrategyFactory {
  StudyStrategyFactory(super.strategies);
}
