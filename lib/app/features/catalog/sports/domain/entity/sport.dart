import 'package:equatable/equatable.dart';

/// A reference sport from the `sports` table.
class Sport extends Equatable {
  const Sport({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, code, description, isActive, sortOrder];
}
