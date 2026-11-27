import 'package:equatable/equatable.dart';

class ProductTypeSizeGroupLink extends Equatable {
  const ProductTypeSizeGroupLink({
    required this.id,
    required this.sizeGroupId,
    required this.sizeGroupName,
    required this.sizeGroupCode,
    required this.isDefault,
    required this.sortOrder,
    this.sizeSystemName,
    this.genderId,
    this.genderName,
  });

  final int id;
  final int sizeGroupId;
  final String sizeGroupName;
  final String sizeGroupCode;
  final String? sizeSystemName;
  final int? genderId;
  final String? genderName;
  final bool isDefault;
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    sizeGroupId,
    sizeGroupName,
    sizeGroupCode,
    sizeSystemName,
    genderId,
    genderName,
    isDefault,
    sortOrder,
  ];
}
