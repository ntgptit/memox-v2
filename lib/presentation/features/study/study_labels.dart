import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../domain/enums/study_enums.dart';
import '../../../domain/study/entities/study_models.dart';

String studyProgressLabel(
  AppLocalizations l10n,
  StudySessionSnapshot snapshot,
) {
  final item = snapshot.currentItem;
  if (item == null) {
    return l10n.studyReadyToFinalizeTitle;
  }
  return l10n.studyProgressModeRound(
    studyModeLabel(l10n, item.studyMode),
    item.roundIndex,
  );
}

String studyModeLabel(AppLocalizations l10n, StudyMode mode) {
  return switch (mode) {
    StudyMode.review => l10n.studyModeReview,
    StudyMode.match => l10n.studyModeMatch,
    StudyMode.guess => l10n.studyModeGuess,
    StudyMode.recall => l10n.studyModeRecall,
    StudyMode.fill => l10n.studyModeFill,
  };
}
