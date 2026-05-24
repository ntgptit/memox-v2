import 'dart:async';

import 'package:flutter/material.dart';

import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_shake_transition.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'guess_motion.dart';
import 'guess_option_models.dart';

const _guessOptionTextMaxLines = 2;
// guard:raw-size-reviewed letter-circle diameter per design mock (28 px)
const _guessLetterCircleDiameter = 28.0;
// guard:raw-size-reviewed letter-circle border thickness per design mock
const _guessLetterCircleBorderWidth = 1.5;

class GuessOptionTile extends StatefulWidget {
  const GuessOptionTile({
    required this.option,
    required this.state,
    required this.enabled,
    required this.letter,
    required this.onTap,
    super.key,
  });

  final StudyFlashcardRef option;
  final GuessOptionState state;
  final bool enabled;
  final String letter;
  final VoidCallback onTap;

  @override
  State<GuessOptionTile> createState() => _GuessOptionTileState();
}

class _GuessOptionTileState extends State<GuessOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: guessFeedbackDelay,
    );
    if (widget.state == GuessOptionState.error) {
      unawaited(_shakeController.forward(from: 0));
    }
  }

  @override
  void didUpdateWidget(covariant GuessOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != GuessOptionState.error &&
        widget.state == GuessOptionState.error) {
      unawaited(_shakeController.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visual = GuessOptionVisual.resolve(context, widget.state);
    final scheme = Theme.of(context).colorScheme;
    final idleBackground =
        Theme.of(context).cardTheme.color ?? scheme.surfaceContainerLow;
    final targetBackground = visual.backgroundColor ?? idleBackground;
    final canTap = widget.enabled && widget.state == GuessOptionState.idle;

    return MxShakeTransition(
      animation: _shakeController,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: targetBackground),
        duration: guessColorTransitionDuration,
        curve: Curves.easeOutCubic,
        builder: (context, backgroundColor, child) => MxCard(
            variant: MxCardVariant.outlined,
            backgroundColor: backgroundColor,
            borderColor: visual.borderColor,
            padding: const EdgeInsets.symmetric(
              horizontal: MxSpace.md,
              vertical: MxSpace.md,
            ),
            onTap: canTap ? widget.onTap : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _GuessLetterCircle(
                  letter: widget.letter,
                  color: visual.foregroundColor,
                ),
                const MxGap(MxSpace.md),
                Expanded(
                  child: MxText(
                    widget.option.back,
                    role: MxTextRole.contentBody,
                    color: visual.foregroundColor,
                    maxLines: _guessOptionTextMaxLines,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                if (widget.state == GuessOptionState.success) ...[
                  const MxGap(MxSpace.sm),
                  Icon(
                    Icons.check_rounded,
                    color: visual.foregroundColor,
                  ),
                ],
                if (widget.state == GuessOptionState.error) ...[
                  const MxGap(MxSpace.sm),
                  Icon(
                    Icons.close_rounded,
                    color: visual.foregroundColor,
                  ),
                ],
              ],
            ),
          ),
      ),
    );
  }
}

class _GuessLetterCircle extends StatelessWidget {
  const _GuessLetterCircle({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      width: _guessLetterCircleDiameter,
      height: _guessLetterCircleDiameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: _guessLetterCircleBorderWidth,
        ),
      ),
      child: MxText(letter, role: MxTextRole.badge, color: color),
    );
}
