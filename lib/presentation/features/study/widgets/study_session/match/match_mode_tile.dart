import 'package:flutter/material.dart';

import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_shake_transition.dart';
import '../../../../../shared/widgets/mx_text.dart';
import 'match_motion.dart';
import 'match_tile_models.dart';

class MatchModeTile extends StatefulWidget {
  const MatchModeTile({
    required this.side,
    required this.item,
    required this.state,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final MatchTileSide side;
  final StudySessionItem item;
  final MatchTileState state;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<MatchModeTile> createState() => _MatchModeTileState();
}

class _MatchModeTileState extends State<MatchModeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: matchResolveDelay,
    );
    if (widget.state == MatchTileState.error) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant MatchModeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != MatchTileState.error &&
        widget.state == MatchTileState.error) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = MatchTileVisual.resolve(context, widget.state, widget.side);
    final isMatched = widget.state == MatchTileState.matched;
    final isResolved =
        widget.state == MatchTileState.success ||
        widget.state == MatchTileState.matched;
    final canTap = widget.enabled && !isResolved;
    final isTerm = widget.side == MatchTileSide.left;
    final text = isTerm
        ? widget.item.flashcard.front
        : widget.item.flashcard.back;

    return MxShakeTransition(
      animation: _shakeController,
      child: AnimatedOpacity(
        opacity: isMatched ? 0 : 1,
        duration: matchFadeDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: isMatched ? 0.8 : 1,
          duration: matchFadeDuration,
          curve: Curves.easeOutCubic,
          child: IgnorePointer(
            ignoring: isMatched,
            child: MxCard(
              variant: MxCardVariant.outlined,
              backgroundColor: visual.backgroundColor,
              borderColor: visual.borderColor,
              padding: const EdgeInsets.all(MxSpace.md),
              onTap: canTap ? widget.onTap : null,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: MxText(
                        text,
                        role: isTerm
                            ? MxTextRole.tileTitle
                            : MxTextRole.contentBody,
                        color: visual.foregroundColor,
                        maxLines: isTerm ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
