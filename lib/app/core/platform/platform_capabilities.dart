import 'platform_capabilities_stub.dart'
    if (dart.library.io) 'platform_capabilities_io.dart'
    as platform;

abstract final class PlatformCapabilities {
  static bool get supportsCollapsibleSidebar =>
      platform.supportsCollapsibleSidebar;
}
