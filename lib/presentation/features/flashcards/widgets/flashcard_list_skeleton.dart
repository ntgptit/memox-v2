import 'package:flutter/material.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';

const double _flashcardHeaderActionSize = 40;
const double _flashcardHeaderTitleHeight = 28;
const double _flashcardHeaderTitleWidth = 220;
const double _flashcardBreadcrumbHeight = 14;
const double _flashcardBreadcrumbWidth = 180;
const double _flashcardToolbarHeight = 48;
const double _flashcardSortChipHeight = 32;
const double _flashcardSortChipWidth = 120;
const double _flashcardActionHeight = 40;
const double _flashcardActionPrimaryWidth = 120;
const double _flashcardActionTertiaryWidth = 132;
const double _flashcardTermTitleHeight = 18;
const double _flashcardTermTitleWidth = 180;
const double _flashcardTermBodyHeight = 16;
const double _flashcardTermBodyWidth = 240;
const double _flashcardTermCaptionHeight = 14;
const double _flashcardTermCaptionWidth = 132;

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
            MxSkeleton(
              width: _flashcardHeaderActionSize,
              height: _flashcardHeaderActionSize,
              borderRadius: MxFeatureRadii.md,
            ),
            MxGap(MxSpace.sm),
            Expanded(
              child: MxSkeleton(
                height: _flashcardHeaderTitleHeight,
                width: _flashcardHeaderTitleWidth,
              ),
            ),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(
          height: _flashcardBreadcrumbHeight,
          width: _flashcardBreadcrumbWidth,
        ),
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
        MxSkeleton(
          height: _flashcardToolbarHeight,
          borderRadius: MxFeatureRadii.full,
        ),
        MxGap(MxSpace.sm),
        Wrap(
          spacing: MxSpace.sm,
          runSpacing: MxSpace.sm,
          children: [
            MxSkeleton(
              height: _flashcardSortChipHeight,
              width: _flashcardSortChipWidth,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: _flashcardActionHeight,
              width: _flashcardActionPrimaryWidth,
              borderRadius: MxFeatureRadii.full,
            ),
            MxSkeleton(
              height: _flashcardActionHeight,
              width: _flashcardActionTertiaryWidth,
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
          MxSkeleton(
            height: _flashcardTermTitleHeight,
            width: _flashcardTermTitleWidth,
          ),
          MxGap(MxSpace.xs),
          MxSkeleton(
            height: _flashcardTermBodyHeight,
            width: _flashcardTermBodyWidth,
          ),
          MxGap(MxSpace.sm),
          MxSkeleton(
            height: _flashcardTermCaptionHeight,
            width: _flashcardTermCaptionWidth,
          ),
        ],
      ),
    );
  }
}
