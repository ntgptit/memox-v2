import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_list_scaffold.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/dashboard_skeleton.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const MxListScaffold(
    contentWidth: MxContentWidth.reading,
    body: DashboardOverviewSection(),
  );
}

class DashboardOverviewSection extends ConsumerWidget {
  const DashboardOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryState = ref.watch(dashboardOverviewProvider);

    return MxRetainedAsyncState<DashboardOverviewState>(
      data: queryState.value,
      isLoading: queryState.isLoading,
      error: queryState.hasError ? queryState.error : null,
      stackTrace: queryState.hasError ? queryState.stackTrace : null,
      onRetry: () => ref.invalidate(dashboardOverviewProvider),
      skeletonBuilder: (_) => const DashboardSkeleton(),
      dataBuilder: (context, state) => DashboardContent(state: state),
    );
  }
}
