import 'package:equatable/equatable.dart';

/// A row of `size_systems` (EU, US, UK...).
class SizeSystem extends Equatable {
  const SizeSystem({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.groupCount,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  /// Null when the embedded relation count is unknown (never treated as 0).
  final int? groupCount;
  final DateTime? updatedAt;

  /// Deletion is offered only when the group count is known and zero.
  bool get canDelete => groupCount == 0;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    isActive,
    groupCount,
    updatedAt,
  ];
}
