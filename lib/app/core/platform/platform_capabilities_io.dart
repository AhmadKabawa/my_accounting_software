// Collapsing the sidebar needs no platform feature: any device that reaches
// the desktop layout (a window, a browser) can do it. Kept as a capability so
// a platform that cannot (or should not) can still turn it off in one place.
bool get supportsCollapsibleSidebar => true;
