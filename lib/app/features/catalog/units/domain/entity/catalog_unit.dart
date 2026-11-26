import 'package:equatable/equatable.dart';

enum UnitType { weight, length, volume, piece }

class CatalogUnit extends Equatable {
  const CatalogUnit({required this.id, required this.name, required this.symbol, required this.type, required this.isActive, required this.usageCount});
  final int id;
  final String name;
  final String symbol;
  final UnitType type;
  final bool isActive;
  /// Null means at least one usage count could not be read.
  final int? usageCount;
  bool get canDelete => usageCount == 0;
  @override
  List<Object?> get props => [id, name, symbol, type, isActive, usageCount];
}
