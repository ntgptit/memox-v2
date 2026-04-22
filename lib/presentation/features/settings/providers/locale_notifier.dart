import 'dart:ui' show Locale;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

/// App-wide locale override. `null` means "follow the system locale"
/// and is the default. `MemoxApp` passes this into `MaterialApp.locale`.
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale? build() => null;

  void set(Locale? locale) => state = locale;
  void clear() => state = null;
}
