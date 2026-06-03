import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_search_field.dart';
import '../../../shared/widgets/mx_text.dart';

/// Library top section per Design System "03 · Library overview".
///
/// Layout: large `Library` title on the left with a sliders/filter affordance
/// on the right, and an always-visible scope-local search field directly below
/// the title row. The search is inline (it never navigates to Global Search).
///
/// The sliders/filter icon is a **visual-only target** for now: Library has no
/// approved filter/sort sheet yet, so the control is rendered disabled rather
/// than exposing an unsupported action (Prompt 49B).
class LibraryAppBar extends StatefulWidget {
  const LibraryAppBar({
    required this.title,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.onSearchClear,
    super.key,
  });

  final String title;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  @override
  State<LibraryAppBar> createState() => _LibraryAppBarState();
}

class _LibraryAppBarState extends State<LibraryAppBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.searchTerm);

  @override
  void didUpdateWidget(LibraryAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the field in sync when the scope-local term is cleared from
    // elsewhere (e.g. the search no-results "Clear" CTA).
    if (widget.searchTerm != oldWidget.searchTerm &&
        widget.searchTerm != _controller.text) {
      _controller.text = widget.searchTerm;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: MxText(widget.title, role: MxTextRole.pageTitle)),
            MxIconButton(
              icon: Icons.tune_rounded,
              tooltip: l10n.libraryFiltersTooltip,
              // Visual-only target: no approved Library-level filter/sort sheet
              // exists yet, so the control stays disabled (Prompt 49B).
              onPressed: null,
            ),
          ],
        ),
        const MxGap(MxSpace.sm),
        MxSearchField(
          controller: _controller,
          hintText: l10n.librarySearchHint,
          onChanged: widget.onSearchChanged,
          onClear: widget.onSearchClear,
        ),
      ],
    );
  }
}
