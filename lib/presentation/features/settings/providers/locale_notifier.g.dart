// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide locale override. `null` means "follow the system locale"
/// and is the default. `MemoxApp` passes this into `MaterialApp.locale`.

@ProviderFor(LocaleNotifier)
final localeProvider = LocaleNotifierProvider._();

/// App-wide locale override. `null` means "follow the system locale"
/// and is the default. `MemoxApp` passes this into `MaterialApp.locale`.
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, Locale?> {
  /// App-wide locale override. `null` means "follow the system locale"
  /// and is the default. `MemoxApp` passes this into `MaterialApp.locale`.
  LocaleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeNotifierHash() => r'e364eca4ac545f01bebf8bc84bf4c35a5f010767';

/// App-wide locale override. `null` means "follow the system locale"
/// and is the default. `MemoxApp` passes this into `MaterialApp.locale`.

abstract class _$LocaleNotifier extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
