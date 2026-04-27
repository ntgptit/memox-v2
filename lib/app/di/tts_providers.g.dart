// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ttsSharedPreferences)
final ttsSharedPreferencesProvider = TtsSharedPreferencesProvider._();

final class TtsSharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  TtsSharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return ttsSharedPreferences(ref);
  }
}

String _$ttsSharedPreferencesHash() =>
    r'8eb1582d87c1294135bc7955374fc6a0e454d8c3';

@ProviderFor(ttsSettingsStore)
final ttsSettingsStoreProvider = TtsSettingsStoreProvider._();

final class TtsSettingsStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<TtsSettingsStore>,
          TtsSettingsStore,
          FutureOr<TtsSettingsStore>
        >
    with $FutureModifier<TtsSettingsStore>, $FutureProvider<TtsSettingsStore> {
  TtsSettingsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSettingsStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSettingsStoreHash();

  @$internal
  @override
  $FutureProviderElement<TtsSettingsStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TtsSettingsStore> create(Ref ref) {
    return ttsSettingsStore(ref);
  }
}

String _$ttsSettingsStoreHash() => r'60f4a306d4fdea5a082ea7abf569a74f87c30d4e';

@ProviderFor(ttsService)
final ttsServiceProvider = TtsServiceProvider._();

final class TtsServiceProvider
    extends $FunctionalProvider<TtsService, TtsService, TtsService>
    with $Provider<TtsService> {
  TtsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsServiceHash();

  @$internal
  @override
  $ProviderElement<TtsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TtsService create(Ref ref) {
    return ttsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsService>(value),
    );
  }
}

String _$ttsServiceHash() => r'23611aca1f04a36deefe992a5166e92121290eda';

@ProviderFor(speakFlashcardUseCase)
final speakFlashcardUseCaseProvider = SpeakFlashcardUseCaseProvider._();

final class SpeakFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          SpeakFlashcardUseCase,
          SpeakFlashcardUseCase,
          SpeakFlashcardUseCase
        >
    with $Provider<SpeakFlashcardUseCase> {
  SpeakFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speakFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speakFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<SpeakFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpeakFlashcardUseCase create(Ref ref) {
    return speakFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeakFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeakFlashcardUseCase>(value),
    );
  }
}

String _$speakFlashcardUseCaseHash() =>
    r'6834dcfc2b1acb78114c86a63e28565630ce8fa1';
