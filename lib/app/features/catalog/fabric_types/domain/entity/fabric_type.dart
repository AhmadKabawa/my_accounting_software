import 'package:equatable/equatable.dart';

enum FabricCategory { knit, woven, fleece }

class CatalogFabricType extends Equatable {
  const CatalogFabricType({
    required this.id,
    required this.name,
    required this.code,
    this.fabricCategory,
    this.description,
    this.isNamedFabric = false,
    required this.isActive,
  });

  final int id;
  final String name;
  final String code;
  final FabricCategory? fabricCategory;
  final String? description;
  final bool isNamedFabric;
  final bool isActive;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    fabricCategory,
    description,
    isNamedFabric,
    isActive,
  ];
}
