import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/google_oauth_config.dart';
import '../../data/services/google_sign_in_account_auth_service.dart';
import '../../data/settings/cloud_account_store.dart';
import '../../domain/repositories/cloud_account_repository.dart';
import '../../domain/services/google_account_auth_service.dart';
import '../../domain/usecases/cloud_account_usecases.dart';
import 'content_providers.dart';
import 'providers.dart';

part 'account_providers.g.dart';

@Riverpod(keepAlive: true)
GoogleOAuthConfig googleOAuthConfig(Ref ref) {
  return ref.watch(appConfigProvider).googleOAuthConfig;
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> accountSharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<CloudAccountRepository> cloudAccountRepository(Ref ref) async {
  return CloudAccountStore(
    await ref.watch(accountSharedPreferencesProvider.future),
  );
}

@Riverpod(keepAlive: true)
GoogleAccountAuthService googleAccountAuthService(Ref ref) {
  final service = GoogleSignInAccountAuthService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
}

@Riverpod(keepAlive: true)
Future<LoadCloudAccountLinkUseCase> loadCloudAccountLinkUseCase(Ref ref) async {
  return LoadCloudAccountLinkUseCase(
    await ref.watch(cloudAccountRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<RestoreGoogleAccountUseCase> restoreGoogleAccountUseCase(Ref ref) async {
  return RestoreGoogleAccountUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
    config: ref.watch(googleOAuthConfigProvider),
    clock: ref.watch(clockProvider),
  );
}

@Riverpod(keepAlive: true)
Future<SignInGoogleAccountUseCase> signInGoogleAccountUseCase(Ref ref) async {
  return SignInGoogleAccountUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
    config: ref.watch(googleOAuthConfigProvider),
    clock: ref.watch(clockProvider),
  );
}

@Riverpod(keepAlive: true)
Future<AuthorizeGoogleDriveUseCase> authorizeGoogleDriveUseCase(Ref ref) async {
  return AuthorizeGoogleDriveUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
    config: ref.watch(googleOAuthConfigProvider),
    clock: ref.watch(clockProvider),
  );
}

@Riverpod(keepAlive: true)
Future<SignOutGoogleAccountUseCase> signOutGoogleAccountUseCase(Ref ref) async {
  return SignOutGoogleAccountUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
  );
}

@Riverpod(keepAlive: true)
Future<PersistGoogleAccountAuthResultUseCase>
persistGoogleAccountAuthResultUseCase(Ref ref) async {
  return PersistGoogleAccountAuthResultUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    clock: ref.watch(clockProvider),
  );
}

@Riverpod(keepAlive: true)
Future<GetDriveAppDataAccessTokenUseCase> getDriveAppDataAccessTokenUseCase(
  Ref ref,
) async {
  return GetDriveAppDataAccessTokenUseCase(
    repository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
    config: ref.watch(googleOAuthConfigProvider),
  );
}
