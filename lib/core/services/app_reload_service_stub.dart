import 'app_reload_service.dart';

AppReloadService createPlatformAppReloadService() {
  return const _NoopAppReloadService();
}

final class _NoopAppReloadService implements AppReloadService {
  const _NoopAppReloadService();

  @override
  void reload() {}
}
