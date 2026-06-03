import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/app_radius.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_loading_state.dart';

// guard:raw-size-reviewed Skeleton placeholder dimensions mirror the populated
// Library Overview layout (page title, search affordance, folder rows) so the
// loading→loaded transition does not shift the chrome. Per Design System
// "03 · Library overview" loading state (skeleton folder rows, not a spinner).
const double _titleHeight = 28;
const double _titleWidth = 160;
const double _searchFieldHeight = 44;
const double _sectionHeaderHeight = 16;
const double _sectionHeaderWidth = 96;
const double _rowLeadingSize = 44;
const double _rowTitleHeight = 14;
const double _rowMetaHeight = 11;
const double _rowMasteryHeight = 5;
const double _rowTitleWidth = 140;
const double _rowMetaWidth = 180;
const int _rowCount = 4;

/// Loading placeholder for [LibraryOverviewView].
///
/// Renders skeleton folder rows (not a full-screen spinner) so the screen
/// stays calm and structurally stable while the first query resolves. None of
/// the placeholders are interactive.
class LibrarySkeleton extends StatelessWidget {
  const LibrarySkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey('library_skeleton'),
    padding: EdgeInsets.zero,
    children: const [
      _LibraryHeaderSkeleton(),
      MxGap(MxSpace.md),
      MxSkeleton(
        height: _searchFieldHeight,
        borderRadius: MxFeatureRadii.md,
      ),
      MxGap(MxSpace.lg),
      MxSkeleton(height: _sectionHeaderHeight, width: _sectionHeaderWidth),
      MxGap(MxSpace.md),
      _LibraryRowSkeleton(),
      MxGap(MxSpace.sm),
      _LibraryRowSkeleton(),
      MxGap(MxSpace.sm),
      _LibraryRowSkeleton(),
      MxGap(MxSpace.sm),
      _LibraryRowSkeleton(),
    ],
  );

  /// Number of skeleton rows rendered. Exposed for tests.
  static int get rowCount => _rowCount;
}

class _LibraryHeaderSkeleton extends StatelessWidget {
  const _LibraryHeaderSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: MxSkeleton(height: _titleHeight, width: _titleWidth),
      ),
      MxGap(MxSpace.sm),
      MxSkeleton(
        width: _rowLeadingSize,
        height: _rowLeadingSize,
        borderRadius: MxFeatureRadii.full,
      ),
    ],
  );
}

class _LibraryRowSkeleton extends StatelessWidget {
  const _LibraryRowSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(MxSpace.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: AppRadius.card,
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(
          width: _rowLeadingSize,
          height: _rowLeadingSize,
          borderRadius: MxFeatureRadii.md,
        ),
        MxGap(MxSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxSkeleton(height: _rowTitleHeight, width: _rowTitleWidth),
              MxGap(MxSpace.xs),
              MxSkeleton(height: _rowMetaHeight, width: _rowMetaWidth),
              MxGap(MxSpace.sm),
              MxSkeleton(
                height: _rowMasteryHeight,
                borderRadius: MxFeatureRadii.full,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
