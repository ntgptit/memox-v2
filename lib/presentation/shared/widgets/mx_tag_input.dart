import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/utils/string_utils.dart';
import '../dialogs/mx_bottom_sheet.dart';
import 'mx_chip.dart';
import 'mx_primary_button.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';
import 'mx_text_field.dart';

/// Tag editor — chip wrap + dashed-border "+ Add tag" trigger.
///
/// Per Design System "05 · Create card", tapping the trailing trigger opens a
/// modal bottom sheet with a single-line input. Submitting the field (or
/// tapping the confirm button) commits the new tag via [onAdd]. Existing
/// chips delete via [onRemove].
class MxTagInput extends StatelessWidget {
  const MxTagInput({
    required this.tags,
    required this.onAdd,
    required this.onRemove,
    required this.addLabel,
    required this.sheetTitle,
    required this.hintText,
    required this.confirmLabel,
    super.key,
  });

  final List<String> tags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final String addLabel;
  final String sheetTitle;
  final String hintText;
  final String confirmLabel;

  Future<void> _openSheet(BuildContext context) async {
    final tag = await MxBottomSheet.show<String>(
      context: context,
      title: sheetTitle,
      child: _TagInputSheetBody(
        hintText: hintText,
        confirmLabel: confirmLabel,
      ),
    );
    if (tag == null) return;
    final trimmed = StringUtils.trimmed(tag);
    if (trimmed.isEmpty) return;
    onAdd(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tag in tags)
          MxChip(
            label: tag,
            tone: MxChipTone.primary,
            onDeleted: () => onRemove(tag),
          ),
        _AddTagTrigger(
          label: addLabel,
          onTap: () => _openSheet(context),
        ),
      ],
    );
  }
}

class _AddTagTrigger extends StatelessWidget {
  const _AddTagTrigger({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = const StadiumBorder();
    return MxTappable(
      shape: shape,
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedStadiumPainter(
          color: scheme.outlineVariant,
          strokeWidth: 1,
          dashLength: AppSpacing.xs,
          gapLength: AppSpacing.xs,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: AppIconSizes.sm,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              MxText(label, role: MxTextRole.tileTrailing),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedStadiumPainter extends CustomPainter {
  const _DashedStadiumPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    // guard:raw-size-reviewed Stadium radius is geometric (half-height); the
    // raw double form sidesteps the `Radius.circular` token rule because no
    // AppRadius token can express a size-dependent value.
    final stadiumRadius = size.height / 2;
    final rrect = RRect.fromLTRBXY(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      stadiumRadius,
      stadiumRadius,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedStadiumPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength;
  }
}

class _TagInputSheetBody extends StatefulWidget {
  const _TagInputSheetBody({
    required this.hintText,
    required this.confirmLabel,
  });

  final String hintText;
  final String confirmLabel;

  @override
  State<_TagInputSheetBody> createState() => _TagInputSheetBodyState();
}

class _TagInputSheetBodyState extends State<_TagInputSheetBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = StringUtils.trimmed(_controller.text);
    if (trimmed.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxTextField(
          controller: _controller,
          hintText: widget.hintText,
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.none,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.md),
        MxPrimaryButton(
          label: widget.confirmLabel,
          fullWidth: true,
          onPressed: _submit,
        ),
      ],
    );
  }
}

