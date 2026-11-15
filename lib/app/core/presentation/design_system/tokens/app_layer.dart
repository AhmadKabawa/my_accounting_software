/// Stacking order (z-index) of the app's layers. Use the token instead of a
/// number wherever layers are ordered (for example `Stack` overlays).
enum AppLayer {
  content(0),
  stickyHeader(10),
  navigation(20),
  dropdown(30),
  sidePanel(40),
  modal(50),
  snackbar(60),
  tooltip(70),
  loadingOverlay(80);

  const AppLayer(this.zIndex);

  final int zIndex;

  /// True when this layer is drawn above [other].
  bool isAbove(AppLayer other) => zIndex > other.zIndex;
}
