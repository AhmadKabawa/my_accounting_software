import 'package:equatable/equatable.dart';
import 'material.dart';

class MaterialDraft extends Equatable {
  const MaterialDraft({
    required this.name,
    required this.code,
    this.materialType,
    this.description,
    this.isActive,
  });

  final String name;
  final String code;
  final MaterialType? materialType;
  final String? description;
  final bool? isActive;

  @override
  List<Object?> get props => [name, code, materialType, description, isActive];
}
