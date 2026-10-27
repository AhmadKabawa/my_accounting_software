import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Replays [statusCodes] in order (the last one repeats) and records every
/// request that reaches the "network".
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.statusCodes, {this.body = '{}'});

  final List<int> statusCodes;
  final String body;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = requests.length < statusCodes.length
        ? requests.length
        : statusCodes.length - 1;
    requests.add(options);
    return ResponseBody.fromString(
      body,
      statusCodes[index],
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
