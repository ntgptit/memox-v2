import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../providers/progress_session_notifier.dart';
import '../widgets/progress_content.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queryState = ref.watch(progressOverviewProvider);

    return MxScaffold(
      title: l10n.progressTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<ProgressOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          onRetry: () => ref.invalidate(progressOverviewProvider),
          dataBuilder: (context, state) => ProgressContent(state: state),
        ),
      ),
    );
  }
}
