import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_reload_service.dart';
import '../../domain/entities/drive_sync_models.dart';
import '../di/providers.dart';

abstract interface class DriveSyncRuntimeEffects {
  Future<void> apply(DriveSyncRestoreEffect effect);
}

final class RiverpodDriveSyncRuntimeEffects implements DriveSyncRuntimeEffects {
  const RiverpodDriveSyncRuntimeEffects({
    required Ref ref,
    required AppReloadService appReloadService,
  }) : _ref = ref,
       _appReloadService = appReloadService;

  final Ref _ref;
  final AppReloadService _appReloadService;

  @override
  Future<void> apply(DriveSyncRestoreEffect effect) async {
    switch (effect) {
      case DriveSyncRestoreEffect.none:
        return;
      case DriveSyncRestoreEffect.refreshDatabaseProvider:
        _ref.invalidate(appDatabaseProvider);
      case DriveSyncRestoreEffect.reloadApp:
        _appReloadService.reload();
    }
  }
}
