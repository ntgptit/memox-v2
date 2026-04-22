import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import 'mx_error_state.dart';

/// Preset error state for offline/no-network situations.
class MxOfflineState extends StatelessWidget {
  const MxOfflineState({this.title, this.message, this.onRetry, super.key});

  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxErrorState(
      icon: Icons.wifi_off_outlined,
      title: title ?? l10n.sharedOfflineTitle,
      message: message ?? l10n.sharedOfflineMessage,
      retryLabel: l10n.sharedTryAgain,
      onRetry: onRetry,
    );
  }
}
