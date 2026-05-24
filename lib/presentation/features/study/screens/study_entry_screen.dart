import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/study/study_settings_policy.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_error_state.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
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
          dataBuilder: (context, state) => _StudyEntryBody(
            state: state,
            effectiveType: _effectiveType(state),
            effectiveSettings: _effectiveSettings(state),
            isStartLoading: actionState.isLoading,
            onTypeChanged: _handleTypeChanged,
            onBatchSizeChanged: (value) =>
                setState(() => _batchSize = value),
            onShuffleFlashcardsChanged: (value) =>
                setState(() => _shuffleFlashcards = value),
            onShuffleAnswersChanged: (value) =>
                setState(() => _shuffleAnswers = value),
            onPrioritizeOverdueChanged: (value) =>
                setState(() => _prioritizeOverdue = value),
            onStart: () => _start(state),
          ),
        ),
      ),
    );
  }

  void _handleTypeChanged(StudyType type) {
    setState(() {
      _selectedType = type;
      _batchSize = null;
      _shuffleFlashcards = null;
      _shuffleAnswers = null;
      _prioritizeOverdue = null;
    });
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

class _StudyEntryBody extends StatelessWidget {
  const _StudyEntryBody({
    required this.state,
    required this.effectiveType,
    required this.effectiveSettings,
    required this.isStartLoading,
    required this.onTypeChanged,
    required this.onBatchSizeChanged,
    required this.onShuffleFlashcardsChanged,
    required this.onShuffleAnswersChanged,
    required this.onPrioritizeOverdueChanged,
    required this.onStart,
  });

  final StudyEntryState state;
  final StudyType effectiveType;
  final StudySettingsSnapshot effectiveSettings;
  final bool isStartLoading;
  final ValueChanged<StudyType> onTypeChanged;
  final ValueChanged<int> onBatchSizeChanged;
  final ValueChanged<bool> onShuffleFlashcardsChanged;
  final ValueChanged<bool> onShuffleAnswersChanged;
  final ValueChanged<bool> onPrioritizeOverdueChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasResume = state.resumeCandidate != null;
    final ctaLabel = hasResume
        ? l10n.studyStartNewWithCountAction(effectiveSettings.batchSize)
        : l10n.studyStartWithCountAction(effectiveSettings.batchSize);
    return ListView(
      children: [
        if (hasResume) ...[
          _ResumeCard(candidate: state.resumeCandidate!),
          const MxGap(MxSpace.xl),
        ],
        _SectionOverline(label: l10n.studyFlowTitle),
        const MxGap(MxSpace.sm),
        _FlowSection(
          state: state,
          selectedType: effectiveType,
          onTypeChanged: onTypeChanged,
        ),
        const MxGap(MxSpace.xl),
        _SectionOverline(label: l10n.studySettingsTitle),
        const MxGap(MxSpace.sm),
        _SettingsCard(
          settings: effectiveSettings,
          minBatchSize: _minBatchSize(effectiveType),
          maxBatchSize: _maxBatchSize(effectiveType),
          onBatchSizeChanged: onBatchSizeChanged,
          onShuffleFlashcardsChanged: onShuffleFlashcardsChanged,
          onShuffleAnswersChanged: onShuffleAnswersChanged,
          onPrioritizeOverdueChanged: onPrioritizeOverdueChanged,
        ),
        const MxGap(MxSpace.xxl),
        MxPrimaryButton(
          label: ctaLabel,
          leadingIcon: Icons.play_arrow_rounded,
          size: MxButtonSize.compact,
          shape: MxPrimaryButtonShape.pill,
          isLoading: isStartLoading,
          fullWidth: true,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _SectionOverline extends StatelessWidget {
  const _SectionOverline({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MxText(
      StringUtils.uppercased(label),
      role: MxTextRole.overline,
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.candidate});

  final StudySessionSnapshot candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.studyResumeTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.xs),
          MxText(
            studyProgressLabel(l10n, candidate),
            role: MxTextRole.contentBody,
          ),
          const MxGap(MxSpace.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: MxSecondaryButton(
              label: l10n.studyContinueSessionAction,
              leadingIcon: Icons.history_rounded,
              size: MxButtonSize.compact,
              onPressed: () => context.goStudySession(candidate.session.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowSection extends StatelessWidget {
  const _FlowSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          MxText(l10n.studyTodayReviewOnly, role: MxTextRole.formHelper),
        ],
      ],
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
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BatchSizeRow(
            value: settings.batchSize,
            minValue: minBatchSize,
            maxValue: maxBatchSize,
            label: l10n.studyBatchSizeShortLabel,
            rangeHelper: l10n.studyBatchSizeRangeLabel(
              minBatchSize,
              maxBatchSize,
            ),
            onChanged: onBatchSizeChanged,
          ),
          const MxDivider(),
          MxToggle(
            label: l10n.studyShuffleCards,
            value: settings.shuffleFlashcards,
            onChanged: onShuffleFlashcardsChanged,
          ),
          const MxDivider(),
          MxToggle(
            label: l10n.studyShuffleAnswers,
            value: settings.shuffleAnswers,
            onChanged: onShuffleAnswersChanged,
          ),
          const MxDivider(),
          MxToggle(
            label: l10n.studyPrioritizeOverdue,
            value: settings.prioritizeOverdue,
            onChanged: onPrioritizeOverdueChanged,
          ),
        ],
      ),
    );
  }
}

class _BatchSizeRow extends StatelessWidget {
  const _BatchSizeRow({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.label,
    required this.rangeHelper,
    required this.onChanged,
  });

  final int value;
  final int minValue;
  final int maxValue;
  final String label;
  final String rangeHelper;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MxText(label, role: MxTextRole.listTitle),
                const MxGap(MxSpace.xxs),
                MxText(rangeHelper, role: MxTextRole.formHelper),
              ],
            ),
          ),
          const MxGap(MxSpace.md),
          _Stepper(
            value: value,
            onDecrement: value <= minValue ? null : () => onChanged(value - 1),
            onIncrement: value >= maxValue ? null : () => onChanged(value + 1),
            decrementTooltip: l10n.studyDecreaseBatch,
            incrementTooltip: l10n.studyIncreaseBatch,
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementTooltip,
    required this.incrementTooltip,
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementTooltip;
  final String incrementTooltip;

  @override
  Widget build(BuildContext context) {
    final valueLabel = value.toString();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxIconButton.compact(
          tooltip: decrementTooltip,
          icon: Icons.remove_rounded,
          onPressed: onDecrement,
        ),
        SizedBox(
          width: MxSpace.xxl + MxSpace.md,
          child: Center(
            child: MxText(valueLabel, role: MxTextRole.tileTitle),
          ),
        ),
        MxIconButton.compact(
          tooltip: incrementTooltip,
          icon: Icons.add_rounded,
          onPressed: onIncrement,
        ),
      ],
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
