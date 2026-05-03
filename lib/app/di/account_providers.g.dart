// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(googleOAuthConfig)
final googleOAuthConfigProvider = GoogleOAuthConfigProvider._();

final class GoogleOAuthConfigProvider
    extends
        $FunctionalProvider<
          GoogleOAuthConfig,
          GoogleOAuthConfig,
          GoogleOAuthConfig
        >
    with $Provider<GoogleOAuthConfig> {
  GoogleOAuthConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleOAuthConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleOAuthConfigHash();

  @$internal
  @override
  $ProviderElement<GoogleOAuthConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleOAuthConfig create(Ref ref) {
    return googleOAuthConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleOAuthConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleOAuthConfig>(value),
    );
  }
}

String _$googleOAuthConfigHash() => r'709ddd0e2f2340f2f2f9bf51240c375ab802971d';

@ProviderFor(accountSharedPreferences)
final accountSharedPreferencesProvider = AccountSharedPreferencesProvider._();

final class AccountSharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  AccountSharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return accountSharedPreferences(ref);
  }
}

String _$accountSharedPreferencesHash() =>
    r'95f90469269f9fd9c99f88c0f37504cde734d062';

@ProviderFor(cloudAccountRepository)
final cloudAccountRepositoryProvider = CloudAccountRepositoryProvider._();

final class CloudAccountRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CloudAccountRepository>,
          CloudAccountRepository,
          FutureOr<CloudAccountRepository>
        >
    with
        $FutureModifier<CloudAccountRepository>,
        $FutureProvider<CloudAccountRepository> {
  CloudAccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudAccountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudAccountRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<CloudAccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CloudAccountRepository> create(Ref ref) {
    return cloudAccountRepository(ref);
  }
}

String _$cloudAccountRepositoryHash() =>
    r'd6c94d9459384b32ad2b0183ca1e59a4a5ba223a';

@ProviderFor(googleAccountAuthService)
final googleAccountAuthServiceProvider = GoogleAccountAuthServiceProvider._();

final class GoogleAccountAuthServiceProvider
    extends
        $FunctionalProvider<
          GoogleAccountAuthService,
          GoogleAccountAuthService,
          GoogleAccountAuthService
        >
    with $Provider<GoogleAccountAuthService> {
  GoogleAccountAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleAccountAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleAccountAuthServiceHash();

  @$internal
  @override
  $ProviderElement<GoogleAccountAuthService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleAccountAuthService create(Ref ref) {
    return googleAccountAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleAccountAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleAccountAuthService>(value),
    );
  }
}

String _$googleAccountAuthServiceHash() =>
    r'8c3d2ef42a77ee877bed11f363a593a4ba83f31f';

@ProviderFor(loadCloudAccountLinkUseCase)
final loadCloudAccountLinkUseCaseProvider =
    LoadCloudAccountLinkUseCaseProvider._();

final class LoadCloudAccountLinkUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoadCloudAccountLinkUseCase>,
          LoadCloudAccountLinkUseCase,
          FutureOr<LoadCloudAccountLinkUseCase>
        >
    with
        $FutureModifier<LoadCloudAccountLinkUseCase>,
        $FutureProvider<LoadCloudAccountLinkUseCase> {
  LoadCloudAccountLinkUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadCloudAccountLinkUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadCloudAccountLinkUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<LoadCloudAccountLinkUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoadCloudAccountLinkUseCase> create(Ref ref) {
    return loadCloudAccountLinkUseCase(ref);
  }
}

String _$loadCloudAccountLinkUseCaseHash() =>
    r'fda616d08c7ef6095b26c055e5322faa5ae7fa10';

@ProviderFor(restoreGoogleAccountUseCase)
final restoreGoogleAccountUseCaseProvider =
    RestoreGoogleAccountUseCaseProvider._();

final class RestoreGoogleAccountUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestoreGoogleAccountUseCase>,
          RestoreGoogleAccountUseCase,
          FutureOr<RestoreGoogleAccountUseCase>
        >
    with
        $FutureModifier<RestoreGoogleAccountUseCase>,
        $FutureProvider<RestoreGoogleAccountUseCase> {
  RestoreGoogleAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreGoogleAccountUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreGoogleAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<RestoreGoogleAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RestoreGoogleAccountUseCase> create(Ref ref) {
    return restoreGoogleAccountUseCase(ref);
  }
}

String _$restoreGoogleAccountUseCaseHash() =>
    r'e33a10c836dc9fef5f94f4968501c866de1b94ce';

@ProviderFor(signInGoogleAccountUseCase)
final signInGoogleAccountUseCaseProvider =
    SignInGoogleAccountUseCaseProvider._();

