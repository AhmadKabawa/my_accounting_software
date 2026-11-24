import 'package:accounting_software/app/core/foundation/image/image_policy.dart';

/// Storage bucket limits for brand logos: 5 MB, JPEG, PNG or WebP.
const brandLogoPolicy = ImagePolicy(
  maxBytes: 5 * 1024 * 1024,
  allowedMimeTypes: {'image/jpeg', 'image/png', 'image/webp'},
);
