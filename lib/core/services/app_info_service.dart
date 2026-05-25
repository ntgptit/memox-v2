import 'package:package_info_plus/package_info_plus.dart';

/// Snapshot of the running app's identity at start-up time.
///
/// Embedded in Drive backup manifests so cross-device restore UX can show the
/// user which app version produced a backup.
final class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  /// Semver-ish from `pubspec.yaml`'s `version:` line (before the `+`).
  final String version;

  /// Build number from `pubspec.yaml`'s `version:` line (after the `+`),
  /// possibly empty on platforms that don't expose it.
  final String buildNumber;

  /// Human-readable label such as `1.0.0+1`. Falls back to just [version]
  /// when [buildNumber] is empty.
  String get fullLabel =>
      buildNumber.isEmpty ? version : '$version+$buildNumber';
}

/// Loads [AppInfo] from the platform. Wrapped behind an interface so tests
/// can stub a deterministic version without needing the plugin's binding.
abstract interface class AppInfoService {
  Future<AppInfo> load();
}

final class PackageInfoAppInfoService implements AppInfoService {
  const PackageInfoAppInfoService();

  @override
  Future<AppInfo> load() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(version: info.version, buildNumber: info.buildNumber);
  }
}
