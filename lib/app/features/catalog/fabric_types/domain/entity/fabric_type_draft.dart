import 'package:equatable/equatable.dart';
import 'fabric_type.dart';

class FabricTypeDraft extends Equatable {
  const FabricTypeDraft({
    required this.name,
    required this.code,
    this.fabricCategory,
    this.description,
    this.isNamedFabric = false,
    this.isActive,
  });

  final String name;
  final String code;
  final FabricCategory? fabricCategory;
  final String? description;
  final bool isNamedFabric;
  final bool? isActive;

  @override
  List<Object?> get props => [
    name,
    code,
    fabricCategory,
    description,
    isNamedFabric,
    isActive,
  ];
}
