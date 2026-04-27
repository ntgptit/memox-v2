// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_guards.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appRouteGuards)
final appRouteGuardsProvider = AppRouteGuardsProvider._();

final class AppRouteGuardsProvider
    extends $FunctionalProvider<AppRouteGuards, AppRouteGuards, AppRouteGuards>
    with $Provider<AppRouteGuards> {
  AppRouteGuardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouteGuardsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouteGuardsHash();

  @$internal
  @override
  $ProviderElement<AppRouteGuards> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppRouteGuards create(Ref ref) {
    return appRouteGuards(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppRouteGuards value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppRouteGuards>(value),
    );
  }
}

String _$appRouteGuardsHash() => r'12d8362cfa9dbf7e6048179e60beefd4fc40ac80';
