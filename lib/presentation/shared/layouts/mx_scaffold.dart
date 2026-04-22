import 'package:flutter/material.dart';

/// Thin wrapper over [Scaffold] that sets MemoX defaults:
/// - Themed app bar title
/// - Optional search/filter row under the app bar
/// - Safe-area handling aware of the presence of a bottom nav
class MxScaffold extends StatelessWidget {
  const MxScaffold({
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  bool get _hasAppBar => title != null || titleWidget != null || actions != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: _hasAppBar
          ? AppBar(
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              title: titleWidget ??
                  (title != null
                      ? Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null),
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: SafeArea(
        top: !_hasAppBar,
        bottom: bottomNavigationBar == null,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}
