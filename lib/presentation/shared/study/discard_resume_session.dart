import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../features/progress/providers/progress_session_notifier.dart';
import '../dialogs/mx_confirmation_dialog.dart';
import '../feedback/mx_snackbar.dart';

/// Shared Resume-Discard flow for study-entry resume banners (Dashboard,
/// Folder Detail, Flashcard List).
///
/// Confirms via the danger confirmation dialog, then cancels the existing
/// paused session through the established use-case path
/// ([progressSessionActionControllerProvider] → CancelStudySessionUseCase),
/// which bumps the study-session revision so every resume banner that watches
/// [studySessionDataRevisionProvider] refreshes and the banner disappears.
///
/// Contract guarantees:
///   * Never creates a new session — discard only cancels the paused one.
///   * Cancelling the confirmation (or dismissing the barrier) does nothing.
///   * Failure surfaces a localized, safe error (no raw exception leaks).
///
/// Returns `true` only when the session was discarded.
Future<bool> confirmAndDiscardResumeSession({
  required BuildContext context,
  required WidgetRef ref,
  required String sessionId,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await MxConfirmationDialog.show(
    context: context,
    title: l10n.dashboardDiscardSessionTitle,
    message: l10n.dashboardDiscardSessionMessage,
    confirmLabel: l10n.dashboardDiscardAction,
    icon: Icons.delete_outline_rounded,
    tone: MxConfirmationTone.danger,
  );
  if (!context.mounted) return false;
  if (!confirmed) return false;

  final success = await ref
      .read(progressSessionActionControllerProvider.notifier)
      .cancel(sessionId);
  if (!context.mounted) return success;
  if (!success) {
    MxSnackbar.error(context, l10n.dashboardSessionDiscardFailedMessage);
    return false;
  }
  MxSnackbar.success(context, l10n.dashboardSessionDiscardedMessage);
  return true;
}
