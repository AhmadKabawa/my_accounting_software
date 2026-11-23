import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';

void main() {
  group('PlatformCapabilities', () {
    test('native adapters support Dio request send timeouts', () {
      // flutter test runs on the Dart VM, which selects the dart:io adapter.
      expect(const PlatformRequestSendTimeoutCapability().isSupported, isTrue);
    });

    test('collapsible sidebar is a layout capability', () {
      expect(PlatformCapabilities.supportsCollapsibleSidebar, isTrue);
    });
  });
}
