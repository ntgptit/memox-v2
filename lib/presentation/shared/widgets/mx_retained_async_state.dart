import 'package:flutter/material.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../feedback/mx_snackbar.dart';
import 'mx_error_state.dart';
import 'mx_loading_state.dart';

typedef MxAsyncErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

/// Keeps the last successful content visible while a query refreshes.
class MxRetainedAsyncState<T extends Object> extends StatefulWidget {
  const MxRetainedAsyncState({
    this.data,
    required this.isLoading,
    this.error,
    this.stackTrace,
    required this.dataBuilder,
    this.skeletonBuilder,
    this.errorBuilder,
    this.onRetry,
    super.key,
  });

  final T? data;
  final bool isLoading;
  final Object? error;
  final StackTrace? stackTrace;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final WidgetBuilder? skeletonBuilder;
  final MxAsyncErrorBuilder? errorBuilder;
  final VoidCallback? onRetry;

  @override
  State<MxRetainedAsyncState<T>> createState() =>
      _MxRetainedAsyncStateState<T>();
}

class _MxRetainedAsyncStateState<T extends Object>
    extends State<MxRetainedAsyncState<T>> {
  int? _lastShownErrorKey;

  @override
  void didUpdateWidget(covariant MxRetainedAsyncState<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleRefreshError();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data == null) {
      final error = widget.error;
      if (error != null) {
        final errorBuilder = widget.errorBuilder;
        if (errorBuilder != null) {
          return errorBuilder(context, error, widget.stackTrace);
        }
        final failure = ErrorMapper.map(error, widget.stackTrace);
        return MxErrorState(
          message: failure.message,
          details: failure.technicalDetails,
          onRetry: widget.onRetry,
        );
      }
      if (widget.skeletonBuilder != null) {
        return widget.skeletonBuilder!(context);
      }
      return const MxLoadingState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = widget.dataBuilder(context, data);
        final boundedContent = constraints.hasBoundedWidth
            ? SizedBox(width: constraints.maxWidth, child: content)
            : content;

        return Stack(
          children: [
            boundedContent,
            if (widget.isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(child: _MxRetainedAsyncRefreshBar()),
              ),
          ],
        );
      },
    );
  }

  void _handleRefreshError() {
    if (widget.error == null || widget.data == null) {
      _lastShownErrorKey = null;
      return;
    }

    final errorKey = Object.hash(widget.error, widget.stackTrace);
    if (_lastShownErrorKey == errorKey) {
      return;
    }
    _lastShownErrorKey = errorKey;

    final failure = ErrorMapper.map(widget.error, widget.stackTrace);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      MxSnackbar.error(context, failure.message);
    });
  }
}

class _MxRetainedAsyncRefreshBar extends StatelessWidget {
  const _MxRetainedAsyncRefreshBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LinearProgressIndicator(
      key: const ValueKey('mx_retained_async_refresh_bar'),
      backgroundColor: scheme.surfaceContainerHighest,
      minHeight: AppSpacing.xxs,
    );
  }
}
