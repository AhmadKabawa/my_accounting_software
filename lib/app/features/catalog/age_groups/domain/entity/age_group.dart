import 'package:equatable/equatable.dart';

class AgeGroup extends Equatable {
  const AgeGroup({
    required this.id,
    required this.name,
    this.minAge,
    this.maxAge,
    required this.isActive,
    required this.sortOrder,
    required this.productCount,
  });
  final int id;
  final String name;
  final int? minAge;
  final int? maxAge;
  final bool isActive;
  final int sortOrder;

  /// Null means unknown usage; deletion must fail closed.
  final int? productCount;
  bool get canDelete => productCount == 0;
  @override
  List<Object?> get props => [
    id,
    name,
    minAge,
    maxAge,
    isActive,
    sortOrder,
    productCount,
  ];
}
