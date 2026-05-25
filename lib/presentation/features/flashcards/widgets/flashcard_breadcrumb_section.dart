import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/value_objects/content_read_models.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';

/// Standalone breadcrumb row above the Deck Detail content per Design System
/// "03 · Deck detail" — sits between the AppBar and the mastery hero, not
/// nested inside the summary card.
///
/// Always prepends a synthetic "Library" root segment so the path reads as
/// `Library › Folder › Deck` per Design System examples, even when the
/// underlying read model only carries folder-level segments.
class FlashcardBreadcrumbSection extends StatelessWidget {
  const FlashcardBreadcrumbSection({
    required this.breadcrumb,
    required this.onOpenBreadcrumb,
    required this.onOpenLibrary,
    super.key,
  });

  final List<BreadcrumbSegmentReadModel> breadcrumb;
  final ValueChanged<String> onOpenBreadcrumb;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    if (breadcrumb.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return MxBreadcrumbBar(
      items: [
        MxBreadcrumb(label: l10n.libraryTitle, onTap: onOpenLibrary),
        for (var index = 0; index < breadcrumb.length; index++)
          MxBreadcrumb(
            label: breadcrumb[index].label,
            onTap:
                index == breadcrumb.length - 1 ||
                    breadcrumb[index].folderId == null
                ? null
                : () => onOpenBreadcrumb(breadcrumb[index].folderId!),
          ),
      ],
    );
  }
}
