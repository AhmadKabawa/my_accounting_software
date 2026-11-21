/// Converts a brand name to the supported ASCII slug format.
///
/// Only lowercase English letters and digits are retained; runs of other
/// characters become a single hyphen. No transliteration is performed.
String brandSlugFrom(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');
