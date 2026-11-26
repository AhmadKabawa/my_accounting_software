import 'package:equatable/equatable.dart';

/// A product tag from the `tags` table.
class CatalogTag extends Equatable {
  const CatalogTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
  });

  final int id;
  final String name;

  /// Lowercase ASCII identifier (`tags.slug`, UNIQUE).
  final String slug;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, slug, isActive];
}
