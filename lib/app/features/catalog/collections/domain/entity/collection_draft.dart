import 'package:equatable/equatable.dart';

class CollectionDraft extends Equatable {
  const CollectionDraft({
    required this.name,
    required this.code,
    this.description,
    this.image,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  final String name;
  final String code;
  final String? description;
  final String? image;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;

  @override
  List<Object?> get props => [
    name, code, description, image, startDate, endDate, isActive,
  ];
}
