import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import 'mx_content_shell.dart';
import 'mx_scaffold.dart';
import 'mx_space.dart';

/// Form-oriented screen template.
///
/// Keeps editable content scrollable while the primary action area remains
/// anchored above the bottom safe area and keyboard. Validation, submit
/// commands, provider reads/watches, and domain decisions stay in feature code.
class MxFormScaffold extends StatelessWidget {
  const MxFormScaffold({
    required this.body,
    this.bottomAction,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.contentWidth = MxContentWidth.reading,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final Widget body;
  final Widget? bottomAction;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final MxContentWidth contentWidth;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pagePadding;
    final action = bottomAction;

    return MxScaffold(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bodyInsets: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: MxContentShell(
                width: contentWidth,
                applyVerticalPadding: true,
                child: body,
              ),
            ),
          ),
          if (action != null)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth(contentWidth),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      // guard:layout-value-reviewed -- reason: combines responsive horizontal gutters with tokenized vertical action spacing.
                      horizontal.left,
                      MxSpace.sm,
                      horizontal.right,
                      MxSpace.md,
                    ),
                    child: action,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
