import 'app_reload_service.dart';

AppReloadService createPlatformAppReloadService() =>
    const _NoopAppReloadService();

final class _NoopAppReloadService implements AppReloadService {
  const _NoopAppReloadService();

  @override
  void reload() {}
}
