import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/content/deck_providers.dart';
import '../../../../app/di/content/folder_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../../domain/value_objects/content_actions.dart';
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
    required this.resumeSessions,
    required int folderCount,
    required int deckCount,
    required int cardCount,
    required int masteryPercent,
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

  /// Resumable (paused) sessions ordered most-recent first.
  final List<DashboardResumeSessionItem> resumeSessions;
  final DashboardLibrarySummary librarySummary;
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

  int get activeSessionCount => resumeSessions.length;
  bool get hasActiveSessions => resumeSessions.isNotEmpty;
  bool get hasMultipleActiveSessions => resumeSessions.length > 1;

  DashboardResumeSessionItem? get primaryResumeSession =>
      resumeSessions.isEmpty ? null : resumeSessions.first;
  String? get resumeSessionId => primaryResumeSession?.sessionId;
}

/// Lightweight projection of a resumable [StudySessionSnapshot] for the
/// Dashboard resume card / paused-sessions sheet. Keeps the widgets and their
/// tests decoupled from the full study snapshot shape (mirrors
/// [DashboardDeckHighlightItem]).
@immutable
final class DashboardResumeSessionItem {
  const DashboardResumeSessionItem({
    required this.sessionId,
    required this.studyType,
    required this.entryType,
    required this.completedSteps,
    required this.totalSteps,
    required this.remainingCount,
    required this.startedAt,
  });

  final String sessionId;
  final StudyType studyType;
  final StudyEntryType entryType;
  final int completedSteps;
  final int totalSteps;
  final int remainingCount;
  final int startedAt;

  double get progress {
    if (totalSteps <= 0) return 0;
    return (completedSteps / totalSteps).clamp(0, 1).toDouble();
  }
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
    resumeSessions: activeSessions
        .map(_mapResumeSession)
        .toList(growable: false),
    folderCount: library.totalFolderCount,
    deckCount: library.deckCount,
    cardCount: library.cardCount,
    masteryPercent: library.masteryPercent,
    deckHighlights: deckHighlights
        .map(_mapDeckHighlight)
        .toList(growable: false),
  );
}

/// All decks available as study scope options for the "Start new learning"
/// scope picker (Deck tab). Read-only.
@riverpod
Future<List<DeckMoveTarget>> dashboardDeckScopeOptions(Ref ref) {
  ref.watch(contentDataRevisionProvider);
  return ref.watch(listDeckDestinationsUseCaseProvider).execute();
}

/// All folders available as study scope options for the "Start new learning"
/// scope picker (Folder tab). Read-only.
@riverpod
Future<List<FolderScopeOption>> dashboardFolderScopeOptions(Ref ref) {
  ref.watch(contentDataRevisionProvider);
  return ref.watch(listAllFoldersUseCaseProvider).execute();
}

DashboardResumeSessionItem _mapResumeSession(StudySessionSnapshot snapshot) {
  final summary = snapshot.summary;
  final totalCards = summary.totalCards > snapshot.sessionFlashcards.length
      ? summary.totalCards
      : snapshot.sessionFlashcards.length;
  final totalSteps = totalCards * summary.totalModeCount;
  final completedSteps = summary.completedAttempts.clamp(0, totalSteps).toInt();
  return DashboardResumeSessionItem(
    sessionId: snapshot.session.id,
    studyType: snapshot.session.studyType,
    entryType: snapshot.session.entryType,
    completedSteps: completedSteps,
    totalSteps: totalSteps,
    remainingCount: summary.remainingCount,
    startedAt: snapshot.session.startedAt,
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
