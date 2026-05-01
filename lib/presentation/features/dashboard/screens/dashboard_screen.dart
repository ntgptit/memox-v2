import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import '../widgets/dashboard_content.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryState = ref.watch(dashboardOverviewProvider);

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<DashboardOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          onRetry: () => ref.invalidate(dashboardOverviewProvider),
          dataBuilder: (context, state) => DashboardContent(state: state),
        ),
      ),
    );
  }
}
