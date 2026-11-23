import 'platform_capabilities_stub.dart'
    if (dart.library.io) 'platform_capabilities_io.dart'
    as platform;

abstract final class PlatformCapabilities {
  static bool get supportsCollapsibleSidebar =>
      platform.supportsCollapsibleSidebar;

  /// Whether the HTTP adapter supports a request-body send timeout.
  ///
  /// Browser XHR/fetch adapters do not support Dio's send timeout, while
  /// dart:io adapters do. Keep this decision behind the platform boundary.
  static bool get supportsRequestSendTimeout =>
      platform.supportsRequestSendTimeout;
}
