import 'package:equatable/equatable.dart';

class ProductTypeStats extends Equatable {
  const ProductTypeStats({
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
