import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/library_overview_viewmodel.dart';

class LibraryHeroSection extends StatelessWidget {
  const LibraryHeroSection({required this.state, super.key});

  final LibraryOverviewState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(MxSpace.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: MxFeatureRadii.heroPanel,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(
            '${state.greeting.salutation}, ${state.greeting.userName}',
            role: MxTextRole.pageGreeting,
          ),
          const MxGap(MxSpace.xs),
          MxText(l10n.libraryTitle, role: MxTextRole.pageTitle),
          const MxGap(MxSpace.md),
          MxText(
            l10n.libraryHeroDueToday(state.dueToday),
            role: MxTextRole.heroAccent,
          ),
        ],
      ),
    );
  }
}
