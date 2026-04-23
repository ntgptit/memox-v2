import 'package:flutter/material.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';

class FlashcardListSkeleton extends StatelessWidget {
  const FlashcardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('flashcard_list_skeleton'),
      children: const [
        _FlashcardHeaderSkeleton(),
        MxGap(MxSpace.xl),
        _FlashcardToolbarSkeleton(),
        MxGap(MxSpace.xl),
        _TermRowSkeleton(),
        MxGap(MxSpace.sm),
        _TermRowSkeleton(),
        MxGap(MxSpace.sm),
        _TermRowSkeleton(),
      ],
    );
  }
}

class _FlashcardHeaderSkeleton extends StatelessWidget {
  const _FlashcardHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
            MxGap(MxSpace.sm),
            Expanded(child: MxSkeleton(height: 28, width: 220)),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: 14, width: 180),
      ],
    );
  }
}

class _FlashcardToolbarSkeleton extends StatelessWidget {
  const _FlashcardToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        MxSkeleton(height: 48, borderRadius: MxFeatureRadii.full),
        MxGap(MxSpace.sm),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          children: [
            MxSkeleton(
              height: 32,
              width: 120,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: 40,
              width: 120,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: 40,
              width: 132,
              borderRadius: MxFeatureRadii.full,
            ),
          ],
        ),
      ],
    );
  }
}

class _TermRowSkeleton extends StatelessWidget {
  const _TermRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(MxSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(height: 18, width: 180),
          MxGap(MxSpace.xs),
          MxSkeleton(height: 16, width: 240),
          MxGap(MxSpace.sm),
          MxSkeleton(height: 14, width: 132),
        ],
      ),
    );
  }
}
