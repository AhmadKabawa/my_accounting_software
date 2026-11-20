import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.description,
    required this.isActive,
    this.productCount,
  });

  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String? description;
  final bool isActive;
  final int? productCount;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    logo,
    description,
    isActive,
    productCount,
  ];
}
