import 'package:flutter/material.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';

class DeckDetailSkeleton extends StatelessWidget {
  const DeckDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('deck_detail_skeleton'),
      children: const [
        _DeckHeaderSkeleton(),
        MxGap(MxSpace.xl),
        _DeckSectionSkeleton(
          titleWidth: 140,
          subtitleWidth: 240,
          body: _StudySetTileSkeleton(),
        ),
        MxGap(MxSpace.xl),
        _DeckSectionSkeleton(
          titleWidth: 180,
          subtitleWidth: 260,
          body: _DeckActionSkeleton(),
        ),
      ],
    );
  }
}

class _DeckHeaderSkeleton extends StatelessWidget {
  const _DeckHeaderSkeleton();

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
            MxGap(MxSpace.sm),
            MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: 14, width: 180),
      ],
    );
  }
}

class _DeckSectionSkeleton extends StatelessWidget {
  const _DeckSectionSkeleton({
    required this.titleWidth,
    required this.subtitleWidth,
    required this.body,
  });

  final double titleWidth;
  final double subtitleWidth;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(height: 18, width: titleWidth),
        const MxGap(MxSpace.xs),
        MxSkeleton(height: 14, width: subtitleWidth),
        const MxGap(MxSpace.md),
        body,
      ],
    );
  }
}

class _StudySetTileSkeleton extends StatelessWidget {
  const _StudySetTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxSkeleton(width: 40, height: 40, borderRadius: MxFeatureRadii.md),
          MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(height: 18, width: 180),
                MxGap(MxSpace.xs),
                MxSkeleton(height: 14, width: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckActionSkeleton extends StatelessWidget {
  const _DeckActionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: MxSpace.sm,
      runSpacing: MxSpace.sm,
      children: [
        MxSkeleton(height: 40, width: 132, borderRadius: MxFeatureRadii.full),
        MxSkeleton(height: 40, width: 136, borderRadius: MxFeatureRadii.full),
        MxSkeleton(height: 40, width: 128, borderRadius: MxFeatureRadii.full),
      ],
    );
  }
}
