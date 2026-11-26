import 'package:equatable/equatable.dart';

class ProductTypeDraft extends Equatable {
  const ProductTypeDraft({
    required this.name,
    required this.code,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String name;
  final String code;
  final String? description;
  final int sortOrder;
  final bool isActive;

  @override
  List<Object?> get props => [name, code, description, sortOrder, isActive];
}
