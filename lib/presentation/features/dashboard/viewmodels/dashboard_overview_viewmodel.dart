import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/content/deck_providers.dart';
import '../../../../app/di/content/folder_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/providers/study_revision_providers.dart';

part 'dashboard_overview_viewmodel.g.dart';

const dashboardDeckHighlightLimit = 3;

@immutable
final class DashboardOverviewState {
  DashboardOverviewState({
    required int overdueCount,
    required int dueTodayCount,
    required int newCardCount,
    required this.activeSessionCount,
    required int folderCount,
    required int deckCount,
    required int cardCount,
    required int masteryPercent,
    required this.resumeSessionId,
    required this.deckHighlights,
  }) : reviewSummary = DashboardReviewSummary(
         overdueCount: overdueCount,
         dueTodayCount: dueTodayCount,
         newCardCount: newCardCount,
       ),
       librarySummary = DashboardLibrarySummary(
         folderCount: folderCount,
         deckCount: deckCount,
         cardCount: cardCount,
         masteryPercent: masteryPercent,
       );

  final DashboardReviewSummary reviewSummary;
  final int activeSessionCount;
  final DashboardLibrarySummary librarySummary;
  final String? resumeSessionId;
  final List<DashboardDeckHighlightItem> deckHighlights;

  int get overdueCount => reviewSummary.overdueCount;
  int get dueTodayCount => reviewSummary.dueTodayCount;
  int get newCardCount => reviewSummary.newCardCount;
  int get folderCount => librarySummary.folderCount;
  int get deckCount => librarySummary.deckCount;
  int get cardCount => librarySummary.cardCount;
  int get masteryPercent => librarySummary.masteryPercent;
  int get reviewCount => overdueCount + dueTodayCount;
  bool get hasReviewCards => reviewCount > 0;
  bool get hasNewCards => newCardCount > 0;
  bool get hasActiveSessions => activeSessionCount > 0;
}

@immutable
final class DashboardReviewSummary {
  const DashboardReviewSummary({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.newCardCount,
  });

  final int overdueCount;
  final int dueTodayCount;
  final int newCardCount;
}

@immutable
final class DashboardLibrarySummary {
  const DashboardLibrarySummary({
    required this.folderCount,
    required this.deckCount,
    required this.cardCount,
    required this.masteryPercent,
  });

  final int folderCount;
  final int deckCount;
  final int cardCount;
  final int masteryPercent;
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
  return DashboardOverviewState(
    overdueCount: library.overdueCount,
    dueTodayCount: library.dueTodayCount,
    newCardCount: library.newCardCount,
    activeSessionCount: activeSessions.length,
    folderCount: library.totalFolderCount,
    deckCount: library.deckCount,
    cardCount: library.cardCount,
    masteryPercent: library.masteryPercent,
    resumeSessionId: activeSessions.length == 1
        ? activeSessions.single.session.id
        : null,
    deckHighlights: deckHighlights
        .map(_mapDeckHighlight)
        .toList(growable: false),
  );
}

DashboardDeckHighlightItem _mapDeckHighlight(DeckHighlightReadModel item) =>
    DashboardDeckHighlightItem(
      id: item.deck.id,
      name: item.deck.name,
      cardCount: item.cardCount,
      dueTodayCount: item.dueTodayCount,
      masteryPercent: item.masteryPercent,
      lastStudiedAt: item.lastStudiedAt,
    );
