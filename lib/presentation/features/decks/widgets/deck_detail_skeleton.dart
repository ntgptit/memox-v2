import 'package:flutter/material.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';

const double _deckHeaderActionSize = 40;
const double _deckHeaderTitleHeight = 28;
const double _deckHeaderTitleWidth = 220;
const double _deckBreadcrumbHeight = 14;
const double _deckBreadcrumbWidth = 180;
const double _deckSectionTitleHeight = 18;
const double _deckSectionSubtitleHeight = 14;
const double _deckOverviewTitleWidth = 140;
const double _deckOverviewSubtitleWidth = 240;
const double _deckActionsTitleWidth = 180;
const double _deckActionsSubtitleWidth = 260;
const double _deckStudySetLeadingSize = 40;
const double _deckStudySetTitleWidth = 180;
const double _deckStudySetMetaWidth = 140;
const double _deckActionHeight = 40;
const double _deckActionPrimaryWidth = 132;
const double _deckActionSecondaryWidth = 136;
const double _deckActionTertiaryWidth = 128;

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
          titleWidth: _deckOverviewTitleWidth,
          subtitleWidth: _deckOverviewSubtitleWidth,
          body: _StudySetTileSkeleton(),
        ),
        MxGap(MxSpace.xl),
        _DeckSectionSkeleton(
          titleWidth: _deckActionsTitleWidth,
          subtitleWidth: _deckActionsSubtitleWidth,
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
            MxSkeleton(
              width: _deckHeaderActionSize,
              height: _deckHeaderActionSize,
              borderRadius: MxFeatureRadii.md,
            ),
            MxGap(MxSpace.sm),
            Expanded(
              child: MxSkeleton(
                height: _deckHeaderTitleHeight,
                width: _deckHeaderTitleWidth,
              ),
            ),
            MxGap(MxSpace.sm),
            MxSkeleton(
              width: _deckHeaderActionSize,
              height: _deckHeaderActionSize,
              borderRadius: MxFeatureRadii.md,
            ),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: _deckBreadcrumbHeight, width: _deckBreadcrumbWidth),
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
        MxSkeleton(height: _deckSectionTitleHeight, width: titleWidth),
        const MxGap(MxSpace.xs),
        MxSkeleton(height: _deckSectionSubtitleHeight, width: subtitleWidth),
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
          MxSkeleton(
            width: _deckStudySetLeadingSize,
            height: _deckStudySetLeadingSize,
            borderRadius: MxFeatureRadii.md,
          ),
          MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(
                  height: _deckSectionTitleHeight,
                  width: _deckStudySetTitleWidth,
                ),
                MxGap(MxSpace.xs),
                MxSkeleton(
                  height: _deckSectionSubtitleHeight,
                  width: _deckStudySetMetaWidth,
                ),
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
        MxSkeleton(
          height: _deckActionHeight,
          width: _deckActionPrimaryWidth,
          borderRadius: MxFeatureRadii.full,
        ),
        MxSkeleton(
          height: _deckActionHeight,
          width: _deckActionSecondaryWidth,
          borderRadius: MxFeatureRadii.full,
        ),
        MxSkeleton(
          height: _deckActionHeight,
          width: _deckActionTertiaryWidth,
          borderRadius: MxFeatureRadii.full,
        ),
      ],
    );
  }
}
