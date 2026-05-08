import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/study_settings_policy.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_inline_toggle.dart';
import '../../../shared/widgets/mx_list_tile.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/study_settings_defaults_viewmodel.dart';
import 'settings_group.dart';

const _newStudyBatchRowKey = ValueKey<String>('settings-study-new-batch-row');
const _reviewBatchRowKey = ValueKey<String>('settings-study-review-batch-row');
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
        title: l10n.settingsLearningExperienceTitle,
        subtitle: l10n.settingsStudyDefaultsLoading,
        child: const MxLoadingState(),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsLearningExperienceTitle,
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
      title: l10n.settingsLearningExperienceTitle,
      child: Column(
        children: [
          _StudySettingRow(
            key: _newStudyBatchRowKey,
            icon: Icons.edit_calendar_outlined,
            title: l10n.settingsNewStudyBatchSizeLabel,
            value: l10n.settingsCardsCountValue(
              state.newStudyDefaults.batchSize,
            ),
            onTap: () => _showBatchSizeSheet(context, StudyType.newStudy),
          ),
          const MxDivider(),
          _StudySettingRow(
            key: _reviewBatchRowKey,
            icon: Icons.history_rounded,
            title: l10n.settingsReviewBatchSizeLabel,
            value: l10n.settingsCardsCountValue(state.reviewDefaults.batchSize),
            onTap: () => _showBatchSizeSheet(context, StudyType.srsReview),
          ),
          const MxDivider(),
          MxInlineToggle(
            value: state.shuffleFlashcards,
            onChanged: (value) => _persistSetting(
              context,
              notifier.setShuffleFlashcards(value),
              l10n,
            ),
            label: l10n.studyShuffleCards,
          ),
          const MxGap(MxSpace.sm),
          MxInlineToggle(
            value: state.shuffleAnswers,
            onChanged: (value) => _persistSetting(
              context,
              notifier.setShuffleAnswers(value),
              l10n,
            ),
            label: l10n.studyShuffleAnswers,
          ),
          const MxGap(MxSpace.sm),
          MxInlineToggle(
            value: state.prioritizeOverdue,
            onChanged: (value) => _persistSetting(
              context,
              notifier.setPrioritizeOverdue(value),
              l10n,
            ),
            label: l10n.studyPrioritizeOverdue,
          ),
        ],
      ),
    );
  }

  void _showBatchSizeSheet(BuildContext context, StudyType studyType) {
    final l10n = AppLocalizations.of(context);
    final title = switch (studyType) {
      StudyType.newStudy => l10n.settingsNewStudyBatchSizeLabel,
      StudyType.srsReview => l10n.settingsReviewBatchSizeLabel,
    };

    unawaited(
      MxBottomSheet.show<void>(
        context: context,
        title: title,
        child: _BatchSizeSheet(studyType: studyType),
      ),
    );
  }
}

class _StudySettingRow extends StatelessWidget {
  const _StudySettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxListTile(
      leading: Icon(icon, color: scheme.onSurfaceVariant, size: MxSpace.xxl),
      title: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxText(
            value,
            role: MxTextRole.tileMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const MxGap(MxSpace.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: MxSpace.xxl,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _BatchSizeSheet extends ConsumerWidget {
  const _BatchSizeSheet({required this.studyType});

  final StudyType studyType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(studyDefaultsSettingsProvider);
    final state = settings.value;
    if (settings.hasError) {
      return MxText(l10n.errorUnexpected, role: MxTextRole.formHelper);
    }
    if (state == null) {
      return const MxLoadingState();
    }

    final notifier = ref.read(studyDefaultsSettingsProvider.notifier);
    final batch = switch (studyType) {
      StudyType.newStudy => state.newStudyDefaults.batchSize,
      StudyType.srsReview => state.reviewDefaults.batchSize,
    };
    final label = switch (studyType) {
      StudyType.newStudy => l10n.settingsNewStudyBatchSizeLabel,
      StudyType.srsReview => l10n.settingsReviewBatchSizeLabel,
    };
    final increaseKey = switch (studyType) {
      StudyType.newStudy => _newStudyBatchIncreaseKey,
      StudyType.srsReview => _reviewBatchIncreaseKey,
    };
    final decreaseKey = switch (studyType) {
      StudyType.newStudy => _newStudyBatchDecreaseKey,
      StudyType.srsReview => _reviewBatchDecreaseKey,
    };

    return _BatchSizeStepper(
      label: label,
      value: batch,
      studyType: studyType,
      increaseKey: increaseKey,
      decreaseKey: decreaseKey,
      onChanged: (value) {
        final action = switch (studyType) {
          StudyType.newStudy => notifier.setNewStudyBatchSize(value),
          StudyType.srsReview => notifier.setReviewBatchSize(value),
        };
        _persistSetting(context, action, l10n);
      },
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

void _persistSetting(
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
