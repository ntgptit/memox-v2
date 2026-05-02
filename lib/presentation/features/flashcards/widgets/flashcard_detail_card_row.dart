import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardDetailCardRow extends StatelessWidget {
  const FlashcardDetailCardRow({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onSpeak,
    required this.onSelect,
    super.key,
  });

  final FlashcardListItemState item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSpeak;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      variant: selected ? MxCardVariant.outlined : MxCardVariant.filled,
      borderColor: selected ? scheme.primary : null,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MxText(
                  item.front,
                  role: MxTextRole.listTitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const MxGap(MxSpace.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxIconButton.compact(
                    icon: Icons.volume_up_outlined,
                    tooltip: l10n.studyCardAudioTooltip,
                    onPressed: onSpeak,
                  ),
                  const MxGap(MxSpace.md),
                  MxIconButton.compact(
                    icon: selected
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    tooltip: l10n.commonSelect,
                    isSelected: selected,
                    selectedIcon: Icons.star_rounded,
                    onPressed: onSelect,
                  ),
                ],
              ),
            ],
          ),
          const MxGap(MxSpace.md),
          MxText(
            item.back,
            role: MxTextRole.listSubtitle,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.note != null) ...[
            const MxGap(MxSpace.sm),
            MxText(
              item.note!,
              role: MxTextRole.tileMeta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
