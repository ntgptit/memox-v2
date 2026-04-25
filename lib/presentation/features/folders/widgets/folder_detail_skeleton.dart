import 'package:flutter/material.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_divider.dart';

const double _folderHeaderActionSize = 40;
const double _folderHeaderTitleHeight = 28;
const double _folderHeaderTitleWidth = 220;
const double _folderBreadcrumbHeight = 14;
const double _folderBreadcrumbWidth = 180;
const double _folderToolbarHeight = 48;
const double _folderToolbarChipHeight = 32;
const double _folderToolbarChipWidth = 120;
const double _folderSectionTitleHeight = 18;
const double _folderSectionSubtitleHeight = 14;
const double _folderSummaryTitleWidth = 160;
const double _folderSummarySubtitleWidth = 220;
const double _folderTileLeadingSize = 48;
const double _folderTileTitleWidth = 180;
const double _folderTileMetaWidth = 120;

class FolderDetailSkeleton extends StatelessWidget {
  const FolderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('folder_detail_skeleton'),
      children: const [
        _FolderHeaderSkeleton(),
        MxGap(MxSpace.xl),
        _ToolbarSkeleton(),
        MxGap(MxSpace.xl),
        _SectionSkeleton(
          titleWidth: _folderSummaryTitleWidth,
          subtitleWidth: _folderSummarySubtitleWidth,
          bodyHeight: 0,
        ),
        MxGap(MxSpace.xl),
        _FolderTileSkeleton(),
        MxDivider(),
        _FolderTileSkeleton(),
        MxDivider(),
        _FolderTileSkeleton(),
      ],
    );
  }
}

class _FolderHeaderSkeleton extends StatelessWidget {
  const _FolderHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            MxSkeleton(
              width: _folderHeaderActionSize,
              height: _folderHeaderActionSize,
              borderRadius: MxFeatureRadii.md,
            ),
            MxGap(MxSpace.sm),
            Expanded(
              child: MxSkeleton(
                height: _folderHeaderTitleHeight,
                width: _folderHeaderTitleWidth,
              ),
            ),
            MxGap(MxSpace.sm),
            MxSkeleton(
              width: _folderHeaderActionSize,
              height: _folderHeaderActionSize,
              borderRadius: MxFeatureRadii.md,
            ),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(
          height: _folderBreadcrumbHeight,
          width: _folderBreadcrumbWidth,
        ),
      ],
    );
  }
}

class _ToolbarSkeleton extends StatelessWidget {
  const _ToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        MxSkeleton(
          height: _folderToolbarHeight,
          borderRadius: MxFeatureRadii.full,
        ),
        MxGap(MxSpace.sm),
        Row(
          children: [
            MxSkeleton(
              height: _folderToolbarChipHeight,
              width: _folderToolbarChipWidth,
              borderRadius: MxFeatureRadii.full,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({
    required this.titleWidth,
    required this.subtitleWidth,
    this.bodyHeight = 16,
  });

  final double titleWidth;
  final double subtitleWidth;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(height: _folderSectionTitleHeight, width: titleWidth),
        const MxGap(MxSpace.xs),
        MxSkeleton(height: _folderSectionSubtitleHeight, width: subtitleWidth),
        if (bodyHeight > 0) ...[
          const MxGap(MxSpace.md),
          MxSkeleton(height: bodyHeight),
        ],
      ],
    );
  }
}

class _FolderTileSkeleton extends StatelessWidget {
  const _FolderTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MxSpace.lg,
        vertical: MxSpace.md,
      ),
      child: Row(
        children: [
          MxSkeleton(
            width: _folderTileLeadingSize,
            height: _folderTileLeadingSize,
            borderRadius: MxFeatureRadii.md,
          ),
          MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(
                  height: _folderSectionTitleHeight,
                  width: _folderTileTitleWidth,
                ),
                MxGap(MxSpace.xs),
                MxSkeleton(
                  height: _folderSectionSubtitleHeight,
                  width: _folderTileMetaWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
