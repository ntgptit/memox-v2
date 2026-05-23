import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AppAsyncDataBuilder<T> = Widget Function(BuildContext context, T value);
typedef AppAsyncErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace);

class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    super.key,
    required this.value,
    required this.loading,
    required this.error,
    required this.data,
  });

  final AsyncValue<T> value;
  final WidgetBuilder loading;
  final AppAsyncErrorBuilder error;
  final AppAsyncDataBuilder<T> data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading(context),
      error: (error, stackTrace) => this.error(context, error, stackTrace),
      data: (value) => data(context, value),
    );
  }
}
