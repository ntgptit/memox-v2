import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';
import 'mx_content_shell.dart';
import 'mx_scaffold.dart';

/// List-oriented screen template.
///
/// Owns only shared layout concerns: app chrome, content width, page padding,
/// FAB clearance, and optional app-bar slots. Data state, search/filter,
/// loading/error/empty handling, providers, and repositories belong in feature
/// sections below this shell.
class MxListScaffold extends StatelessWidget {
  const MxListScaffold({
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.contentWidth = MxContentWidth.wide,
    this.applyVerticalPadding = true,
    this.hasFab,
    super.key,
  });

  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final MxContentWidth contentWidth;
  final bool applyVerticalPadding;
  final bool? hasFab;

  @override
  Widget build(BuildContext context) {
    final shouldReserveFabSpace = hasFab ?? floatingActionButton != null;

    return MxScaffold(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: MxContentShell(
        width: contentWidth,
        applyVerticalPadding: applyVerticalPadding,
        hasFab: shouldReserveFabSpace,
        child: body,
      ),
    );
  }
}
