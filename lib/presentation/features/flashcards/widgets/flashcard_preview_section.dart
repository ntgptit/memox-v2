import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/motion/mx_motion.dart';
import '../../../shared/widgets/mx_flashcard.dart';
import '../../../shared/widgets/mx_page_dots.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardPreviewSection extends StatefulWidget {
  const FlashcardPreviewSection({required this.items, super.key});

  final List<FlashcardListItemState> items;

  @override
  State<FlashcardPreviewSection> createState() =>
      _FlashcardPreviewSectionState();
}

class _FlashcardPreviewSectionState extends State<FlashcardPreviewSection> {
  // guard:raw-size-reviewed wide card ratio follows the deck-detail preview.
  static const double _previewAspectRatio = 2.08;
  static const double _fullscreenAspectRatio = 0.75;
  static const double _previewViewportFraction = 0.94;

  late final PageController _controller = PageController(
    viewportFraction: _previewViewportFraction,
  );
  var _activeIndex = 0;
  var _showBack = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.maxWidth / _previewAspectRatio,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _activeIndex = index;
                  _showBack = false;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return AnimatedSwitcher(
                  duration: MxDurations.quickTransition,
                  child: _PreviewFlashcard(
                    key: ValueKey('${item.id}:$_showBack'),
                    item: item,
                    showBack: _showBack,
                    aspectRatio: _previewAspectRatio,
                    onTap: _toggleFace,
                    onFullscreen: () =>
                        _showFullscreen(context, item, _showBack),
                  ),
                );
              },
            ),
          ),
        ),
        const MxGap(MxSpace.sm),
        MxPageDots(
          count: widget.items.length,
          activeIndex: _activeIndex,
          onDotTap: (index) {
            unawaited(
              _controller.animateToPage(
                index,
                duration: MxDurations.quickTransition,
                curve: Curves.easeOut,
              ),
            );
          },
        ),
      ],
    );
  }

  void _toggleFace() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  Future<void> _showFullscreen(
    BuildContext context,
    FlashcardListItemState item,
    bool initialShowBack,
  ) {
    final l10n = AppLocalizations.of(context);
    var showBack = initialShowBack;
    return MxDialog.show<void>(
      context: context,
      title: l10n.flashcardsPreviewDialogTitle,
      child: StatefulBuilder(
        builder: (context, setDialogState) => _PreviewFlashcard(
          item: item,
          showBack: showBack,
          aspectRatio: _fullscreenAspectRatio,
          onTap: () {
            setDialogState(() {
              showBack = !showBack;
            });
          },
        ),
      ),
    );
  }
}

class _PreviewFlashcard extends StatelessWidget {
  const _PreviewFlashcard({
    required this.item,
    required this.showBack,
    required this.aspectRatio,
    this.onTap,
    this.onFullscreen,
    super.key,
  });

  final FlashcardListItemState item;
  final bool showBack;
  final double aspectRatio;
  final VoidCallback? onTap;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final face = showBack ? MxFlashcardFace.back : MxFlashcardFace.front;

    return MxFlashcard(
      content: showBack ? item.back : item.front,
      face: face,
      language: showBack
          ? l10n.flashcardsFieldBackLabel
          : l10n.flashcardsFieldFrontLabel,
      aspectRatio: aspectRatio,
      onTap: onTap,
      onFullscreen: onFullscreen,
    );
  }
}
