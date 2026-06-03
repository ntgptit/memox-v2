import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../domain/study/usecases/deck_study_entry_usecase.dart';
import '../../../shared/providers/study_revision_providers.dart';

part 'deck_study_entry_provider.g.dart';

/// Deck-scoped study-entry summary (card/due counts + resumable session) used by
/// the Flashcard List study banners. Re-resolves when deck content changes
/// (cards added/removed/imported/deleted) or when a study session is
/// created/cancelled/finalized, so the banners stay in sync with the gate.
@riverpod
Future<DeckStudyEntry> deckStudyEntry(Ref ref, String deckId) async {
  ref.watch(contentDataRevisionProvider);
  ref.watch(studySessionDataRevisionProvider);
  return ref.watch(getDeckStudyEntryUseCaseProvider).execute(deckId);
}
