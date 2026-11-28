import 'package:equatable/equatable.dart';

class CatalogCollection extends Equatable {
  const CatalogCollection({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.description,
    this.image,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String? description;
  final String? image;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    isActive,
    description,
    image,
    startDate,
    endDate,
  ];
}
