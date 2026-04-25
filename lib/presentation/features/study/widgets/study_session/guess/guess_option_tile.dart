import 'package:flutter/material.dart';

import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_shake_transition.dart';
import '../../../../../shared/widgets/mx_text.dart';
import 'guess_motion.dart';
import 'guess_option_models.dart';

const _guessOptionTextMaxLines = 2;

class GuessOptionTile extends StatefulWidget {
  const GuessOptionTile({
    required this.option,
    required this.state,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final StudyFlashcardRef option;
  final GuessOptionState state;
  final bool enabled;
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
      _shakeController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant GuessOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != GuessOptionState.error &&
        widget.state == GuessOptionState.error) {
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
        builder: (context, backgroundColor, child) {
          return MxCard(
            variant: MxCardVariant.outlined,
            backgroundColor: backgroundColor,
            borderColor: visual.borderColor,
            padding: const EdgeInsets.all(MxSpace.md),
            onTap: canTap ? widget.onTap : null,
            child: Center(
              child: MxText(
                widget.option.back,
                role: MxTextRole.contentBody,
                color: visual.foregroundColor,
                maxLines: _guessOptionTextMaxLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
