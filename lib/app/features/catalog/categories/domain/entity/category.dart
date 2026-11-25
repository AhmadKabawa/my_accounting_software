import 'package:equatable/equatable.dart';

/// A product category from the `categories` table (a self-referencing tree).
class Category extends Equatable {
  const Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.sortOrder,
    required this.isActive,
    this.productCount,
  });

  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;

  /// Null means the PostgREST embedded usage count was unavailable.
  /// Unknown usage must never be interpreted as zero for delete eligibility.
  final int? productCount;

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    slug,
    description,
    image,
    sortOrder,
    isActive,
    productCount,
  ];
}
