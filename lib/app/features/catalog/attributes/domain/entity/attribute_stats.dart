import 'package:equatable/equatable.dart';
class AttributeStats extends Equatable {
  const AttributeStats({required this.all, required this.active, required this.inactive, required this.filterable});
  final int all;
  final int active;
  final int inactive;
  final int filterable;
  @override
  List<Object?> get props => [all, active, inactive, filterable];
}