import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../core/errors/failures.dart';

/// Maps a tag-validation [AppFailure] code to a localized, user-facing message.
/// Shared by the flashcard editor tag input and the tag management screen so
/// the same validation surfaces identical copy everywhere.
String tagValidationMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (failure.code) {
      FailureCodes.tagEmpty => l10n.flashcardsTagErrorEmpty,
      FailureCodes.tagInvalidCharacter => l10n.flashcardsTagErrorComma,
      FailureCodes.tagTooLong => l10n.flashcardsTagErrorTooLong,
      _ => failure.message,
    };
