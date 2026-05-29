import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import 'mx_action_sheet_list.dart';
import 'mx_bottom_sheet.dart';

/// V1 card-action choices. `History` is intentionally absent — Flashcard
/// History is Future Proposal per `docs/checklist/v1-implementation-scope-2026-05-29.md`.
enum MxCardAction { edit, bury, suspend }

/// Shared card-actions bottom sheet body offering the V1 actions
/// Edit / Bury / Suspend. Spec: `docs/wireframes/25-shared-bottom-sheets.md`
/// §card-context, `docs/business/study-actions/bury-suspend.md`.
class MxCardActionsSheet extends StatelessWidget {
  const MxCardActionsSheet({this.onSelected, super.key});

  final ValueChanged<MxCardAction>? onSelected;

  /// Presents the sheet and resolves to the chosen [MxCardAction], or null when
  /// dismissed.
  static Future<MxCardAction?> show({required BuildContext context}) {
    final l10n = AppLocalizations.of(context);
    return MxBottomSheet.show<MxCardAction>(
      context: context,
      title: l10n.cardActionsTitle,
      child: const MxCardActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxActionSheetList<MxCardAction>(
      onSelected: onSelected,
      items: <MxActionSheetItem<MxCardAction>>[
        MxActionSheetItem<MxCardAction>(
          value: MxCardAction.edit,
          label: l10n.commonEdit,
          icon: Icons.edit_outlined,
        ),
        MxActionSheetItem<MxCardAction>(
          value: MxCardAction.bury,
          label: l10n.cardActionBury,
          icon: Icons.bedtime_outlined,
        ),
        MxActionSheetItem<MxCardAction>(
          value: MxCardAction.suspend,
          label: l10n.cardActionSuspend,
          icon: Icons.pause_circle_outline,
        ),
      ],
    );
  }
}
