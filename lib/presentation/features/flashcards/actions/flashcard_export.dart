import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/value_objects/content_actions.dart';
import '../../../shared/dialogs/mx_action_sheet_list.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';

/// Show a bottom sheet asking the user which file format to export to.
///
/// Returns the picked [ExportFormat], or `null` if the sheet was dismissed.
Future<ExportFormat?> pickFlashcardExportFormat(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return MxBottomSheet.show<ExportFormat>(
    context: context,
    title: l10n.exportFormatChoiceTitle,
    child: MxActionSheetList<ExportFormat>(
      items: [
        MxActionSheetItem(
          value: ExportFormat.csv,
          label: l10n.exportFormatCsvLabel,
          subtitle: l10n.exportFormatCsvDescription,
          icon: Icons.description_outlined,
        ),
        MxActionSheetItem(
          value: ExportFormat.excel,
          label: l10n.exportFormatExcelLabel,
          subtitle: l10n.exportFormatExcelDescription,
          icon: Icons.table_chart_outlined,
        ),
      ],
    ),
  );
}

/// Hand a prepared [ExportData] payload to the platform share sheet.
///
/// Centralised so both deck-level and selection-level exports use the same
/// share invocation (binary-safe via XFile.fromData).
Future<void> shareFlashcardExport(ExportData export) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(export.bytes, mimeType: export.mimeType)],
      fileNameOverrides: [export.fileName],
      subject: export.fileName,
    ),
  );
}
