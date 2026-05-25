import '../../core/constants/app_constants.dart';
import 'cloud_account_link.dart';

enum AccountDatabaseContextKind { guest, googleAccount }

enum GuestDatabaseSignInChoice { attachGuestData, createFreshAccountDatabase }

final class AccountDatabaseContext {
  const AccountDatabaseContext._({
    required this.kind,
    required this.databaseName,
    this.accountSubjectId,
  });

  factory AccountDatabaseContext.guest() => const AccountDatabaseContext._(
    kind: AccountDatabaseContextKind.guest,
    databaseName: '${AppConstants.localDatabaseName}_guest',
  );

  factory AccountDatabaseContext.googleAccount(String subjectId) {
    final normalizedSubjectId = _normalizeSubjectId(subjectId);
    return AccountDatabaseContext._(
      kind: AccountDatabaseContextKind.googleAccount,
      databaseName: '${AppConstants.localDatabaseName}_$normalizedSubjectId',
      accountSubjectId: subjectId,
    );
  }

  final AccountDatabaseContextKind kind;
  final String databaseName;
  final String? accountSubjectId;

  bool belongsTo(CloudAccountLink? link) {
    if (link == null) {
      return kind == AccountDatabaseContextKind.guest;
    }
    return kind == AccountDatabaseContextKind.googleAccount &&
        accountSubjectId == link.subjectId;
  }
}

final class AccountDatabaseTransition {
  const AccountDatabaseTransition({
    required this.context,
    required this.shouldAttachGuestData,
  });

  final AccountDatabaseContext context;
  final bool shouldAttachGuestData;
}

abstract final class AccountDatabaseContextResolver {
  const AccountDatabaseContextResolver._();

  static AccountDatabaseContext resolve(CloudAccountLink? link) {
    if (link == null) {
      return AccountDatabaseContext.guest();
    }
    return AccountDatabaseContext.googleAccount(link.subjectId);
  }

  static AccountDatabaseTransition resolveGuestSignIn({
    required CloudAccountLink link,
    required GuestDatabaseSignInChoice choice,
  }) => AccountDatabaseTransition(
    context: AccountDatabaseContext.googleAccount(link.subjectId),
    shouldAttachGuestData: choice == GuestDatabaseSignInChoice.attachGuestData,
  );
}

String _normalizeSubjectId(String subjectId) => _validateNormalizedSubjectId(
  subjectId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_'),
);

String _validateNormalizedSubjectId(String normalized) => normalized.isEmpty
    ? throw ArgumentError.value(normalized, 'subjectId', 'must not be empty')
    : normalized;
