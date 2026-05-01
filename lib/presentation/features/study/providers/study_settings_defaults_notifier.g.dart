// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_settings_defaults_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudySettingsDataRevision)
final studySettingsDataRevisionProvider = StudySettingsDataRevisionProvider._();

final class StudySettingsDataRevisionProvider
    extends $NotifierProvider<StudySettingsDataRevision, int> {
  StudySettingsDataRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySettingsDataRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySettingsDataRevisionHash();

  @$internal
  @override
  StudySettingsDataRevision create() => StudySettingsDataRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$studySettingsDataRevisionHash() =>
    r'b1c32670b4861408f634ed976eb8c915e4bb43a8';

abstract class _$StudySettingsDataRevision extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(StudyDefaultsSettings)
final studyDefaultsSettingsProvider = StudyDefaultsSettingsProvider._();

final class StudyDefaultsSettingsProvider
    extends
        $AsyncNotifierProvider<
          StudyDefaultsSettings,
          StudyDefaultsSettingsState
        > {
  StudyDefaultsSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyDefaultsSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyDefaultsSettingsHash();

  @$internal
  @override
  StudyDefaultsSettings create() => StudyDefaultsSettings();
}

String _$studyDefaultsSettingsHash() =>
    r'ba3cf46aeea89f8a743d566ce79133351fe397d0';

abstract class _$StudyDefaultsSettings
    extends $AsyncNotifier<StudyDefaultsSettingsState> {
  FutureOr<StudyDefaultsSettingsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<StudyDefaultsSettingsState>,
              StudyDefaultsSettingsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<StudyDefaultsSettingsState>,
                StudyDefaultsSettingsState
              >,
              AsyncValue<StudyDefaultsSettingsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
