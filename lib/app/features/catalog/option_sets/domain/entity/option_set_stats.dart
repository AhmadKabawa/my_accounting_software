import 'package:equatable/equatable.dart';

class OptionSetStats extends Equatable {
  const OptionSetStats({required this.total, required this.active, required this.inactive});
  final int total;
  final int active;
  final int inactive;
  @override
  List<Object?> get props => [total, active, inactive];
}
