import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_elevation.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';

typedef MxReorderableItemBuilder =
    Widget Function(BuildContext context, int index);

/// Thin wrapper over [ReorderableListView.builder] with a shared drag proxy.
class MxReorderableList extends StatelessWidget {
  const MxReorderableList.builder({
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    this.padding = EdgeInsets.zero,
    this.header,
    this.footer,
    this.shrinkWrap = false,
    this.physics,
    this.buildDefaultDragHandles = false,
    this.proxyDecorator,
    super.key,
  });

  final int itemCount;
  final MxReorderableItemBuilder itemBuilder;
  final ReorderCallback onReorder;
  final EdgeInsets padding;
  final Widget? header;
  final Widget? footer;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool buildDefaultDragHandles;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final child = itemBuilder(context, index);
        assert(child.key != null, 'MxReorderableList items must have keys.');
        return child;
      },
      onReorder: onReorder,
      padding: padding,
      header: header,
      footer: footer,
      shrinkWrap: shrinkWrap,
      physics: physics,
      buildDefaultDragHandles: buildDefaultDragHandles,
      proxyDecorator:
          proxyDecorator ??
          (child, _, animation) =>
              _MxDefaultReorderProxy(animation: animation, child: child),
    );
  }
}

class _MxDefaultReorderProxy extends StatelessWidget {
  const _MxDefaultReorderProxy({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);

        return Transform.scale(
          scale: lerpDouble(1, 1.01, t)!,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: AppOpacity.transparent),
            elevation: lerpDouble(
              AppElevation.card,
              AppElevation.cardRaised,
              t,
            )!,
            shadowColor: Theme.of(context).shadowColor,
            borderRadius: AppRadius.card,
            child: child,
          ),
        );
      },
    );
  }
}
