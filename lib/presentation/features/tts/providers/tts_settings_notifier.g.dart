// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TtsSettingsNotifier)
final ttsSettingsProvider = TtsSettingsNotifierProvider._();

final class TtsSettingsNotifierProvider
    extends $AsyncNotifierProvider<TtsSettingsNotifier, TtsSettings> {
  TtsSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSettingsNotifierHash();

  @$internal
  @override
  TtsSettingsNotifier create() => TtsSettingsNotifier();
}

String _$ttsSettingsNotifierHash() =>
    r'fac7f1e5b6f8a77b4476edb81e1ff0fb16d9acdd';

abstract class _$TtsSettingsNotifier extends $AsyncNotifier<TtsSettings> {
  FutureOr<TtsSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TtsSettings>, TtsSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TtsSettings>, TtsSettings>,
              AsyncValue<TtsSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
