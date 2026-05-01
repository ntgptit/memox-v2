// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

@ProviderFor(studySettingsStore)
final studySettingsStoreProvider = StudySettingsStoreProvider._();

final class StudySettingsStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudySettingsStore>,
          StudySettingsStore,
          FutureOr<StudySettingsStore>
        >
    with
        $FutureModifier<StudySettingsStore>,
        $FutureProvider<StudySettingsStore> {
  StudySettingsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySettingsStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySettingsStoreHash();

  @$internal
  @override
  $FutureProviderElement<StudySettingsStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudySettingsStore> create(Ref ref) {
    return studySettingsStore(ref);
  }
}

String _$studySettingsStoreHash() =>
    r'26bb47cca157c89bb064de33b1d7cfc76dc7e6cc';

@ProviderFor(studySessionDao)
final studySessionDaoProvider = StudySessionDaoProvider._();

final class StudySessionDaoProvider
    extends
        $FunctionalProvider<StudySessionDao, StudySessionDao, StudySessionDao>
    with $Provider<StudySessionDao> {
  StudySessionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionDaoHash();

  @$internal
  @override
  $ProviderElement<StudySessionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudySessionDao create(Ref ref) {
    return studySessionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySessionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySessionDao>(value),
    );
  }
}

String _$studySessionDaoHash() => r'3c5360fa2a935411ca7ea0a58016646b08c71717';

@ProviderFor(studySessionItemDao)
final studySessionItemDaoProvider = StudySessionItemDaoProvider._();

final class StudySessionItemDaoProvider
    extends
        $FunctionalProvider<
          StudySessionItemDao,
          StudySessionItemDao,
          StudySessionItemDao
        >
    with $Provider<StudySessionItemDao> {
  StudySessionItemDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionItemDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionItemDaoHash();

  @$internal
  @override
  $ProviderElement<StudySessionItemDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudySessionItemDao create(Ref ref) {
    return studySessionItemDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySessionItemDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySessionItemDao>(value),
    );
  }
}

String _$studySessionItemDaoHash() =>
    r'5aa334d223484e14fd94314acbb3fa58cd0933dd';

@ProviderFor(studyAttemptDao)
final studyAttemptDaoProvider = StudyAttemptDaoProvider._();

final class StudyAttemptDaoProvider
    extends
        $FunctionalProvider<StudyAttemptDao, StudyAttemptDao, StudyAttemptDao>
    with $Provider<StudyAttemptDao> {
  StudyAttemptDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyAttemptDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyAttemptDaoHash();

  @$internal
  @override
  $ProviderElement<StudyAttemptDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudyAttemptDao create(Ref ref) {
    return studyAttemptDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyAttemptDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyAttemptDao>(value),
    );
  }
}

String _$studyAttemptDaoHash() => r'733e1f36db5e6967d2dccf39d22af9af589ed13c';

@ProviderFor(studyStrategyFactory)
final studyStrategyFactoryProvider = StudyStrategyFactoryProvider._();

final class StudyStrategyFactoryProvider
    extends
        $FunctionalProvider<
          StudyFlowStrategyFactory,
          StudyFlowStrategyFactory,
          StudyFlowStrategyFactory
        >
    with $Provider<StudyFlowStrategyFactory> {
  StudyStrategyFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyStrategyFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyStrategyFactoryHash();

  @$internal
  @override
  $ProviderElement<StudyFlowStrategyFactory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyFlowStrategyFactory create(Ref ref) {
    return studyStrategyFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyFlowStrategyFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyFlowStrategyFactory>(value),
    );
  }
}

String _$studyStrategyFactoryHash() =>
    r'e77c177f5d73b331d17b7fa9f694d23d6db640de';

@ProviderFor(studyModeStrategyFactory)
final studyModeStrategyFactoryProvider = StudyModeStrategyFactoryProvider._();

