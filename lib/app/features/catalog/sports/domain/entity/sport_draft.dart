import 'package:equatable/equatable.dart';

class SportDraft extends Equatable {
  const SportDraft({
    required this.name,
    required this.code,
    this.description,
    this.sortOrder = 0,
    this.isActive,
  });

  final String name;
  final String code;
  final String? description;
  final int sortOrder;
  final bool? isActive;

  @override
  List<Object?> get props => [name, code, description, sortOrder, isActive];
}
