import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/library_overview_viewmodel.dart';

class LibraryHeroSection extends StatelessWidget {
  const LibraryHeroSection({required this.state, super.key});

  final LibraryOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!context.showsSupportingCopy) {
      return MxText(l10n.libraryTitle, role: MxTextRole.pageTitle);
    }

    return Padding(
      padding: AppLayout.heroPadding(
        context,
      ).resolve(Directionality.of(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(
            '${state.greeting.salutation}, ${state.greeting.userName}',
            role: MxTextRole.pageGreeting,
          ),
          const MxGap(MxSpace.xs),
          MxText(l10n.libraryTitle, role: MxTextRole.pageTitle),
          const MxGap(MxSpace.sm),
          MxText(
            l10n.libraryHeroDueToday(state.dueToday),
            role: MxTextRole.heroAccent,
          ),
        ],
      ),
    );
  }
}
