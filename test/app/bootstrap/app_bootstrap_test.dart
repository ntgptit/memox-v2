import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/bootstrap/app_bootstrap.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

void main() {
  testWidgets('bootstrap demangles package stack_trace chains', (
    WidgetTester tester,
  ) async {
    final originalFlutterOnError = FlutterError.onError;
    final originalStackTraceDemangler = FlutterError.demangleStackTrace;
    final originalPlatformOnError = PlatformDispatcher.instance.onError;

    addTearDown(() {
      FlutterError.onError = originalFlutterOnError;
      FlutterError.demangleStackTrace = originalStackTraceDemangler;
      PlatformDispatcher.instance.onError = originalPlatformOnError;
    });

    FlutterError.demangleStackTrace = (stackTrace) => stackTrace;

    await AppBootstrap.bootstrap(
      builder: () => const SizedBox.shrink(),
      reportError: (_, _) {},
    );

    final stackChain = stack_trace.Chain([
      stack_trace.Trace.current(),
      stack_trace.Trace.current(),
    ]);

    expect(stackChain.toString(), contains('===== asynchronous gap'));

    final demangledStackTrace = FlutterError.demangleStackTrace(stackChain);

    expect(
      demangledStackTrace.toString(),
      isNot(contains('===== asynchronous gap')),
    );
    expect(
      () => FlutterError.defaultStackFilter(
        demangledStackTrace.toString().trimRight().split('\n'),
      ).toList(),
      returnsNormally,
    );
  });
}
