import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';

class UnitDraft extends Equatable {
  const UnitDraft({
    required this.name,
    required this.symbol,
    required this.type,
    this.isActive,
  });
  final String name;
  final String symbol;
  final UnitType type;
  final bool? isActive;
  @override
  List<Object?> get props => [name, symbol, type, isActive];
}
