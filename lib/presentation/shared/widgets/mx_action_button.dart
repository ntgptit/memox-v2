import 'package:flutter/material.dart';

import 'mx_button_size.dart';
import 'mx_primary_button.dart';
import 'mx_secondary_button.dart';

/// Semantic action context. A feature declares *where* an action lives, not how
/// big the button should be. The context resolves to a tokenized size, the
/// right primitive (primary vs secondary), and whether full-width is permitted.
///
/// This is the enforcement layer for the action-density contract: it makes the
/// oversized full-width card button hard to produce by accident. See
/// `docs/ui-ux/action-hierarchy-contract.md`.
enum MxActionIntent {
  /// The single dominant action on a screen (form footer, screen header CTA).
  screenPrimary,

  /// The main action inside a content/action card. Compact, never full-width.
  cardPrimary,

  /// A lighter companion action inside a card. Visually lighter than
  /// [cardPrimary].
  cardSecondary,

  /// A small action embedded inline with text or a row.
  inline,

  /// A dense toolbar / app-bar action.
  toolbar,

  /// The confirm action inside a dialog.
  dialogPrimary,

  /// The action in a screen-bottom action area / sticky bar. Full-width.
  bottomAction,

  /// The recovery CTA inside a full-screen empty state.
  emptyState,

  /// The hero CTA in onboarding / first-run. Large, full-width.
  onboardingHero,

  /// The submit / final action in a study session, where the study contract
  /// specifies a prominent button.
  studyPrimary,
}

/// Resolved density rules for an [MxActionIntent].
class _ActionSpec {
  const _ActionSpec({
    required this.size,
    required this.isPrimary,
    required this.allowsFullWidth,
    required this.defaultFullWidth,
    this.secondaryVariant = MxSecondaryVariant.tonal,
  });

  final MxButtonSize size;
  final bool isPrimary;
  final bool allowsFullWidth;
  final bool defaultFullWidth;
  final MxSecondaryVariant secondaryVariant;
}

_ActionSpec _specFor(MxActionIntent intent) => switch (intent) {
  MxActionIntent.screenPrimary => const _ActionSpec(
    size: MxButtonSize.medium,
    isPrimary: true,
    allowsFullWidth: true,
    defaultFullWidth: false,
  ),
  MxActionIntent.cardPrimary => const _ActionSpec(
    size: MxButtonSize.compact,
    isPrimary: true,
    allowsFullWidth: false,
    defaultFullWidth: false,
  ),
  MxActionIntent.cardSecondary => const _ActionSpec(
    size: MxButtonSize.compact,
    isPrimary: false,
    allowsFullWidth: false,
    defaultFullWidth: false,
  ),
  MxActionIntent.inline => const _ActionSpec(
    size: MxButtonSize.small,
    isPrimary: false,
    allowsFullWidth: false,
    defaultFullWidth: false,
    secondaryVariant: MxSecondaryVariant.text,
  ),
  MxActionIntent.toolbar => const _ActionSpec(
    size: MxButtonSize.xsmall,
    isPrimary: false,
    allowsFullWidth: false,
    defaultFullWidth: false,
    secondaryVariant: MxSecondaryVariant.text,
  ),
  MxActionIntent.dialogPrimary => const _ActionSpec(
    size: MxButtonSize.medium,
    isPrimary: true,
    allowsFullWidth: false,
    defaultFullWidth: false,
  ),
  MxActionIntent.bottomAction => const _ActionSpec(
    size: MxButtonSize.medium,
    isPrimary: true,
    allowsFullWidth: true,
    defaultFullWidth: true,
  ),
  MxActionIntent.emptyState => const _ActionSpec(
    size: MxButtonSize.medium,
    isPrimary: true,
    allowsFullWidth: true,
    defaultFullWidth: false,
  ),
  MxActionIntent.onboardingHero => const _ActionSpec(
    size: MxButtonSize.large,
    isPrimary: true,
    allowsFullWidth: true,
    defaultFullWidth: true,
  ),
  MxActionIntent.studyPrimary => const _ActionSpec(
    size: MxButtonSize.compact,
    isPrimary: true,
    allowsFullWidth: true,
    defaultFullWidth: false,
  ),
};

/// Semantic action button. Features pick an [MxActionIntent] instead of a raw
/// [MxButtonSize] / `fullWidth`, so card-level actions cannot become oversized
/// hero CTAs by accident.
///
/// Delegates rendering to [MxPrimaryButton] / [MxSecondaryButton]; those remain
/// the low-level primitives.
class MxActionButton extends StatelessWidget {
  const MxActionButton({
    required this.intent,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDestructive = false,
    this.fullWidth,
    super.key,
  });

  final MxActionIntent intent;
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;

  /// Maps to the danger tone on whichever primitive the intent uses.
  final bool isDestructive;

  /// Explicit full-width override. Honored only for intents whose context
  /// allows full-width (screen-bottom, empty state, onboarding, study, screen
  /// primary). Ignored for card/inline/toolbar/dialog intents — they are never
  /// full-width. When null the intent's own default applies.
  final bool? fullWidth;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(intent);
    final requested = fullWidth ?? spec.defaultFullWidth;
    assert(
      !(fullWidth == true && !spec.allowsFullWidth),
      'MxActionIntent.$intent does not allow full-width actions. '
      'See docs/ui-ux/action-hierarchy-contract.md.',
    );
    final effectiveFullWidth = spec.allowsFullWidth && requested;

    if (spec.isPrimary) {
      return MxPrimaryButton(
        label: label,
        onPressed: onPressed,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        size: spec.size,
        tone: isDestructive
            ? MxPrimaryButtonTone.danger
            : MxPrimaryButtonTone.primary,
        isLoading: isLoading,
        fullWidth: effectiveFullWidth,
      );
    }

    return MxSecondaryButton(
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      size: spec.size,
      variant: spec.secondaryVariant,
      tone: isDestructive
          ? MxSecondaryButtonTone.danger
          : MxSecondaryButtonTone.neutral,
      isLoading: isLoading,
      fullWidth: effectiveFullWidth,
    );
  }
}
