import 'package:equatable/equatable.dart';

class ProductTypeOptionSetLink extends Equatable {
  const ProductTypeOptionSetLink({
    required this.optionSetId,
    required this.name,
    required this.code,
    required this.isRequired,
    required this.sortOrder,
  });

  final int optionSetId;
  final String name;
  final String code;
  final bool isRequired;
  final int sortOrder;

  @override
  List<Object?> get props => [optionSetId, name, code, isRequired, sortOrder];
}
