import 'package:equatable/equatable.dart';

/// Lightweight read-only view of `genders` owned by this feature (the genders
/// screen belongs to another module): id, name and activity only.
class GenderOption extends Equatable {
  const GenderOption({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final int id;
  final String name;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, isActive];
}
