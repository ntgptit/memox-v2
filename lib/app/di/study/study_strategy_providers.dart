import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/study/strategy/study_mode_strategy.dart';
import '../../../domain/study/strategy/study_strategy.dart';
import '../../../domain/study/strategy/study_strategy_factory.dart';

part 'study_strategy_providers.g.dart';

@riverpod
StudyFlowStrategyFactory studyStrategyFactory(Ref ref) =>
    StudyFlowStrategyFactory(const <StudyFlowStrategy>[
      NewStudyStrategy(),
      SrsReviewStrategy(),
    ]);

@riverpod
StudyModeStrategyFactory studyModeStrategyFactory(Ref ref) =>
    StudyModeStrategyFactory(const <StudyModeStrategy>[
      ReviewModeStrategy(),
      MatchModeStrategy(),
      GuessModeStrategy(),
      RecallModeStrategy(),
      FillModeStrategy(),
    ]);
