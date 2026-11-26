import 'package:equatable/equatable.dart';

class ProductTypeStats extends Equatable {
  const ProductTypeStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.withoutProducts,
  });

  final int total;
  final int active;
  final int inactive;

  /// Null means at least one product usage count was unavailable.
  final int? withoutProducts;

  @override
  List<Object?> get props => [total, active, inactive, withoutProducts];
}
