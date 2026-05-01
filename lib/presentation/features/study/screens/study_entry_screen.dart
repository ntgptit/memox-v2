import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/study/study_settings_policy.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_toggle.dart';
import '../providers/study_entry_notifier.dart';
import '../providers/study_session_notifier.dart';
import '../study_labels.dart';

class StudyEntryScreen extends ConsumerStatefulWidget {
  const StudyEntryScreen({
    required this.entryType,
    required this.entryRefId,
    super.key,
  });

  final String entryType;
  final String? entryRefId;

  @override
  ConsumerState<StudyEntryScreen> createState() => _StudyEntryScreenState();
}

class _StudyEntryScreenState extends ConsumerState<StudyEntryScreen> {
  StudyType? _selectedType;
  int? _batchSize;
  bool? _shuffleFlashcards;
  bool? _shuffleAnswers;
  bool? _prioritizeOverdue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entryState = ref.watch(
      studyEntryStateProvider(widget.entryType, widget.entryRefId),
    );
    final actionState = ref.watch(
      studyEntryActionControllerProvider(widget.entryType, widget.entryRefId),
    );

    ref.listen<AsyncValue<void>>(
      studyEntryActionControllerProvider(widget.entryType, widget.entryRefId),
      (_, next) {
        if (next.hasError) {
          MxSnackbar.error(context, studyErrorMessage(next.error));
        }
      },
    );

    return MxScaffold(
      title: l10n.studyEntryTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<StudyEntryState>(
          data: entryState.value,
          isLoading: entryState.isLoading,
          error: entryState.hasError ? entryState.error : null,
          stackTrace: entryState.hasError ? entryState.stackTrace : null,
          skeletonBuilder: (_) => const _StudyEntryLoadingView(),
          errorBuilder: (_, error, _) => MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(error),
            onRetry: () => ref.invalidate(
              studyEntryStateProvider(widget.entryType, widget.entryRefId),
            ),
          ),
          dataBuilder: (context, state) => ListView(
            children: [
              MxText(l10n.studyEntryHeading, role: MxTextRole.pageTitle),
              const MxGap(MxSpace.sm),
              MxText(l10n.studyEntrySubtitle, role: MxTextRole.contentBody),
              const MxGap(MxSpace.xl),
              if (state.resumeCandidate != null) ...[
                _ResumeCard(candidate: state.resumeCandidate!),
                const MxGap(MxSpace.xl),
              ],
              _FlowCard(
                state: state,
                selectedType: _effectiveType(state),
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    _batchSize = null;
                    _shuffleFlashcards = null;
                    _shuffleAnswers = null;
                    _prioritizeOverdue = null;
                  });
                },
              ),
              const MxGap(MxSpace.xl),
              _SettingsCard(
                settings: _effectiveSettings(state),
                minBatchSize: _minBatchSize(_effectiveType(state)),
                maxBatchSize: _maxBatchSize(_effectiveType(state)),
                onBatchSizeChanged: (value) => setState(() {
                  _batchSize = value;
                }),
                onShuffleFlashcardsChanged: (value) => setState(() {
                  _shuffleFlashcards = value;
                }),
                onShuffleAnswersChanged: (value) => setState(() {
                  _shuffleAnswers = value;
                }),
                onPrioritizeOverdueChanged: (value) => setState(() {
                  _prioritizeOverdue = value;
                }),
              ),
              const MxGap(MxSpace.xl),
              MxPrimaryButton(
                label: state.resumeCandidate == null
                    ? l10n.studyStartAction
                    : l10n.studyStartNewSessionAction,
                leadingIcon: Icons.play_arrow_rounded,
                isLoading: actionState.isLoading,
                fullWidth: true,
                onPressed: () => _start(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StudyType _effectiveType(StudyEntryState state) {
    if (state.entryType == StudyEntryType.today) {
      return StudyType.srsReview;
    }
    return _selectedType ?? StudyType.newStudy;
  }

  StudySettingsSnapshot _effectiveSettings(StudyEntryState state) {
    final base = _effectiveType(state) == StudyType.newStudy
        ? state.newStudyDefaults
        : state.reviewDefaults;
    final studyType = _effectiveType(state);
    return StudySettingsSnapshot(
      batchSize: _clampBatchSize(_batchSize ?? base.batchSize, studyType),
      shuffleFlashcards: _shuffleFlashcards ?? base.shuffleFlashcards,
      shuffleAnswers: _shuffleAnswers ?? base.shuffleAnswers,
      prioritizeOverdue: _prioritizeOverdue ?? base.prioritizeOverdue,
    );
  }

  Future<void> _start(StudyEntryState state) async {
    final restartedFromSessionId = state.resumeCandidate?.session.id;
    if (restartedFromSessionId != null) {
      final shouldStart = await _confirmStartNewSession();
      if (!mounted || !shouldStart) {
        return;
      }
    }

    await _startSession(state, restartedFromSessionId);
  }

  Future<bool> _confirmStartNewSession() {
    final l10n = AppLocalizations.of(context);
    return MxConfirmationDialog.show(
      context: context,
      title: l10n.studyStartNewSessionConfirmTitle,
      message: l10n.studyStartNewSessionConfirmMessage,
      confirmLabel: l10n.studyStartNewSessionAction,
      icon: Icons.play_arrow_rounded,
      tone: MxConfirmationTone.danger,
    );
  }

  Future<void> _startSession(
    StudyEntryState state,
    String? restartedFromSessionId,
  ) async {
    final result = await ref
        .read(
          studyEntryActionControllerProvider(
            widget.entryType,
            widget.entryRefId,
          ).notifier,
        )
        .start(
          studyType: _effectiveType(state),
          settings: _effectiveSettings(state),
          restartedFromSessionId: restartedFromSessionId,
        );
    if (!mounted || result == null) {
      return;
    }
    final error = result.error;
    if (error != null) {
      MxSnackbar.error(context, studyErrorMessage(error));
      return;
    }
    final sessionId = result.sessionId;
    if (sessionId == null) {
      return;
    }
    context.goStudySession(sessionId);
  }
}

int _clampBatchSize(int value, StudyType studyType) {
  return StudySettingsPolicy.clampBatchSize(value, studyType);
}

int _minBatchSize(StudyType studyType) {
  return StudySettingsPolicy.minBatchSize(studyType);
}

int _maxBatchSize(StudyType studyType) {
  return StudySettingsPolicy.maxBatchSize(studyType);
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.candidate});

