import 'package:equatable/equatable.dart';

class ProductTypeStats extends Equatable {
  const ProductTypeStats({
    required this.total,
    required this.active,
    required this.inactive,
    this.unused,
  });

  final int total;
  final int active;
  final int inactive;
  final int? unused;

  @override
  List<Object?> get props => [total, active, inactive, unused];
}
