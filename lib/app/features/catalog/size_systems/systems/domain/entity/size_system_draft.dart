import 'package:equatable/equatable.dart';

class SizeSystemDraft extends Equatable {
  const SizeSystemDraft({
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
  });

  final String name;
  final String code;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [name, code, description, isActive];
}
