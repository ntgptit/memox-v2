import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/google_oauth_config.dart';
import '../../data/services/google_sign_in_account_auth_service.dart';
import '../../data/settings/cloud_account_store.dart';
import '../../domain/repositories/cloud_account_repository.dart';
import '../../domain/services/google_account_auth_service.dart';
import '../../domain/usecases/cloud_account_usecases.dart';
import 'content/content_core_providers.dart';
import 'providers.dart';

part 'account_providers.g.dart';

@riverpod
GoogleOAuthConfig googleOAuthConfig(Ref ref) =>
    ref.watch(appConfigProvider).googleOAuthConfig;

@riverpod
Future<CloudAccountRepository> cloudAccountRepository(Ref ref) async =>
    CloudAccountStore(await ref.watch(sharedPreferencesProvider.future));

@Riverpod(keepAlive: true)
GoogleAccountAuthService googleAccountAuthService(Ref ref) {
  final service = GoogleSignInAccountAuthService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
}

@riverpod
Future<LoadCloudAccountLinkUseCase> loadCloudAccountLinkUseCase(
  Ref ref,
) async => LoadCloudAccountLinkUseCase(
  await ref.watch(cloudAccountRepositoryProvider.future),
);

@riverpod
Future<RestoreGoogleAccountUseCase> restoreGoogleAccountUseCase(
  Ref ref,
) async => RestoreGoogleAccountUseCase(
  repository: await ref.watch(cloudAccountRepositoryProvider.future),
  authService: ref.watch(googleAccountAuthServiceProvider),
  config: ref.watch(googleOAuthConfigProvider),
  clock: ref.watch(clockProvider),
);

@riverpod
Future<SignInGoogleAccountUseCase> signInGoogleAccountUseCase(Ref ref) async =>
    SignInGoogleAccountUseCase(
      repository: await ref.watch(cloudAccountRepositoryProvider.future),
      authService: ref.watch(googleAccountAuthServiceProvider),
      config: ref.watch(googleOAuthConfigProvider),
      clock: ref.watch(clockProvider),
    );

@riverpod
Future<AuthorizeGoogleDriveUseCase> authorizeGoogleDriveUseCase(
  Ref ref,
) async => AuthorizeGoogleDriveUseCase(
  repository: await ref.watch(cloudAccountRepositoryProvider.future),
  authService: ref.watch(googleAccountAuthServiceProvider),
  config: ref.watch(googleOAuthConfigProvider),
  clock: ref.watch(clockProvider),
);

@riverpod
Future<SignOutGoogleAccountUseCase> signOutGoogleAccountUseCase(
  Ref ref,
) async => SignOutGoogleAccountUseCase(
  repository: await ref.watch(cloudAccountRepositoryProvider.future),
  authService: ref.watch(googleAccountAuthServiceProvider),
);

@riverpod
Future<PersistGoogleAccountAuthResultUseCase>
persistGoogleAccountAuthResultUseCase(Ref ref) async =>
    PersistGoogleAccountAuthResultUseCase(
      repository: await ref.watch(cloudAccountRepositoryProvider.future),
      clock: ref.watch(clockProvider),
    );

@riverpod
Future<GetDriveAppDataAccessTokenUseCase> getDriveAppDataAccessTokenUseCase(
  Ref ref,
) async => GetDriveAppDataAccessTokenUseCase(
  repository: await ref.watch(cloudAccountRepositoryProvider.future),
  authService: ref.watch(googleAccountAuthServiceProvider),
  config: ref.watch(googleOAuthConfigProvider),
);
