import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/states/mx_error_state.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/states/mx_retained_async_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows full loading state on first load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: const MxRetainedAsyncState<String>(
          isLoading: true,
          dataBuilder: _buildData,
        ),
      ),
    );

    expect(find.byType(MxLoadingState), findsOneWidget);
    expect(find.text('Loaded value'), findsNothing);
  });

  testWidgets('DT2 onOpen: uses skeleton builder on first load when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: MxRetainedAsyncState<String>(
          isLoading: true,
          skeletonBuilder: (_) => const Text('Skeleton'),
          dataBuilder: _buildData,
        ),
      ),
    );

    expect(find.text('Skeleton'), findsOneWidget);
    expect(find.byType(MxLoadingState), findsNothing);
  });

  testWidgets(
    'DT1 onRefreshRetry: keeps previous content and shows refresh bar while refetching',
    (WidgetTester tester) async {
      final controller = _FutureController<String>(
        Future<String>.value('Loaded value'),
      );
      final currentFutureProvider =
          ChangeNotifierProvider<_FutureController<String>>(
            (ref) => controller,
          );
      final queryProvider = FutureProvider<String>(
        (ref) => ref.watch(currentFutureProvider).future,
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestApp(
            child: Consumer(
              builder: (context, ref, _) {
                final query = ref.watch(queryProvider);
                return MxRetainedAsyncState<String>(
                  data: query.value,
                  isLoading: query.isLoading,
                  error: query.hasError ? query.error : null,
                  stackTrace: query.hasError ? query.stackTrace : null,
                  dataBuilder: _buildData,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Loaded value'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
        findsNothing,
      );

      final refreshCompleter = Completer<String>();
      controller.future = refreshCompleter.future;
      await tester.pump();

      expect(find.text('Loaded value'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT2 onRefreshRetry: keeps previous content and shows snackbar when refresh fails',
    (WidgetTester tester) async {
      final controller = _FutureController<String>(
        Future<String>.value('Loaded value'),
      );
      final currentFutureProvider =
          ChangeNotifierProvider<_FutureController<String>>(
            (ref) => controller,
          );
      final queryProvider = FutureProvider<String>(
        (ref) => ref.watch(currentFutureProvider).future,
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestApp(
            child: Consumer(
              builder: (context, ref, _) {
                final query = ref.watch(queryProvider);
                return MxRetainedAsyncState<String>(
                  data: query.value,
                  isLoading: query.isLoading,
                  error: query.hasError ? query.error : null,
                  stackTrace: query.hasError ? query.stackTrace : null,
                  dataBuilder: _buildData,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final refreshCompleter = Completer<String>();
      controller.future = refreshCompleter.future;
      await tester.pump();

      refreshCompleter.completeError(StateError('refresh failed'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Loaded value'), findsOneWidget);
      expect(find.byType(MxErrorState), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Something went wrong.'), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onRefreshRetry: expands retained content to bounded parent width',
    (WidgetTester tester) async {
      const contentKey = ValueKey('retained-content-width');
      const hostWidth = 320.0;

      await tester.pumpWidget(
        _TestApp(
          child: SizedBox(
            width: hostWidth,
            child: MxRetainedAsyncState<String>(
              data: 'Loaded value',
              isLoading: true,
              dataBuilder: (_, data) =>
                  SizedBox(key: contentKey, height: 24, child: Text(data)),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(contentKey)).width, hostWidth);
      expect(
        find.byKey(const ValueKey('mx_retained_async_refresh_bar')),
        findsOneWidget,
      );
    },
  );

  testWidgets('DT3 onOpen: shows error state when first load fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: MxRetainedAsyncState<String>(
          isLoading: false,
          error: StateError('boom'),
          stackTrace: StackTrace.empty,
          dataBuilder: _buildData,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxErrorState), findsOneWidget);
    expect(find.byType(MxLoadingState), findsNothing);
  });
}

Widget _buildData(BuildContext context, String data) => Text(data);

class _FutureController<T> extends ChangeNotifier {
  _FutureController(this._future);

  Future<T> _future;

  Future<T> get future => _future;

  set future(Future<T> value) {
    _future = value;
    notifyListeners();
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
