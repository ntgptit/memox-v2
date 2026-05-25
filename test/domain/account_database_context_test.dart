import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/account_database_context.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';

void main() {
  test('DT1 resolve: signed-out user uses guest database context', () {
    final context = AccountDatabaseContextResolver.resolve(null);

    expect(context.kind, AccountDatabaseContextKind.guest);
    expect(context.databaseName, 'memox_guest');
    expect(context.belongsTo(null), isTrue);
  });

  test('DT2 resolve: account A uses account-scoped database context', () {
    final context = AccountDatabaseContextResolver.resolve(_accountA);

    expect(context.kind, AccountDatabaseContextKind.googleAccount);
    expect(context.databaseName, 'memox_google-user-a');
    expect(context.belongsTo(_accountA), isTrue);
  });

  test('DT3 resolve: account B does not belong to account A database', () {
    final accountAContext = AccountDatabaseContextResolver.resolve(_accountA);
    final accountBContext = AccountDatabaseContextResolver.resolve(_accountB);

    expect(accountBContext.databaseName, 'memox_google-user-b');
    expect(accountBContext.belongsTo(_accountB), isTrue);
    expect(accountBContext.belongsTo(_accountA), isFalse);
    expect(accountAContext.belongsTo(_accountB), isFalse);
  });

  test(
    'DT4 resolve: signing back into account A resolves account A database',
    () {
      final firstAccountAContext = AccountDatabaseContextResolver.resolve(
        _accountA,
      );
      final accountBContext = AccountDatabaseContextResolver.resolve(_accountB);
      final secondAccountAContext = AccountDatabaseContextResolver.resolve(
        _accountA,
      );

      expect(
        accountBContext.databaseName,
        isNot(firstAccountAContext.databaseName),
      );
      expect(
        secondAccountAContext.databaseName,
        firstAccountAContext.databaseName,
      );
    },
  );

  test(
    'DT1 resolveGuestSignIn: user can attach guest data to Google account',
    () {
      final transition = AccountDatabaseContextResolver.resolveGuestSignIn(
        link: _accountA,
        choice: GuestDatabaseSignInChoice.attachGuestData,
      );

      expect(transition.context.databaseName, 'memox_google-user-a');
      expect(transition.shouldAttachGuestData, isTrue);
    },
  );

  test(
    'DT2 resolveGuestSignIn: user can create fresh Google account database',
    () {
      final transition = AccountDatabaseContextResolver.resolveGuestSignIn(
        link: _accountA,
        choice: GuestDatabaseSignInChoice.createFreshAccountDatabase,
      );

      expect(transition.context.databaseName, 'memox_google-user-a');
      expect(transition.shouldAttachGuestData, isFalse);
    },
  );
}

const _accountA = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-a',
  email: 'a@example.com',
  displayName: 'Account A',
  photoUrl: null,
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 1,
);

const _accountB = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-b',
  email: 'b@example.com',
  displayName: 'Account B',
  photoUrl: null,
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 2,
  lastSignedInAt: 2,
);
