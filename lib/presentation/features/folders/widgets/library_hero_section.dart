import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/library_overview_viewmodel.dart';

/// Library top row per Design System "02 · Library": a single bold title.
///
/// The previous greeting + "due today" hero block belongs to the Home screen
/// pattern, not the Library pattern. Keeping this widget so its sliver slot
/// in `library_overview_screen.dart` stays stable.
class LibraryHeroSection extends StatelessWidget {
  const LibraryHeroSection({required this.state, super.key});

  // ignore: unused_element
  final LibraryOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxText(l10n.libraryTitle, role: MxTextRole.pageTitle);
  }
}
