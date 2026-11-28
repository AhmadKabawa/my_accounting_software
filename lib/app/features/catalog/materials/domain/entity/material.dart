import 'package:equatable/equatable.dart';

enum MaterialType { natural, synthetic, blended }

class CatalogMaterial extends Equatable {
  const CatalogMaterial({
    required this.id,
    required this.name,
    required this.code,
    this.materialType,
    this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String code;
  final MaterialType? materialType;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    materialType,
    description,
    isActive,
  ];
}
