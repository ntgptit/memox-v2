import 'package:flutter/material.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_divider.dart';

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
        _SectionSkeleton(titleWidth: 160, subtitleWidth: 220, bodyHeight: 0),
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

class _ToolbarSkeleton extends StatelessWidget {
  const _ToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        MxSkeleton(height: 48, borderRadius: MxFeatureRadii.full),
        MxGap(MxSpace.sm),
        Row(
          children: [
            MxSkeleton(
              height: 32,
              width: 120,
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
        MxSkeleton(height: 18, width: titleWidth),
        const MxGap(MxSpace.xs),
        MxSkeleton(height: 14, width: subtitleWidth),
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
          MxSkeleton(width: 48, height: 48, borderRadius: MxFeatureRadii.md),
          MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxSkeleton(height: 18, width: 180),
                MxGap(MxSpace.xs),
                MxSkeleton(height: 14, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
