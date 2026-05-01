import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/study_settings_policy.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_toggle.dart';
import '../../study/providers/study_settings_defaults_notifier.dart';
import 'settings_group.dart';

const _newStudyBatchIncreaseKey = ValueKey<String>(
  'settings-study-new-batch-increase',
);
const _newStudyBatchDecreaseKey = ValueKey<String>(
  'settings-study-new-batch-decrease',
);
const _reviewBatchIncreaseKey = ValueKey<String>(
  'settings-study-review-batch-increase',
);
const _reviewBatchDecreaseKey = ValueKey<String>(
  'settings-study-review-batch-decrease',
);

class StudySettingsGroup extends ConsumerWidget {
  const StudySettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(studyDefaultsSettingsProvider);

    return MxRetainedAsyncState<StudyDefaultsSettingsState>(
      data: settings.value,
      isLoading: settings.isLoading,
      error: settings.hasError ? settings.error : null,
      stackTrace: settings.hasError ? settings.stackTrace : null,
      onRetry: () => ref.invalidate(studyDefaultsSettingsProvider),
      skeletonBuilder: (_) => SettingsGroup(
        title: l10n.settingsStudyDefaultsTitle,
        subtitle: l10n.settingsStudyDefaultsLoading,
        child: const MxLoadingState(),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsStudyDefaultsTitle,
        subtitle: l10n.sharedErrorTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      dataBuilder: (_, state) => _StudySettingsContent(state: state),
    );
  }
}

class _StudySettingsContent extends ConsumerWidget {
  const _StudySettingsContent({required this.state});

  final StudyDefaultsSettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(studyDefaultsSettingsProvider.notifier);

    return SettingsGroup(
      title: l10n.settingsStudyDefaultsTitle,
      subtitle: l10n.settingsStudyDefaultsSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BatchSizeStepper(
            label: l10n.settingsNewStudyBatchSizeLabel,
            value: state.newStudyDefaults.batchSize,
            studyType: StudyType.newStudy,
            increaseKey: _newStudyBatchIncreaseKey,
            decreaseKey: _newStudyBatchDecreaseKey,
            onChanged: (value) =>
                _persist(context, notifier.setNewStudyBatchSize(value), l10n),
          ),
          const MxGap(MxSpace.md),
          const MxDivider(),
          const MxGap(MxSpace.md),
          _BatchSizeStepper(
            label: l10n.settingsReviewBatchSizeLabel,
            value: state.reviewDefaults.batchSize,
            studyType: StudyType.srsReview,
            increaseKey: _reviewBatchIncreaseKey,
            decreaseKey: _reviewBatchDecreaseKey,
            onChanged: (value) =>
                _persist(context, notifier.setReviewBatchSize(value), l10n),
          ),
          const MxGap(MxSpace.md),
          const MxDivider(),
          const MxGap(MxSpace.sm),
          MxToggle(
            value: state.shuffleFlashcards,
            onChanged: (value) =>
                _persist(context, notifier.setShuffleFlashcards(value), l10n),
            label: l10n.studyShuffleCards,
          ),
          MxToggle(
            value: state.shuffleAnswers,
            onChanged: (value) =>
                _persist(context, notifier.setShuffleAnswers(value), l10n),
            label: l10n.studyShuffleAnswers,
          ),
          MxToggle(
            value: state.prioritizeOverdue,
            onChanged: (value) =>
                _persist(context, notifier.setPrioritizeOverdue(value), l10n),
            label: l10n.studyPrioritizeOverdue,
          ),
        ],
      ),
    );
  }

  void _persist(
    BuildContext context,
    Future<void> action,
    AppLocalizations l10n,
  ) {
    unawaited(
      action
          .then((_) {
            if (context.mounted) {
              MxSnackbar.success(context, l10n.settingsUpdatedMessage);
            }
          })
          .catchError((Object _) {
            if (context.mounted) {
              MxSnackbar.error(context, l10n.errorUnexpected);
            }
          }),
    );
  }
}

class _BatchSizeStepper extends StatelessWidget {
  const _BatchSizeStepper({
    required this.label,
    required this.value,
    required this.studyType,
    required this.increaseKey,
    required this.decreaseKey,
    required this.onChanged,
  });

  final String label;
  final int value;
  final StudyType studyType;
  final Key increaseKey;
  final Key decreaseKey;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final min = StudySettingsPolicy.minBatchSize(studyType);
    final max = StudySettingsPolicy.maxBatchSize(studyType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: MxText(label, role: MxTextRole.formLabel)),
            MxText(value.toString(), role: MxTextRole.tileMeta),
            const MxGap(MxSpace.sm),
            MxIconButton(
              key: decreaseKey,
              tooltip: l10n.studyDecreaseBatch,
              onPressed: value <= min ? null : () => onChanged(value - 1),
              icon: Icons.remove_rounded,
            ),
            MxIconButton(
              key: increaseKey,
              tooltip: l10n.studyIncreaseBatch,
              onPressed: value >= max ? null : () => onChanged(value + 1),
              icon: Icons.add_rounded,
            ),
          ],
        ),
        MxText(
          l10n.studyBatchSizeRangeLabel(min, max),
          role: MxTextRole.formHelper,
        ),
      ],
    );
  }
}
