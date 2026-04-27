// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudySessionDataRevision)
final studySessionDataRevisionProvider = StudySessionDataRevisionProvider._();

final class StudySessionDataRevisionProvider
    extends $NotifierProvider<StudySessionDataRevision, int> {
  StudySessionDataRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionDataRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionDataRevisionHash();

  @$internal
  @override
  StudySessionDataRevision create() => StudySessionDataRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$studySessionDataRevisionHash() =>
    r'67455e5095b016544944633085940bb30a38a20e';

abstract class _$StudySessionDataRevision extends $Notifier<int> {
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

@ProviderFor(studySessionState)
final studySessionStateProvider = StudySessionStateFamily._();

final class StudySessionStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudySessionSnapshot>,
          StudySessionSnapshot,
          FutureOr<StudySessionSnapshot>
        >
    with
        $FutureModifier<StudySessionSnapshot>,
        $FutureProvider<StudySessionSnapshot> {
  StudySessionStateProvider._({
    required StudySessionStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studySessionStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySessionStateHash();

  @override
  String toString() {
    return r'studySessionStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StudySessionSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudySessionSnapshot> create(Ref ref) {
    final argument = this.argument as String;
    return studySessionState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudySessionStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySessionStateHash() => r'd2066dd825df863c783e6c92cf4386a79d94b181';

final class StudySessionStateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StudySessionSnapshot>, String> {
  StudySessionStateFamily._()
    : super(
        retry: null,
        name: r'studySessionStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  StudySessionStateProvider call(String sessionId) =>
      StudySessionStateProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'studySessionStateProvider';
}

@ProviderFor(StudySessionActionController)
final studySessionActionControllerProvider =
    StudySessionActionControllerFamily._();

final class StudySessionActionControllerProvider
    extends $AsyncNotifierProvider<StudySessionActionController, void> {
  StudySessionActionControllerProvider._({
    required StudySessionActionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studySessionActionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySessionActionControllerHash();

  @override
  String toString() {
    return r'studySessionActionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudySessionActionController create() => StudySessionActionController();

  @override
  bool operator ==(Object other) {
    return other is StudySessionActionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySessionActionControllerHash() =>
    r'47d9312dc2128d036cfc83b262db3c53550b3801';

final class StudySessionActionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudySessionActionController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          String
        > {
  StudySessionActionControllerFamily._()
    : super(
        retry: null,
        name: r'studySessionActionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudySessionActionControllerProvider call(String sessionId) =>
      StudySessionActionControllerProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'studySessionActionControllerProvider';
}

abstract class _$StudySessionActionController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<void> build(String sessionId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
