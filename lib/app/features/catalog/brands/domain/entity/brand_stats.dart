import 'package:equatable/equatable.dart';

class BrandStats extends Equatable {
  const BrandStats({
    required this.total,
    required this.active,
    required this.inactive,
    this.withProducts = 0,
    this.withoutProducts = 0,
    this.mostUsedBrandId,
    this.mostUsedCount = 0,
  });

  final int total;
  final int active;
  final int inactive;
  final int withProducts;
  final int withoutProducts;
  final int? mostUsedBrandId;
  final int mostUsedCount;

  @override
  List<Object?> get props => [
    total,
    active,
    inactive,
    withProducts,
    withoutProducts,
    mostUsedBrandId,
    mostUsedCount,
  ];
}
