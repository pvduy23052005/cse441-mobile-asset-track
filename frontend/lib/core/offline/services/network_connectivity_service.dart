import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkConnectivityService {
  final Connectivity _connectivity;

  NetworkConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    if (results.length == 1 && results.first == ConnectivityResult.none) {
      return false;
    }
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> checkOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (_) {
      return true;
    }
  }

  Stream<bool> get onOnlineStatusChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return _hasActiveConnection(results);
    });
  }
}

final networkConnectivityServiceProvider =
    Provider<NetworkConnectivityService>((ref) {
  return NetworkConnectivityService();
});

final networkStatusStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return service.onOnlineStatusChanged;
});

class NetworkStatusNotifier extends StateNotifier<bool> {
  final NetworkConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  NetworkStatusNotifier(this._service) : super(true) {
    _init();
  }

  void _init() async {
    final initialStatus = await _service.checkOnline();
    if (mounted) {
      state = initialStatus;
    }
    _subscription = _service.onOnlineStatusChanged.listen((isOnline) {
      if (mounted) {
        state = isOnline;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, bool>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return NetworkStatusNotifier(service);
});