  final StudySessionSnapshot candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.studyResumeTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxText(
            studyProgressLabel(l10n, candidate),
            role: MxTextRole.contentBody,
          ),
          const MxGap(MxSpace.md),
          MxSecondaryButton(
            label: l10n.studyContinueSessionAction,
            leadingIcon: Icons.history_rounded,
            onPressed: () => context.goStudySession(candidate.session.id),
          ),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.state,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final StudyEntryState state;
  final StudyType selectedType;
  final ValueChanged<StudyType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isToday = state.entryType == StudyEntryType.today;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.studyFlowTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.md),
          MxSegmentedControl<StudyType>(
            segments: [
              if (!isToday)
                MxSegment(
                  value: StudyType.newStudy,
                  label: l10n.studyTypeNew,
                  icon: Icons.auto_stories_outlined,
                ),
              MxSegment(
                value: StudyType.srsReview,
                label: l10n.studyTypeReview,
                icon: Icons.event_available_outlined,
              ),
            ],
            selected: {selectedType},
            onChanged: (selection) => onTypeChanged(selection.first),
          ),
          if (isToday) ...[
            const MxGap(MxSpace.sm),
            MxText(l10n.studyTodayReviewOnly, role: MxTextRole.contentBody),
          ],
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.minBatchSize,
    required this.maxBatchSize,
    required this.onBatchSizeChanged,
    required this.onShuffleFlashcardsChanged,
    required this.onShuffleAnswersChanged,
    required this.onPrioritizeOverdueChanged,
  });

  final StudySettingsSnapshot settings;
  final int minBatchSize;
  final int maxBatchSize;
  final ValueChanged<int> onBatchSizeChanged;
  final ValueChanged<bool> onShuffleFlashcardsChanged;
  final ValueChanged<bool> onShuffleAnswersChanged;
  final ValueChanged<bool> onPrioritizeOverdueChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.studySettingsTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.md),
          Row(
            children: [
              Expanded(
                child: MxText(
                  l10n.studyBatchSizeLabel(settings.batchSize),
                  role: MxTextRole.contentBody,
                ),
              ),
              MxIconButton(
                tooltip: l10n.studyDecreaseBatch,
                onPressed: settings.batchSize <= minBatchSize
                    ? null
                    : () => onBatchSizeChanged(settings.batchSize - 1),
                icon: Icons.remove_rounded,
              ),
              MxIconButton(
                tooltip: l10n.studyIncreaseBatch,
                onPressed: settings.batchSize >= maxBatchSize
                    ? null
                    : () => onBatchSizeChanged(settings.batchSize + 1),
                icon: Icons.add_rounded,
              ),
            ],
          ),
          MxText(
            l10n.studyBatchSizeRangeLabel(minBatchSize, maxBatchSize),
            role: MxTextRole.formHelper,
          ),
          const MxGap(MxSpace.sm),
          MxToggle(
            value: settings.shuffleFlashcards,
            onChanged: onShuffleFlashcardsChanged,
            label: l10n.studyShuffleCards,
          ),
          MxToggle(
            value: settings.shuffleAnswers,
            onChanged: onShuffleAnswersChanged,
            label: l10n.studyShuffleAnswers,
          ),
          MxToggle(
            value: settings.prioritizeOverdue,
            onChanged: onPrioritizeOverdueChanged,
            label: l10n.studyPrioritizeOverdue,
          ),
        ],
      ),
    );
  }
}

class _StudyEntryLoadingView extends StatelessWidget {
  const _StudyEntryLoadingView();

  @override
  Widget build(BuildContext context) {
    return const MxLoadingState();
  }
}
