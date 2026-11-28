import 'package:equatable/equatable.dart';

enum CareType {
  washing,
  drying,
  ironing,
  bleaching,
  dryCleaning;

  static CareType? tryParse(String? value) => switch (value) {
    'washing' => CareType.washing,
    'drying' => CareType.drying,
    'ironing' => CareType.ironing,
    'bleaching' => CareType.bleaching,
    'dry_cleaning' => CareType.dryCleaning,
    _ => null,
  };

  String get apiValue => this == CareType.dryCleaning ? 'dry_cleaning' : name;
}

class CareInstruction extends Equatable {
  const CareInstruction({
    required this.id,
    required this.name,
    required this.code,
    required this.careType,
    required this.isActive,
    this.description,
    this.sortOrder = 0,
    this.isUsed = false,
  });

  final int id;
  final String name;
  final String code;
  final CareType careType;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final bool isUsed;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    careType,
    description,
    isActive,
    sortOrder,
    isUsed,
  ];
}