final class StudyModeStrategyFactoryProvider
    extends
        $FunctionalProvider<
          StudyModeStrategyFactory,
          StudyModeStrategyFactory,
          StudyModeStrategyFactory
        >
    with $Provider<StudyModeStrategyFactory> {
  StudyModeStrategyFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyModeStrategyFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyModeStrategyFactoryHash();

  @$internal
  @override
  $ProviderElement<StudyModeStrategyFactory> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StudyModeStrategyFactory create(Ref ref) {
    return studyModeStrategyFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyModeStrategyFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyModeStrategyFactory>(value),
    );
  }
}

String _$studyModeStrategyFactoryHash() =>
    r'993028e0cd8510150ea4a5715e717c62ae658256';

@ProviderFor(studyShuffleRandom)
final studyShuffleRandomProvider = StudyShuffleRandomProvider._();

final class StudyShuffleRandomProvider
    extends $FunctionalProvider<Random, Random, Random>
    with $Provider<Random> {
  StudyShuffleRandomProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyShuffleRandomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyShuffleRandomHash();

  @$internal
  @override
  $ProviderElement<Random> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Random create(Ref ref) {
    return studyShuffleRandom(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Random value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Random>(value),
    );
  }
}

String _$studyShuffleRandomHash() =>
    r'c550107ab3faa86b5f546fa30f01ed27866af46e';

@ProviderFor(studyRepo)
final studyRepoProvider = StudyRepoProvider._();

final class StudyRepoProvider
    extends $FunctionalProvider<StudyRepo, StudyRepo, StudyRepo>
    with $Provider<StudyRepo> {
  StudyRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyRepoHash();

  @$internal
  @override
  $ProviderElement<StudyRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudyRepo create(Ref ref) {
    return studyRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyRepo>(value),
    );
  }
}

String _$studyRepoHash() => r'77108272ad95669ea654c69b2fe30cb6fe7a087d';

@ProviderFor(startStudySessionUseCase)
final startStudySessionUseCaseProvider = StartStudySessionUseCaseProvider._();

final class StartStudySessionUseCaseProvider
    extends
        $FunctionalProvider<
          StartStudySessionUseCase,
          StartStudySessionUseCase,
          StartStudySessionUseCase
        >
    with $Provider<StartStudySessionUseCase> {
  StartStudySessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startStudySessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startStudySessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<StartStudySessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartStudySessionUseCase create(Ref ref) {
    return startStudySessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartStudySessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartStudySessionUseCase>(value),
    );
  }
}

String _$startStudySessionUseCaseHash() =>
    r'5503af2a59baefcd92065730df23c174bc4fa820';

@ProviderFor(resumeStudySessionUseCase)
final resumeStudySessionUseCaseProvider = ResumeStudySessionUseCaseProvider._();

final class ResumeStudySessionUseCaseProvider
    extends
        $FunctionalProvider<
          ResumeStudySessionUseCase,
          ResumeStudySessionUseCase,
          ResumeStudySessionUseCase
        >
    with $Provider<ResumeStudySessionUseCase> {
  ResumeStudySessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resumeStudySessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resumeStudySessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResumeStudySessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResumeStudySessionUseCase create(Ref ref) {
    return resumeStudySessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResumeStudySessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResumeStudySessionUseCase>(value),
    );
  }
}

String _$resumeStudySessionUseCaseHash() =>
    r'ed4f5588e965300f9303602a85918fedef241131';

@ProviderFor(restartStudySessionUseCase)
final restartStudySessionUseCaseProvider =
    RestartStudySessionUseCaseProvider._();

final class RestartStudySessionUseCaseProvider
    extends
        $FunctionalProvider<
          RestartStudySessionUseCase,
          RestartStudySessionUseCase,
          RestartStudySessionUseCase
        >
    with $Provider<RestartStudySessionUseCase> {
  RestartStudySessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restartStudySessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restartStudySessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<RestartStudySessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RestartStudySessionUseCase create(Ref ref) {
    return restartStudySessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestartStudySessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestartStudySessionUseCase>(value),
    );
  }
}

