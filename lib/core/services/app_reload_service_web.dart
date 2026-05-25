import 'package:web/web.dart' as web;

import 'app_reload_service.dart';

AppReloadService createPlatformAppReloadService() =>
    const _WebAppReloadService();

final class _WebAppReloadService implements AppReloadService {
  const _WebAppReloadService();

  @override
  void reload() {
    web.window.location.reload();
  }
}
