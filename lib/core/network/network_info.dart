import 'dart:async';

enum NetworkStatus {
  unknown,
  online,
  offline;

  bool get isOnline => this == NetworkStatus.online;
}

abstract interface class NetworkInfo {
  NetworkStatus get currentStatus;
  bool get isOnline;

  Stream<NetworkStatus> watch();
  Future<NetworkStatus> refresh();
}
