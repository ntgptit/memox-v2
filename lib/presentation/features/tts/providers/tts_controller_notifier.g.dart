// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_controller_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TtsController)
final ttsControllerProvider = TtsControllerProvider._();

final class TtsControllerProvider
    extends $NotifierProvider<TtsController, TtsState> {
  TtsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsControllerHash();

  @$internal
  @override
  TtsController create() => TtsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsState>(value),
    );
  }
}

String _$ttsControllerHash() => r'2b767e471babafd1c5c9e77ef8f75ca3339a3b2e';

abstract class _$TtsController extends $Notifier<TtsState> {
  TtsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TtsState, TtsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TtsState, TtsState>,
              TtsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ttsVoices)
final ttsVoicesProvider = TtsVoicesFamily._();

final class TtsVoicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TtsVoice>>,
          List<TtsVoice>,
          FutureOr<List<TtsVoice>>
        >
    with $FutureModifier<List<TtsVoice>>, $FutureProvider<List<TtsVoice>> {
  TtsVoicesProvider._({
    required TtsVoicesFamily super.from,
    required TtsLanguage super.argument,
  }) : super(
         retry: null,
         name: r'ttsVoicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ttsVoicesHash();

  @override
  String toString() {
    return r'ttsVoicesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TtsVoice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TtsVoice>> create(Ref ref) {
    final argument = this.argument as TtsLanguage;
    return ttsVoices(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TtsVoicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ttsVoicesHash() => r'd0a354b66d5953f274d6cc8a39a224a8e9d0677e';

final class TtsVoicesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TtsVoice>>, TtsLanguage> {
  TtsVoicesFamily._()
    : super(
        retry: null,
        name: r'ttsVoicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TtsVoicesProvider call(TtsLanguage language) =>
      TtsVoicesProvider._(argument: language, from: this);

  @override
  String toString() => r'ttsVoicesProvider';
}
