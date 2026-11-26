import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';

class OptionSetDraft extends Equatable {
  const OptionSetDraft({required this.name, required this.code, required this.selectionType, this.isActive});
  final String name;
  final String code;
  final OptionSelectionType selectionType;
  final bool? isActive;
  @override
  List<Object?> get props => [name, code, selectionType, isActive];
}

class CatalogOptionDraft extends Equatable {
  const CatalogOptionDraft({required this.name, required this.code, required this.sortOrder, this.isActive});
  final String name;
  final String code;
  final int sortOrder;
  final bool? isActive;
  @override
  List<Object?> get props => [name, code, sortOrder, isActive];
}
