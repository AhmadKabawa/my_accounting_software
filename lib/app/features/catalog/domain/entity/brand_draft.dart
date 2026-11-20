import 'package:equatable/equatable.dart';

class BrandDraft extends Equatable {
  const BrandDraft({
    required this.name,
    required this.slug,
    this.logo,
    this.description,
  });

  final String name;
  final String slug;
  final String? logo;
  final String? description;

  @override
  List<Object?> get props => [name, slug, logo, description];
}
