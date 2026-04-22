import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_shell_notifier.g.dart';

/// Currently selected tab index in the root [AppShell].
///
/// Lives at app level (not inside a feature) because tab state is
/// cross-feature and has to survive when features rebuild.
///
/// Index contract (see `AppShell._destinations`):
/// 0 Home · 1 Library · 2 Progress · 3 Settings.
@riverpod
class AppShellNotifier extends _$AppShellNotifier {
  static const int _defaultIndex = 1;

  @override
  int build() => _defaultIndex;

  void select(int index) {
    if (index == state) return;
    state = index;
  }
}
