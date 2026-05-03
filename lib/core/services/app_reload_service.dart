import 'app_reload_service_stub.dart'
    if (dart.library.html) 'app_reload_service_web.dart';

abstract interface class AppReloadService {
  void reload();
}

AppReloadService createAppReloadService() {
  return createPlatformAppReloadService();
}
