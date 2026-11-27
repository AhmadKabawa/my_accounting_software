import 'package:equatable/equatable.dart';

class CatalogTagDraft extends Equatable {
  const CatalogTagDraft({
    required this.name,
    required this.slug,
    this.isActive,
  });

  final String name;
  final String slug;
  final bool? isActive;

  @override
  List<Object?> get props => [name, slug, isActive];
}
