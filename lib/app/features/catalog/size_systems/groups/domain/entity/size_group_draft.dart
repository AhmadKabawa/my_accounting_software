import 'package:equatable/equatable.dart';

class SizeGroupDraft extends Equatable {
  const SizeGroupDraft({
    required this.sizeSystemId,
    this.genderId,
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
  });

  /// Fixed by the route context, never edited in the form.
  final int sizeSystemId;
  final int? genderId;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [
    sizeSystemId,
    genderId,
    name,
    code,
    description,
    isActive,
  ];
}
