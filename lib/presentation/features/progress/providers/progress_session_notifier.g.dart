// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(progressStudySessions)
final progressStudySessionsProvider = ProgressStudySessionsProvider._();

final class ProgressStudySessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudySessionSnapshot>>,
          List<StudySessionSnapshot>,
          FutureOr<List<StudySessionSnapshot>>
        >
    with
        $FutureModifier<List<StudySessionSnapshot>>,
        $FutureProvider<List<StudySessionSnapshot>> {
  ProgressStudySessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressStudySessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressStudySessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<StudySessionSnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudySessionSnapshot>> create(Ref ref) {
    return progressStudySessions(ref);
  }
}

String _$progressStudySessionsHash() =>
    r'5b09bbc703659e780bd0467bda5611bd8c106896';

@ProviderFor(ProgressSessionActionController)
final progressSessionActionControllerProvider =
    ProgressSessionActionControllerProvider._();

final class ProgressSessionActionControllerProvider
    extends $AsyncNotifierProvider<ProgressSessionActionController, void> {
  ProgressSessionActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressSessionActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressSessionActionControllerHash();

  @$internal
  @override
  ProgressSessionActionController create() => ProgressSessionActionController();
}

String _$progressSessionActionControllerHash() =>
    r'65160fb426b475c9a3c71401d5af26ebae44e4e8';

abstract class _$ProgressSessionActionController extends $AsyncNotifier<void> {
  FutureOr<void> build();
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
    element.handleCreate(ref, build);
  }
}
