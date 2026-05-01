import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../app/di/study_providers.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../study/providers/study_session_notifier.dart';

part 'dashboard_overview_viewmodel.g.dart';

const dashboardDeckHighlightLimit = 3;

@immutable
final class DashboardOverviewState {
  const DashboardOverviewState({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.newCardCount,
    required this.activeSessionCount,
    required this.folderCount,
    required this.deckCount,
    required this.cardCount,
    required this.masteryPercent,
    required this.resumeSessionId,
    required this.deckHighlights,
  });

  final int overdueCount;
  final int dueTodayCount;
  final int newCardCount;
  final int activeSessionCount;
  final int folderCount;
  final int deckCount;
  final int cardCount;
  final int masteryPercent;
  final String? resumeSessionId;
  final List<DashboardDeckHighlightItem> deckHighlights;

  int get reviewCount => overdueCount + dueTodayCount;
  bool get hasReviewCards => reviewCount > 0;
  bool get hasNewCards => newCardCount > 0;
  bool get hasActiveSessions => activeSessionCount > 0;
}

@immutable
final class DashboardDeckHighlightItem {
  const DashboardDeckHighlightItem({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final String id;
  final String name;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;

  bool get hasBeenStudied => lastStudiedAt != null;
}

@Riverpod(keepAlive: true)
Future<DashboardOverviewState> dashboardOverview(Ref ref) async {
  ref.watch(contentDataRevisionProvider);
  ref.watch(studySessionDataRevisionProvider);

  final library = await ref
      .watch(watchLibraryOverviewUseCaseProvider)
      .execute(const ContentQuery());
  final activeSessions = await ref
      .watch(resumeStudySessionUseCaseProvider)
      .listActiveSessions();
  final deckHighlights = await ref
      .watch(getDeckHighlightsUseCaseProvider)
      .execute(limit: dashboardDeckHighlightLimit);
  final cardCount = library.folders.fold<int>(
    0,
    (sum, folder) => sum + folder.itemCount,
  );
  final deckCount = library.folders.fold<int>(
    0,
    (sum, folder) => sum + folder.deckCount,
  );
  final weightedMasteryTotal = library.folders.fold<int>(
    0,
    (sum, folder) => sum + folder.itemCount * folder.masteryPercent,
  );
  final masteryPercent = cardCount == 0
      ? 0
      : (weightedMasteryTotal / cardCount).round();

  return DashboardOverviewState(
    overdueCount: library.overdueCount,
    dueTodayCount: library.dueTodayCount,
    newCardCount: library.newCardCount,
    activeSessionCount: activeSessions.length,
    folderCount: library.totalFolderCount,
    deckCount: deckCount,
    cardCount: cardCount,
    masteryPercent: masteryPercent,
    resumeSessionId: activeSessions.length == 1
        ? activeSessions.single.session.id
        : null,
    deckHighlights: deckHighlights
        .map(_mapDeckHighlight)
        .toList(growable: false),
  );
}

DashboardDeckHighlightItem _mapDeckHighlight(DeckHighlightReadModel item) {
  return DashboardDeckHighlightItem(
    id: item.deck.id,
    name: item.deck.name,
    cardCount: item.cardCount,
    dueTodayCount: item.dueTodayCount,
    masteryPercent: item.masteryPercent,
    lastStudiedAt: item.lastStudiedAt,
  );
}
