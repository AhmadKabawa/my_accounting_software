import 'package:equatable/equatable.dart';
import 'care_instruction.dart';

class CareInstructionDraft extends Equatable {
  const CareInstructionDraft({
    required this.name,
    required this.code,
    required this.careType,
    this.description,
    this.isActive,
  });

  final String name;
  final String code;
  final CareType careType;
  final String? description;
  final bool? isActive;

  @override
  List<Object?> get props => [name, code, careType, description, isActive];
}
