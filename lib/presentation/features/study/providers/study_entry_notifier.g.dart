// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_entry_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studyEntryState)
final studyEntryStateProvider = StudyEntryStateFamily._();

final class StudyEntryStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudyEntryState>,
          StudyEntryState,
          FutureOr<StudyEntryState>
        >
    with $FutureModifier<StudyEntryState>, $FutureProvider<StudyEntryState> {
  StudyEntryStateProvider._({
    required StudyEntryStateFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'studyEntryStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyEntryStateHash();

  @override
  String toString() {
    return r'studyEntryStateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<StudyEntryState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudyEntryState> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return studyEntryState(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyEntryStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyEntryStateHash() => r'0087504f56b5584a21e164fced4e3dbedcac846c';

final class StudyEntryStateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<StudyEntryState>,
          (String, String?)
        > {
  StudyEntryStateFamily._()
    : super(
        retry: null,
        name: r'studyEntryStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  StudyEntryStateProvider call(String entryType, String? entryRefId) =>
      StudyEntryStateProvider._(argument: (entryType, entryRefId), from: this);

  @override
  String toString() => r'studyEntryStateProvider';
}

@ProviderFor(StudyEntryActionController)
final studyEntryActionControllerProvider = StudyEntryActionControllerFamily._();

final class StudyEntryActionControllerProvider
    extends $AsyncNotifierProvider<StudyEntryActionController, void> {
  StudyEntryActionControllerProvider._({
    required StudyEntryActionControllerFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'studyEntryActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyEntryActionControllerHash();

  @override
  String toString() {
    return r'studyEntryActionControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  StudyEntryActionController create() => StudyEntryActionController();

  @override
  bool operator ==(Object other) {
    return other is StudyEntryActionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyEntryActionControllerHash() =>
    r'ab5d2681696d9bbc79efc9f7710cc0ed3d8342d5';

final class StudyEntryActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyEntryActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          (String, String?)
        > {
  StudyEntryActionControllerFamily._()
    : super(
        retry: null,
        name: r'studyEntryActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyEntryActionControllerProvider call(
    String entryType,
    String? entryRefId,
  ) => StudyEntryActionControllerProvider._(
    argument: (entryType, entryRefId),
    from: this,
  );

  @override
  String toString() => r'studyEntryActionControllerProvider';
}

abstract class _$StudyEntryActionController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as (String, String?);
  String get entryType => _$args.$1;
  String? get entryRefId => _$args.$2;

  FutureOr<void> build(String entryType, String? entryRefId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
