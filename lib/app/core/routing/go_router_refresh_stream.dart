// go_router_refresh_stream.dart
import 'dart:async';

import 'package:flutter/material.dart';
class GoRouterRefreshStream extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];

  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subscriptions.add(
        stream.listen(
          (_) => notifyListeners(),
          onError: (_) => notifyListeners(),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}