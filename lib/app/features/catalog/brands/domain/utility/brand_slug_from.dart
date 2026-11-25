import 'package:accounting_software/app/core/foundation/validation/slug.dart';

/// Converts a brand name to the supported ASCII slug format.
///
/// Delegates to the shared [Slug.from]; kept so brand code and tests keep one
/// stable name.
String brandSlugFrom(String value) => Slug.from(value);
