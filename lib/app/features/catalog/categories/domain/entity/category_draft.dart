import 'package:equatable/equatable.dart';

/// The editable fields of a category, as sent to the server.
class CategoryDraft extends Equatable {
  const CategoryDraft({
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;

  @override
  List<Object?> get props => [
    parentId,
    name,
    slug,
    description,
    image,
    sortOrder,
    isActive,
  ];
}
