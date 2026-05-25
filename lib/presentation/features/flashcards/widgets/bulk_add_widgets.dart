import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/extensions/theme_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/feedback/mx_banner.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../viewmodels/flashcard_import_viewmodel.dart';
import 'bulk_add_controls.dart';

class BulkAddBreadcrumb extends StatelessWidget {
  const BulkAddBreadcrumb({
    required this.breadcrumb,
    required this.deckName,
    required this.onOpenLibrary,
    required this.onOpenFolder,
    required this.onOpenDeck,
    super.key,
  });

  final List<BreadcrumbSegmentReadModel> breadcrumb;
  final String deckName;
  final VoidCallback onOpenLibrary;
  final ValueChanged<String> onOpenFolder;
  final VoidCallback onOpenDeck;

  @override
  Widget build(BuildContext context) {
    if (deckName.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final items = <MxBreadcrumb>[
      MxBreadcrumb(label: l10n.libraryTitle, onTap: onOpenLibrary),
      for (var i = 0; i < breadcrumb.length - 1; i++)
        MxBreadcrumb(
          label: breadcrumb[i].label,
          onTap: breadcrumb[i].folderId == null
              ? null
              : () => onOpenFolder(breadcrumb[i].folderId!),
        ),
      MxBreadcrumb(label: deckName, onTap: onOpenDeck),
      MxBreadcrumb(label: l10n.bulkAddBreadcrumbLeaf),
    ];
    return MxBreadcrumbBar(items: items);
  }
}

// guard:raw-size-reviewed paste textarea inner height — ~10 mono lines per
// Design mock 05d, balances breathing room above format helper.
const double _bulkAddPasteHeight = 320;

class BulkAddPasteSection extends StatelessWidget {
  const BulkAddPasteSection({
    required this.controller,
    required this.hint,
    required this.helper,
    required this.separator,
    required this.enabled,
    required this.separatorLabels,
    required this.onChanged,
    required this.onSeparatorChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final String helper;
  final ImportStructuredTextSeparator separator;
  final bool enabled;
  final Map<ImportStructuredTextSeparator, String> separatorLabels;
  final ValueChanged<String> onChanged;
  final ValueChanged<ImportStructuredTextSeparator> onSeparatorChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: _bulkAddPasteHeight,
            child: MxTextField(
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
              expands: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.none,
              variant: MxTextFieldVariant.borderless,
              textRole: MxTextRole.monoBody,
              textAlignVertical: TextAlignVertical.top,
              hintText: hint,
            ),
          ),
        ),
        const MxGap(MxSpace.md),
        BulkAddInfoBanner(message: helper),
        const MxGap(MxSpace.md),
        MxText(l10n.bulkAddSeparatorLabel, role: MxTextRole.overline),
        const MxGap(MxSpace.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in separatorLabels.entries)
              BulkAddSeparatorPill(
                label: entry.value,
                selected: separator == entry.key,
                onTap: enabled ? () => onSeparatorChanged(entry.key) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class BulkAddPreviewSection extends StatelessWidget {
  const BulkAddPreviewSection({
    required this.draft,
    required this.actionState,
    super.key,
  });

  final FlashcardImportDraftState draft;
  final AsyncValue<void> actionState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preparation = draft.preparation;

    if (actionState.isLoading && preparation == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: MxCircularProgress(size: MxProgressSize.large),
        ),
      );
    }

    if (StringUtils.isBlank(draft.rawContent)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: MxText(l10n.bulkAddEmptyPaste, role: MxTextRole.formHelper),
      );
    }

    if (preparation == null) {
      return const SizedBox.shrink();
    }

    return _PreparedPreview(preparation: preparation);
  }
}

class _PreparedPreview extends StatelessWidget {
  const _PreparedPreview({required this.preparation});

  final FlashcardImportPreparation preparation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardsCount = preparation.previewItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: MxText(
                l10n.bulkAddCardsReady(cardsCount),
                role: MxTextRole.sectionTitle,
              ),
            ),
            _statusBadgeFor(context, preparation),
          ],
        ),
        const MxGap(MxSpace.md),
        if (preparation.hasIssues) ...[
          MxBanner(
            tone: MxBannerTone.warning,
            message: preparation.issues
                .take(3)
                .map((i) => '• ${i.lineNumber}: ${i.message}')
                .join('\n'),
          ),
          const MxGap(MxSpace.md),
        ],
        MxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < preparation.previewItems.length; i++) ...[
                if (i > 0) const MxDivider(),
                _PreviewRow(
                  index: i + 1,
                  front: preparation.previewItems[i].draft.front,
                  back: preparation.previewItems[i].draft.back,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadgeFor(
    BuildContext context,
    FlashcardImportPreparation preparation,
  ) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mx = context.mxColors;
    if (preparation.hasIssues) {
      return _StatusBadge(
        icon: Icons.error_outline,
        label: l10n.bulkAddIssuesCount(preparation.issues.length),
        color: scheme.error,
      );
    }
    final dupCount = preparation.skippedDuplicateCount;
    if (dupCount > 0) {
      return _StatusBadge(
        icon: Icons.info_outline,
        label: l10n.bulkAddDuplicatesSkipped(dupCount),
        color: mx.info,
      );
    }
    return _StatusBadge(
      icon: Icons.check_rounded,
      label: l10n.bulkAddNoDuplicates,
      color: mx.success,
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.index,
    required this.front,
    required this.back,
  });

  final int index;
  final String front;
  final String back;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppIconSizes.lg,
            child: Text(
              '$index',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: Text(
              front,
              style: textTheme.titleSmall?.copyWith(color: scheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const MxGap(MxSpace.md),
          Expanded(
            child: Text(
              back,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSizes.sm, color: color),
        const MxGap(MxSpace.xs),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class BulkAddFooter extends StatelessWidget {
  const BulkAddFooter({
    required this.count,
    required this.deckName,
    required this.isBusy,
    required this.canCommit,
    required this.onCommit,
    super.key,
  });

  final int count;
  final String deckName;
  final bool isBusy;
  final bool canCommit;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _summary(l10n)),
        const MxGap(MxSpace.md),
        MxPrimaryButton(
          label: l10n.bulkAddCommit(count),
          size: MxButtonSize.compact,
          shape: MxPrimaryButtonShape.pill,
          onPressed: canCommit ? onCommit : null,
          isLoading: isBusy,
        ),
      ],
    );
  }

  Widget _summary(AppLocalizations l10n) {
    if (deckName.isEmpty) {
      return const SizedBox.shrink();
    }
    return MxText(
      l10n.bulkAddFooterSummary(count, deckName),
      role: MxTextRole.tileMeta,
    );
  }
}
