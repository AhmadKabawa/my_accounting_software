import 'package:equatable/equatable.dart';

class AgeGroupDraft extends Equatable {
  const AgeGroupDraft({
    required this.name,
    this.minAge,
    this.maxAge,
    this.sortOrder = 0,
    this.isActive,
  });
  final String name;
  final int? minAge;
  final int? maxAge;
  final int sortOrder;

  /// Null preserves the stored value on PATCH.
  final bool? isActive;
  @override
  List<Object?> get props => [name, minAge, maxAge, sortOrder, isActive];
}
