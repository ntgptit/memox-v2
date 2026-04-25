import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_breakpoints.dart';
import '../../../core/theme/responsive/app_layout.dart';
import 'mx_content_shell.dart';

/// Destination descriptor used by [MxAdaptiveScaffold] to render the right
/// navigation surface at each [WindowSize]:
/// - compact: [NavigationBar]
/// - medium / expanded: [NavigationRail]
/// - large / extraLarge: extended rail (drawer-style)
@immutable
class MxAdaptiveDestination {
  const MxAdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}

/// Top-level app shell that swaps its navigation surface based on the
/// window size. Screens should use [MxAdaptiveScaffold] at the root of any
/// tab/destination hierarchy. Leaf screens keep using `MxScaffold`.
///
/// All layout decisions (rail width, page padding, content cap) come from
/// [AppLayout] — no raw pixel numbers live in this widget.
class MxAdaptiveScaffold extends StatelessWidget {
  const MxAdaptiveScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.constrainBody = true,
    this.contentWidth = MxContentWidth.wide,
    super.key,
  });

  final List<MxAdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// When `true`, the body is wrapped in [MxContentShell] so its reading
  /// column never stretches across the whole rail-less area on wide screens.
  final bool constrainBody;

  /// Content-width role applied when [constrainBody] is `true`. Ignored
  /// otherwise.
  final MxContentWidth contentWidth;

  @override
  Widget build(BuildContext context) {
    final wrappedBody = constrainBody
        ? MxContentShell(width: contentWidth, child: body)
        : body;
    final appBar = (title != null || actions != null)
        ? AppBar(
            title: title != null
                ? Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            actions: actions,
          )
        : null;

    return switch (context.windowSize) {
      WindowSize.compact => Scaffold(
        appBar: appBar,
        body: SafeArea(child: wrappedBody),
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: d.label,
              ),
          ],
        ),
      ),
      WindowSize.medium || WindowSize.expanded => Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: wrappedBody),
            ],
          ),
        ),
      ),
      WindowSize.large || WindowSize.extraLarge => Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: AppLayout.railWidth,
                child: NavigationRail(
                  extended: true,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  minExtendedWidth: AppLayout.railWidth,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: wrappedBody),
            ],
          ),
        ),
      ),
    };
  }
}
