/// Wrapper خفيف — يُستخدم كـ String تماماً
/// لكن يجبر المطور يمر بـ endpoints الميزة
/// (`features/<feature>/data/<feature>_endpoints.dart`) بدل نص حرفي.
extension type const AppEndpoint(String path) {
  String toStringPath() => path;
}

/// Encodes one dynamic path segment. Every dynamic part of an endpoint must go
/// through this function: percent-encoding keeps a `/`, `?` or `#` inside the
/// value from changing the structure of the path.
///
/// `.` and `..` are rejected: they are not touched by percent-encoding, so
/// `/items/..` could be normalised by a proxy or resolver into a different
/// resource.
String encodePathSegment(String value) {
  if (value == '.' || value == '..') {
    throw ArgumentError.value(
      value,
      'value',
      'A path segment cannot be "." or ".."',
    );
  }
  return Uri.encodeComponent(value);
}
