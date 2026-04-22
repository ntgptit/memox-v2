import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'network_info.dart';

typedef NetworkStatusProbe = Future<NetworkStatus> Function();

/// App-owned connectivity facade.
///
/// This service intentionally stays infrastructure-agnostic for now.
/// A future platform adapter can feed it through [updateStatus] or
/// [refresh] without changing call sites or providers.
class ConnectivityService implements NetworkInfo {
  ConnectivityService({
    NetworkStatus initialStatus = NetworkStatus.unknown,
    NetworkStatusProbe? probe,
    Duration debounce = AppConstants.connectivityDebounce,
  })  : _currentStatus = initialStatus,
        _probe = probe,
        _debounce = debounce {
    _controller = StreamController<NetworkStatus>.broadcast(
      onListen: _emitCurrentStatus,
    );
  }

  late final StreamController<NetworkStatus> _controller;
  final NetworkStatusProbe? _probe;
  final Duration _debounce;

  NetworkStatus _currentStatus;
  Timer? _pendingEmission;

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  bool get isOnline => _currentStatus.isOnline;

  @override
  Stream<NetworkStatus> watch() => _controller.stream.distinct();

  @override
  Future<NetworkStatus> refresh() async {
    final probe = _probe;
    if (probe == null) {
      return _currentStatus;
    }

    final next = await probe();
    _applyStatus(next);
    return _currentStatus;
  }

  void updateStatus(NetworkStatus next) {
    _scheduleEmission(next);
  }

  @mustCallSuper
  void dispose() {
    _pendingEmission?.cancel();
    _controller.close();
  }

  void _scheduleEmission(NetworkStatus next) {
    if (_currentStatus == next && _pendingEmission == null) {
      return;
    }

    _pendingEmission?.cancel();
    _pendingEmission = Timer(_debounce, () {
      _applyStatus(next);
    });
  }

  void _applyStatus(NetworkStatus next) {
    _pendingEmission?.cancel();
    _pendingEmission = null;
    if (_currentStatus == next) {
      return;
    }

    _currentStatus = next;
    _emitCurrentStatus();
  }

  void _emitCurrentStatus() {
    if (_controller.isClosed) {
      return;
    }

    _controller.add(_currentStatus);
  }
}