String _$restartStudySessionUseCaseHash() =>
    r'78d9f40faa4fff13422a3060f1d79330ad643bb6';

@ProviderFor(answerFlashcardUseCase)
final answerFlashcardUseCaseProvider = AnswerFlashcardUseCaseProvider._();

final class AnswerFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          AnswerFlashcardUseCase,
          AnswerFlashcardUseCase,
          AnswerFlashcardUseCase
        >
    with $Provider<AnswerFlashcardUseCase> {
  AnswerFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answerFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$answerFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<AnswerFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnswerFlashcardUseCase create(Ref ref) {
    return answerFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnswerFlashcardUseCase>(value),
    );
  }
}

String _$answerFlashcardUseCaseHash() =>
    r'c6c536d8096092ab439a4e4bb40155f97fc9d40a';

@ProviderFor(answerCurrentModeBatchUseCase)
final answerCurrentModeBatchUseCaseProvider =
    AnswerCurrentModeBatchUseCaseProvider._();

final class AnswerCurrentModeBatchUseCaseProvider
    extends
        $FunctionalProvider<
          AnswerCurrentModeBatchUseCase,
          AnswerCurrentModeBatchUseCase,
          AnswerCurrentModeBatchUseCase
        >
    with $Provider<AnswerCurrentModeBatchUseCase> {
  AnswerCurrentModeBatchUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answerCurrentModeBatchUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$answerCurrentModeBatchUseCaseHash();

  @$internal
  @override
  $ProviderElement<AnswerCurrentModeBatchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnswerCurrentModeBatchUseCase create(Ref ref) {
    return answerCurrentModeBatchUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerCurrentModeBatchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnswerCurrentModeBatchUseCase>(
        value,
      ),
    );
  }
}

String _$answerCurrentModeBatchUseCaseHash() =>
    r'824f34bda1cef9e6c0ca232d4aa1beee47124abe';

@ProviderFor(answerCurrentModeItemGradesBatchUseCase)
final answerCurrentModeItemGradesBatchUseCaseProvider =
    AnswerCurrentModeItemGradesBatchUseCaseProvider._();

final class AnswerCurrentModeItemGradesBatchUseCaseProvider
    extends
        $FunctionalProvider<
          AnswerCurrentModeItemGradesBatchUseCase,
          AnswerCurrentModeItemGradesBatchUseCase,
          AnswerCurrentModeItemGradesBatchUseCase
        >
    with $Provider<AnswerCurrentModeItemGradesBatchUseCase> {
  AnswerCurrentModeItemGradesBatchUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answerCurrentModeItemGradesBatchUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$answerCurrentModeItemGradesBatchUseCaseHash();

  @$internal
  @override
  $ProviderElement<AnswerCurrentModeItemGradesBatchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnswerCurrentModeItemGradesBatchUseCase create(Ref ref) {
    return answerCurrentModeItemGradesBatchUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerCurrentModeItemGradesBatchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AnswerCurrentModeItemGradesBatchUseCase>(value),
    );
  }
}

String _$answerCurrentModeItemGradesBatchUseCaseHash() =>
    r'06b1c424658403cfaa2451dd262ca5863f9cc453';

@ProviderFor(answerCurrentMatchModeBatchUseCase)
final answerCurrentMatchModeBatchUseCaseProvider =
    AnswerCurrentMatchModeBatchUseCaseProvider._();

final class AnswerCurrentMatchModeBatchUseCaseProvider
    extends
        $FunctionalProvider<
          AnswerCurrentMatchModeBatchUseCase,
          AnswerCurrentMatchModeBatchUseCase,
          AnswerCurrentMatchModeBatchUseCase
        >
    with $Provider<AnswerCurrentMatchModeBatchUseCase> {
  AnswerCurrentMatchModeBatchUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'answerCurrentMatchModeBatchUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$answerCurrentMatchModeBatchUseCaseHash();

  @$internal
  @override
  $ProviderElement<AnswerCurrentMatchModeBatchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnswerCurrentMatchModeBatchUseCase create(Ref ref) {
    return answerCurrentMatchModeBatchUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerCurrentMatchModeBatchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnswerCurrentMatchModeBatchUseCase>(
        value,
      ),
    );
  }
}

