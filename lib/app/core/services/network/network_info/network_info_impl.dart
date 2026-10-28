import 'package:accounting_software/app/core/services/network/network_info/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device has any network interface up.
///
/// This is only link availability. It deliberately does not probe a host:
/// `dart:io` lookups do not work on Web and a fixed third-party host says
/// nothing about our own server. Actual reachability is decided by the result
/// of the request itself (timeouts and connection errors are mapped by Dio).
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
