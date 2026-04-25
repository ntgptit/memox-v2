import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/network/connectivity_service.dart';
import 'package:memox/core/network/network_info.dart';

void main() {
  group('ConnectivityService', () {
    test('DT1 onRefreshRetry: refresh applies the probed status immediately', () async {
      final service = ConnectivityService(
        initialStatus: NetworkStatus.offline,
        debounce: Duration.zero,
        probe: () async => NetworkStatus.online,
      );
      addTearDown(service.dispose);

      final next = await service.refresh();

      expect(next, NetworkStatus.online);
      expect(service.currentStatus, NetworkStatus.online);
      expect(service.isOnline, isTrue);
    });

    test('DT1 onUpdate: watch emits the current status and debounced updates', () async {
      final service = ConnectivityService(
        initialStatus: NetworkStatus.offline,
        debounce: const Duration(milliseconds: 1),
      );
      addTearDown(service.dispose);

      final emitted = <NetworkStatus>[];
      final subscription = service.watch().listen(emitted.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      service.updateStatus(NetworkStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(emitted, <NetworkStatus>[
        NetworkStatus.offline,
        NetworkStatus.online,
      ]);
    });
  });
}
