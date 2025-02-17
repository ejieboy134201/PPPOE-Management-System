import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_checkConnectivity);
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _checkConnectivity(result);
  }

  bool _checkConnectivity(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    _controller.add(isConnected);
    return isConnected;
  }

  void dispose() {
    _controller.close();
  }
}
