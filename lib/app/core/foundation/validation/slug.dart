/// ASCII slug rules shared by catalog entities (brands, categories...).
///
/// Pure Dart, so domain code can use it. Only lowercase English letters and
/// digits are kept; no transliteration is performed, so an Arabic name yields
/// an empty slug that the user must type by hand.
abstract final class Slug {
  /// Lowercase alphanumeric groups joined by single hyphens.
  static final pattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  static final _nonSlug = RegExp(r'[^a-z0-9]+');
  static final _edgeHyphen = RegExp(r'^-|-$');

  static bool isValid(String? value) =>
      value != null && pattern.hasMatch(value);

  /// Converts free text to a slug: runs of other characters become one hyphen
  /// and leading/trailing hyphens are dropped.
  static String from(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(_nonSlug, '-')
      .replaceAll(_edgeHyphen, '');
}
