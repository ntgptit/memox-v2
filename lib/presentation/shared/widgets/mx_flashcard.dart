import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'mx_card.dart';
import 'mx_icon_button.dart';
import 'mx_text.dart';

enum MxFlashcardFace { front, back }

/// Hero card surface for the flashcard study flow. Displays a term (or
/// definition) at large display type, with an optional fullscreen icon in the
/// bottom-right and a tap-to-flip behavior.
///
/// Keep business logic (which face to show, which card is next) in a
/// provider/notifier — this widget only renders a face.
class MxFlashcard extends StatelessWidget {
  const MxFlashcard({
    required this.content,
    this.face = MxFlashcardFace.front,
    this.onTap,
    this.onFullscreen,
    this.language,
    this.aspectRatio = 0.75,
    super.key,
  });

  final String content;
  final MxFlashcardFace face;
  final VoidCallback? onTap;
  final VoidCallback? onFullscreen;

  /// Optional BCP-47 language tag shown as a small label above the term.
  final String? language;

  /// Width / height ratio for the card surface. Default tuned for portrait.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: MxCard(
        variant: MxCardVariant.elevated,
        borderRadius: AppRadius.cardLarge,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        onTap: onTap,
        child: Stack(
          children: [
            if (language != null)
              Align(
                alignment: Alignment.topLeft,
                child: MxText(
                  language!,
                  role: MxTextRole.badge,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            Center(
              child: MxText(
                content,
                role: MxTextRole.displayLarge,
                textAlign: TextAlign.center,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onFullscreen != null)
              Align(
                alignment: Alignment.bottomRight,
                child: MxIconButton(
                  icon: Icons.fullscreen,
                  size: AppIconSizes.lg,
                  tooltip: l10n.sharedFullscreenTooltip,
                  onPressed: onFullscreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
