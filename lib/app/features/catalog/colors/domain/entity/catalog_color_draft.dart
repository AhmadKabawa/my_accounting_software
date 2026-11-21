import 'package:equatable/equatable.dart';

class CatalogColorDraft extends Equatable {
  const CatalogColorDraft({
    required this.name,
    required this.code,
    this.hexCode,
    this.sortOrder = 0,
  });

  final String name;
  final String code;
  final String? hexCode;
  final int sortOrder;

  @override
  List<Object?> get props => [name, code, hexCode, sortOrder];
}
