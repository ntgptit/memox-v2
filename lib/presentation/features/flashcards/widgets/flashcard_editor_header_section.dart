import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';

/// Top header for the create/edit card screen.
///
/// Per Design System "05 · Create card": close (×) on the left, centered
/// title, and an optional quick-action icon on the right ("Save & add
/// another"). Title weight stays at `sheetTitle` so the page reads as a
/// focused author surface, not a high-level page.
class FlashcardEditorHeaderSection extends StatelessWidget {
  const FlashcardEditorHeaderSection({
    required this.title,
    required this.onBack,
    this.onQuickSave,
    this.quickSaveTooltip,
    super.key,
  });

  final String title;
  final VoidCallback onBack;

  /// When non-null, renders the trailing quick-save icon. Pass null to hide
  /// it (edit mode or empty draft).
  final VoidCallback? onQuickSave;
  final String? quickSaveTooltip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        MxIconButton.toolbar(
          icon: Icons.close_rounded,
          tooltip: l10n.commonClose,
          onPressed: onBack,
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: Center(
            child: MxText(
              title,
              role: MxTextRole.sheetTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const MxGap(MxSpace.sm),
        MxIconButton.toolbar(
          icon: Icons.subdirectory_arrow_left_rounded,
          tooltip: quickSaveTooltip,
          onPressed: onQuickSave,
        ),
      ],
    );
  }
}