final class SignInGoogleAccountUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SignInGoogleAccountUseCase>,
          SignInGoogleAccountUseCase,
          FutureOr<SignInGoogleAccountUseCase>
        >
    with
        $FutureModifier<SignInGoogleAccountUseCase>,
        $FutureProvider<SignInGoogleAccountUseCase> {
  SignInGoogleAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInGoogleAccountUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInGoogleAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SignInGoogleAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SignInGoogleAccountUseCase> create(Ref ref) {
    return signInGoogleAccountUseCase(ref);
  }
}

String _$signInGoogleAccountUseCaseHash() =>
    r'6ad13cde782299ac5f3bb0d0cff3e97f2e2a82c8';

@ProviderFor(authorizeGoogleDriveUseCase)
final authorizeGoogleDriveUseCaseProvider =
    AuthorizeGoogleDriveUseCaseProvider._();

final class AuthorizeGoogleDriveUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthorizeGoogleDriveUseCase>,
          AuthorizeGoogleDriveUseCase,
          FutureOr<AuthorizeGoogleDriveUseCase>
        >
    with
        $FutureModifier<AuthorizeGoogleDriveUseCase>,
        $FutureProvider<AuthorizeGoogleDriveUseCase> {
  AuthorizeGoogleDriveUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authorizeGoogleDriveUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authorizeGoogleDriveUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<AuthorizeGoogleDriveUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuthorizeGoogleDriveUseCase> create(Ref ref) {
    return authorizeGoogleDriveUseCase(ref);
  }
}

String _$authorizeGoogleDriveUseCaseHash() =>
    r'a094415a83839856fafd273f29bdeb52a804e926';

@ProviderFor(signOutGoogleAccountUseCase)
final signOutGoogleAccountUseCaseProvider =
    SignOutGoogleAccountUseCaseProvider._();

final class SignOutGoogleAccountUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SignOutGoogleAccountUseCase>,
          SignOutGoogleAccountUseCase,
          FutureOr<SignOutGoogleAccountUseCase>
        >
    with
        $FutureModifier<SignOutGoogleAccountUseCase>,
        $FutureProvider<SignOutGoogleAccountUseCase> {
  SignOutGoogleAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutGoogleAccountUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutGoogleAccountUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SignOutGoogleAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SignOutGoogleAccountUseCase> create(Ref ref) {
    return signOutGoogleAccountUseCase(ref);
  }
}

String _$signOutGoogleAccountUseCaseHash() =>
    r'957d3d08be8cc193527ba62c9300745697914bf9';

@ProviderFor(persistGoogleAccountAuthResultUseCase)
final persistGoogleAccountAuthResultUseCaseProvider =
    PersistGoogleAccountAuthResultUseCaseProvider._();

final class PersistGoogleAccountAuthResultUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersistGoogleAccountAuthResultUseCase>,
          PersistGoogleAccountAuthResultUseCase,
          FutureOr<PersistGoogleAccountAuthResultUseCase>
        >
    with
        $FutureModifier<PersistGoogleAccountAuthResultUseCase>,
        $FutureProvider<PersistGoogleAccountAuthResultUseCase> {
  PersistGoogleAccountAuthResultUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'persistGoogleAccountAuthResultUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$persistGoogleAccountAuthResultUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<PersistGoogleAccountAuthResultUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PersistGoogleAccountAuthResultUseCase> create(Ref ref) {
    return persistGoogleAccountAuthResultUseCase(ref);
  }
}

String _$persistGoogleAccountAuthResultUseCaseHash() =>
    r'8c8945a7d20d14272fe9f5fcfd818149a88db223';

@ProviderFor(getDriveAppDataAccessTokenUseCase)
final getDriveAppDataAccessTokenUseCaseProvider =
    GetDriveAppDataAccessTokenUseCaseProvider._();

final class GetDriveAppDataAccessTokenUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetDriveAppDataAccessTokenUseCase>,
          GetDriveAppDataAccessTokenUseCase,
          FutureOr<GetDriveAppDataAccessTokenUseCase>
        >
    with
        $FutureModifier<GetDriveAppDataAccessTokenUseCase>,
        $FutureProvider<GetDriveAppDataAccessTokenUseCase> {
  GetDriveAppDataAccessTokenUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDriveAppDataAccessTokenUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getDriveAppDataAccessTokenUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetDriveAppDataAccessTokenUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetDriveAppDataAccessTokenUseCase> create(Ref ref) {
    return getDriveAppDataAccessTokenUseCase(ref);
  }
}

String _$getDriveAppDataAccessTokenUseCaseHash() =>
    r'3f7d38bd33b4f56cb34bd16cff290ccc9ff9c13e';
