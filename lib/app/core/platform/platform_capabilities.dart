import 'platform_capabilities_stub.dart'
    if (dart.library.io) 'platform_capabilities_io.dart'
    as platform;

/// A platform capability consumed by the network adapter.
abstract interface class RequestSendTimeoutCapability {
  bool get isSupported;
}

/// Runtime-selected implementation supplied by the composition root.
class PlatformRequestSendTimeoutCapability
    implements RequestSendTimeoutCapability {
  const PlatformRequestSendTimeoutCapability();

  @override
  bool get isSupported => platform.supportsRequestSendTimeout;
}

abstract final class PlatformCapabilities {
  static bool get supportsCollapsibleSidebar =>
      platform.supportsCollapsibleSidebar;
}
