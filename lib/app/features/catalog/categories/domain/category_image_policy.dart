import 'package:accounting_software/app/core/foundation/image/image_policy.dart';

/// Category image rules: 5 MB, JPEG, PNG or WebP.
const categoryImagePolicy = ImagePolicy(
  maxBytes: 5 * 1024 * 1024,
  allowedMimeTypes: {'image/jpeg', 'image/png', 'image/webp'},
);
