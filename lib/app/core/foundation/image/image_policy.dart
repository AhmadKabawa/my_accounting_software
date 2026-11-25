/// Server-aligned rules for an image upload.
class ImagePolicy {
  const ImagePolicy({required this.maxBytes, required this.allowedMimeTypes});

  final int maxBytes;
  final Set<String> allowedMimeTypes;
}
