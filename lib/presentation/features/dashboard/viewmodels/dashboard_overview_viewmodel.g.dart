// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_overview_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardOverview)
final dashboardOverviewProvider = DashboardOverviewProvider._();

final class DashboardOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardOverviewState>,
          DashboardOverviewState,
          FutureOr<DashboardOverviewState>
        >
    with
        $FutureModifier<DashboardOverviewState>,
        $FutureProvider<DashboardOverviewState> {
  DashboardOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardOverviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardOverviewHash();

  @$internal
  @override
  $FutureProviderElement<DashboardOverviewState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardOverviewState> create(Ref ref) {
    return dashboardOverview(ref);
  }
}

String _$dashboardOverviewHash() => r'7652cb6af41739894396230a9b608bb063742217';