String _$answerCurrentMatchModeBatchUseCaseHash() =>
    r'76a227499e423adfddaa5b272fadaf7ea478162f';

@ProviderFor(skipFlashcardUseCase)
final skipFlashcardUseCaseProvider = SkipFlashcardUseCaseProvider._();

final class SkipFlashcardUseCaseProvider
    extends
        $FunctionalProvider<
          SkipFlashcardUseCase,
          SkipFlashcardUseCase,
          SkipFlashcardUseCase
        >
    with $Provider<SkipFlashcardUseCase> {
  SkipFlashcardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skipFlashcardUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skipFlashcardUseCaseHash();

  @$internal
  @override
  $ProviderElement<SkipFlashcardUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SkipFlashcardUseCase create(Ref ref) {
    return skipFlashcardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SkipFlashcardUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SkipFlashcardUseCase>(value),
    );
  }
}

String _$skipFlashcardUseCaseHash() =>
    r'a06a421056277cdfd4e12877aa9c591aea3918eb';

@ProviderFor(cancelStudySessionUseCase)
final cancelStudySessionUseCaseProvider = CancelStudySessionUseCaseProvider._();

final class CancelStudySessionUseCaseProvider
    extends
        $FunctionalProvider<
          CancelStudySessionUseCase,
          CancelStudySessionUseCase,
          CancelStudySessionUseCase
        >
    with $Provider<CancelStudySessionUseCase> {
  CancelStudySessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelStudySessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelStudySessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelStudySessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelStudySessionUseCase create(Ref ref) {
    return cancelStudySessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelStudySessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelStudySessionUseCase>(value),
    );
  }
}

String _$cancelStudySessionUseCaseHash() =>
    r'a9fc78100a1540e9a16e86122cfe8f50e6117c43';

@ProviderFor(finalizeStudySessionUseCase)
final finalizeStudySessionUseCaseProvider =
    FinalizeStudySessionUseCaseProvider._();

final class FinalizeStudySessionUseCaseProvider
    extends
        $FunctionalProvider<
          FinalizeStudySessionUseCase,
          FinalizeStudySessionUseCase,
          FinalizeStudySessionUseCase
        >
    with $Provider<FinalizeStudySessionUseCase> {
  FinalizeStudySessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'finalizeStudySessionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$finalizeStudySessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<FinalizeStudySessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinalizeStudySessionUseCase create(Ref ref) {
    return finalizeStudySessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinalizeStudySessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinalizeStudySessionUseCase>(value),
    );
  }
}

String _$finalizeStudySessionUseCaseHash() =>
    r'4ac7ade731a902ec6fb1d0bfc2ec8079bfba2e3a';

@ProviderFor(retryFinalizeUseCase)
final retryFinalizeUseCaseProvider = RetryFinalizeUseCaseProvider._();

final class RetryFinalizeUseCaseProvider
    extends
        $FunctionalProvider<
          RetryFinalizeUseCase,
          RetryFinalizeUseCase,
          RetryFinalizeUseCase
        >
    with $Provider<RetryFinalizeUseCase> {
  RetryFinalizeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retryFinalizeUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retryFinalizeUseCaseHash();

  @$internal
  @override
  $ProviderElement<RetryFinalizeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RetryFinalizeUseCase create(Ref ref) {
    return retryFinalizeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetryFinalizeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetryFinalizeUseCase>(value),
    );
  }
}

String _$retryFinalizeUseCaseHash() =>
    r'f2cc2250234a3091df7189a2206de4280de980a1';
