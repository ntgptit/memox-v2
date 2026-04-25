import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../actions/deck_quick_actions.dart';
import '../widgets/deck_detail_skeleton.dart';
import '../widgets/deck_header_section.dart';
import '../widgets/deck_stats_section.dart';
import '../widgets/deck_study_action_section.dart';
import '../viewmodels/deck_detail_viewmodel.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen<AsyncValue<void>>(deckActionControllerProvider(deckId), (
      _,
      next,
    ) {
      final failure = deckActionError(next);
      if (failure != null) {
        MxSnackbar.error(context, deckActionErrorMessage(failure));
      }
    });

    final queryState = ref.watch(deckDetailQueryProvider(deckId));

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.wide,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<DeckDetailState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          skeletonBuilder: (_) => const DeckDetailSkeleton(),
          onRetry: () => ref.invalidate(deckDetailQueryProvider(deckId)),
          dataBuilder: (context, state) {
            final lastStudiedLabel = l10n.decksLastStudiedLabel(
              _formatLastStudied(context, state.lastStudiedAt),
            );
            return ListView(
              children: [
                DeckHeaderSection(
                  state: state,
                  onBack: () => context.popRoute(
                    fallback: () => context.goFolderDetail(state.folderId),
                  ),
                  onOpenActions: () => showDeckActions(
                    context: context,
                    ref: ref,
                    deckId: state.id,
                    deckName: state.name,
                    state: state,
                    onDeleted: () async {
                      await context.popRoute(
                        fallback: () => context.goFolderDetail(state.folderId),
                      );
                    },
                  ),
                  onOpenBreadcrumb: (folderId) =>
                      context.goFolderDetail(folderId),
                ),
                const MxGap(MxSpace.xl),
                DeckStatsSection(
                  state: state,
                  lastStudiedLabel: lastStudiedLabel,
                ),
                const MxGap(MxSpace.xl),
                DeckStudyActionSection(
                  cardCount: state.cardCount,
                  dueTodayCount: state.dueTodayCount,
                  onOpenFlashcards: () => context.pushFlashcardList(state.id),
                  onAddFlashcard: () => context.pushFlashcardCreate(state.id),
                  onImport: () => context.pushDeckImport(state.id),
                  onStartStudy: () => context.goStudyEntry(
                    entryType: 'deck',
                    entryRefId: state.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatLastStudied(BuildContext context, int? value) {
  final l10n = AppLocalizations.of(context);
  if (value == null) {
    return l10n.commonNever;
  }

  final date = DateTime.fromMillisecondsSinceEpoch(
    value,
    isUtc: true,
  ).toLocal();
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}
