import 'package:equatable/equatable.dart';

class SportStats extends Equatable {
  const SportStats({
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;

  @override
  List<Object?> get props => [total, active, inactive];
}
