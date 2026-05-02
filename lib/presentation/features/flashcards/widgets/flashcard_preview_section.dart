import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/dialogs/mx_dialog.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
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
  static const double _previewAspectRatio = 1.48;
  static const double _fullscreenAspectRatio = 0.75;

  late final PageController _controller = PageController();
  var _activeIndex = 0;

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
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxWidth / _previewAspectRatio,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.items.length,
                onPageChanged: (index) {
                  setState(() {
                    _activeIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return MxFlashcard(
                    content: item.front,
                    aspectRatio: _previewAspectRatio,
                    onFullscreen: () => _showFullscreen(context, item),
                  );
                },
              ),
            );
          },
        ),
        const MxGap(MxSpace.md),
        MxPageDots(
          count: widget.items.length,
          activeIndex: _activeIndex,
          onDotTap: (index) {
            _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }

  Future<void> _showFullscreen(
    BuildContext context,
    FlashcardListItemState item,
  ) {
    final l10n = AppLocalizations.of(context);
    return MxDialog.show<void>(
      context: context,
      title: l10n.flashcardsPreviewDialogTitle,
      child: MxFlashcard(
        content: item.front,
        aspectRatio: _fullscreenAspectRatio,
      ),
    );
  }
}
