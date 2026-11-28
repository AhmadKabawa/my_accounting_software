import 'package:accounting_software/app/core/foundation/image/image_policy.dart';

/// Collection image rules match the CAT-07 specification.
const collectionImagePolicy = ImagePolicy(
  maxBytes: 5 * 1024 * 1024,
  allowedMimeTypes: {'image/jpeg', 'image/png', 'image/webp'},
);
