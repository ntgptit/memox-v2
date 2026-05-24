import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/deck_providers.dart';
import '../../../../domain/value_objects/content_actions.dart';

part 'flashcard_editor_destinations_provider.g.dart';

/// All decks (with breadcrumb) the create-card screen can re-target to.
///
/// Loaded once per session via [ListDeckDestinationsUseCase]; the picker sheet
/// reads from this provider and selecting a row updates the editor draft via
/// `FlashcardEditorDraft.setDestinationDeck`.
@riverpod
Future<List<DeckMoveTarget>> flashcardEditorDestinations(Ref ref) => ref.read(listDeckDestinationsUseCaseProvider).execute();
