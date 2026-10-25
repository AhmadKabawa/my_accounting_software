import 'dart:async';
import 'dart:io';

import 'package:accounting_software/app/core/services/network/network_info/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Simple implementation of NetworkInfo
/// In production, you can use connectivity_plus package

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  bool? _lastStatus;
  DateTime? _lastCheck;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // كاش لمدة 5 ثواني
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < const Duration(seconds: 5)) {
      return _lastStatus ?? false;
    }

    final connectivityResult = await connectivity.checkConnectivity();

    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none ||
        connectivityResult.isEmpty) {
      _updateCache(false);
      return false;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      final isOnline = result.isNotEmpty && result.first.rawAddress.isNotEmpty;

      _updateCache(isOnline);
      return isOnline;
    } catch (_) {
      _updateCache(false);
      return false;
    }
  }

  void _updateCache(bool status) {
    _lastStatus = status;
    _lastCheck = DateTime.now();
  }
}
