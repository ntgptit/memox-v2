import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

typedef AppBuilder = FutureOr<Widget> Function();
typedef BootstrapTask = FutureOr<void> Function();
typedef ErrorReporter =
    FutureOr<void> Function(Object error, StackTrace stackTrace);

/// Centralized application bootstrap entrypoint.
///
/// Keeps startup sequencing out of `main.dart` so future boot tasks
/// (prefs hydration, local DB open, remote config, crash reporting) have
/// one place to plug into.
final class AppBootstrap {
  const AppBootstrap._();

  static Future<void> bootstrap({
    required AppBuilder builder,
    BootstrapTask? beforeRun,
    ErrorReporter? reportError,
  }) async {
    _configureStackTraceDemangler();

    final errorReporter = reportError ?? _reportUnhandledError;
    final originalFlutterOnError = FlutterError.onError;

    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        FlutterError.onError = (details) {
          originalFlutterOnError?.call(details);
          final stackTrace = details.stack ?? StackTrace.current;
          errorReporter(details.exception, stackTrace);
        };

        PlatformDispatcher.instance.onError = (error, stackTrace) {
          errorReporter(error, stackTrace);
          return true;
        };

        if (beforeRun != null) {
          await beforeRun();
        }

        final app = await builder();
        runApp(app);
      },
      (error, stackTrace) {
        errorReporter(error, stackTrace);
      },
    );
  }

  static void _reportUnhandledError(Object error, StackTrace stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
  }

  static void _configureStackTraceDemangler() {
    final originalDemangler = FlutterError.demangleStackTrace;

    FlutterError.demangleStackTrace = (stackTrace) {
      final demangledStackTrace = originalDemangler(stackTrace);

      if (demangledStackTrace is stack_trace.Trace) {
        return demangledStackTrace.vmTrace;
      }

      if (demangledStackTrace is stack_trace.Chain) {
        return demangledStackTrace.toTrace().vmTrace;
      }

      return demangledStackTrace;
    };
  }
}
