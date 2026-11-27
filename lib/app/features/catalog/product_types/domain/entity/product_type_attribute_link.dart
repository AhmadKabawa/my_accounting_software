import 'package:equatable/equatable.dart';

class ProductTypeAttributeLink extends Equatable {
  const ProductTypeAttributeLink({
    required this.attributeId,
    required this.name,
    required this.code,
    required this.dataType,
    required this.isRequired,
    required this.sortOrder,
  });

  final int attributeId;
  final String name;
  final String code;
  final String dataType;
  final bool isRequired;
  final int sortOrder;

  @override
  List<Object?> get props => [
    attributeId,
    name,
    code,
    dataType,
    isRequired,
    sortOrder,
  ];
}
