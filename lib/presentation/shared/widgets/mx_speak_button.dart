import 'package:flutter/material.dart';

import 'mx_icon_button.dart';

class MxSpeakButton extends StatefulWidget {
  const MxSpeakButton({
    required this.tooltip,
    required this.onPressed,
    this.isSpeaking = false,
    super.key,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final bool isSpeaking;

  @override
  State<MxSpeakButton> createState() => _MxSpeakButtonState();
}

class _MxSpeakButtonState extends State<MxSpeakButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.95,
    end: 1.08,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant MxSpeakButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSpeaking != widget.isSpeaking ||
        oldWidget.onPressed != widget.onPressed) {
      _syncPulse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconButton = MxIconButton(
      tooltip: widget.tooltip,
      icon: widget.isSpeaking
          ? Icons.volume_off_rounded
          : Icons.volume_up_rounded,
      onPressed: widget.onPressed,
    );

    if (!widget.isSpeaking || widget.onPressed == null) {
      return iconButton;
    }

    return AnimatedBuilder(
      animation: _scale,
      child: iconButton,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
    );
  }

  void _syncPulse() {
    if (widget.isSpeaking && widget.onPressed != null) {
      _controller.repeat(reverse: true);
      return;
    }
    _controller.stop();
    _controller.reset();
  }
}
