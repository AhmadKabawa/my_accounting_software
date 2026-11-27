import 'package:equatable/equatable.dart';

class GenderDraft extends Equatable {
  const GenderDraft({
    required this.name,
    required this.code,
    this.sortOrder = 0,
    this.isActive,
  });

  final String name;
  final String code;
  final int sortOrder;

  /// Null preserves the current server value on PATCH.
  final bool? isActive;

  @override
  List<Object?> get props => [name, code, sortOrder, isActive];
}
