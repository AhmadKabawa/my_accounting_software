import 'package:accounting_software/app/core/services/network/network_info/network_info_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this.results);
  final List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

Future<bool> check(List<ConnectivityResult> results) =>
    NetworkInfoImpl(_FakeConnectivity(results)).isConnected;

void main() {
  test('none means offline', () async {
    expect(await check([ConnectivityResult.none]), isFalse);
  });

  test('an empty result means offline', () async {
    expect(await check([]), isFalse);
  });

  test('any real interface means online', () async {
    expect(await check([ConnectivityResult.wifi]), isTrue);
    expect(
      await check([ConnectivityResult.none, ConnectivityResult.mobile]),
      isTrue,
    );
  });
}
