import 'package:flutter/material.dart';

import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import 'match_mode_tile.dart';
import 'match_tile_models.dart';

class MatchBoard extends StatelessWidget {
  const MatchBoard({
    required this.leftItems,
    required this.rightItems,
    required this.isLocked,
    required this.tileStateFor,
    required this.onTileTap,
    super.key,
  });

  final List<StudySessionItem> leftItems;
  final List<StudySessionItem> rightItems;
  final bool isLocked;
  final MatchTileState Function(MatchTileSide side, StudySessionItem item)
  tileStateFor;
  final void Function(MatchTileSide side, StudySessionItem item) onTileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _MatchBoardColumn(
            side: MatchTileSide.left,
            items: leftItems,
            isLocked: isLocked,
            tileStateFor: tileStateFor,
            onTileTap: onTileTap,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: _MatchBoardColumn(
            side: MatchTileSide.right,
            items: rightItems,
            isLocked: isLocked,
            tileStateFor: tileStateFor,
            onTileTap: onTileTap,
          ),
        ),
      ],
    );
  }
}

class _MatchBoardColumn extends StatelessWidget {
  const _MatchBoardColumn({
    required this.side,
    required this.items,
    required this.isLocked,
    required this.tileStateFor,
    required this.onTileTap,
  });

  final MatchTileSide side;
  final List<StudySessionItem> items;
  final bool isLocked;
  final MatchTileState Function(MatchTileSide side, StudySessionItem item)
  tileStateFor;
  final void Function(MatchTileSide side, StudySessionItem item) onTileTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemExtent = constraints.maxHeight / items.length;
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemExtent: itemExtent,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : MxSpace.sm,
              ),
              child: MatchModeTile(
                key: ValueKey<String>('match-${side.name}-${item.id}'),
                side: side,
                item: item,
                state: tileStateFor(side, item),
                enabled: !isLocked,
                onTap: () => onTileTap(side, item),
              ),
            );
          },
        );
      },
    );
  }
}
