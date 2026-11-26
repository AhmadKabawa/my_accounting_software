import 'package:equatable/equatable.dart';

enum OptionSelectionType { single, multiple }

class CatalogOption extends Equatable {
  const CatalogOption({required this.id, required this.name, required this.code, required this.sortOrder, required this.isActive});
  final int id;
  final String name;
  final String code;
  final int sortOrder;
  final bool isActive;
  @override
  List<Object?> get props => [id, name, code, sortOrder, isActive];
}

class OptionSet extends Equatable {
  const OptionSet({required this.id, required this.name, required this.code, required this.selectionType, required this.isActive, required this.options, required this.usageCount});
  final int id;
  final String name;
  final String code;
  final OptionSelectionType selectionType;
  final bool isActive;
  final List<CatalogOption> options;
  /// Null means at least one relationship count is unknown.
  final int? usageCount;
  bool get canDelete => options.isEmpty && usageCount == 0;
  bool get canChangeSelectionType => usageCount == 0;
  @override
  List<Object?> get props => [id, name, code, selectionType, isActive, options, usageCount];
}
