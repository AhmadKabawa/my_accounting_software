import 'package:equatable/equatable.dart';

/// A reference color from the `colors` table (not Flutter's `Color`).
class CatalogColor extends Equatable {
  const CatalogColor({
    required this.id,
    required this.name,
    required this.code,
    this.hexCode,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String code;

  /// `#RRGGBB` or `#RRGGBBAA`; null when the color has no sample value.
  final String? hexCode;
  final bool isActive;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, code, hexCode, isActive, sortOrder];
}
