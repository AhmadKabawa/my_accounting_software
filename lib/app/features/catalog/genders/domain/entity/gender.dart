import 'package:equatable/equatable.dart';

class Gender extends Equatable {
  const Gender({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.sortOrder,
    required this.sizeGroupCount,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final int sortOrder;

  /// Null means the relationship count could not be established; deletion is
  /// intentionally disabled in that case.
  final int? sizeGroupCount;

  bool get canDelete => sizeGroupCount == 0;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    isActive,
    sortOrder,
    sizeGroupCount,
  ];
}
