import 'package:equatable/equatable.dart';

class ColorStats extends Equatable {
  const ColorStats({
    required this.total,
    required this.active,
    required this.inactive,
    this.used = 0,
    this.unused = 0,
  });

  final int total;
  final int active;
  final int inactive;
  final int used;
  final int unused;

  @override
  List<Object?> get props => [total, active, inactive, used, unused];
}
