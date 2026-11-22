import 'package:equatable/equatable.dart';

class BrandDraft extends Equatable {
  const BrandDraft({
    required this.name,
    required this.slug,
    this.logo,
    this.description,
    this.isActive,
  });

  final String name;
  final String slug;
  final String? logo;
  final String? description;

  /// Sent only when set (a new brand can start deactivated); null leaves the
  /// stored status untouched.
  final bool? isActive;

  @override
  List<Object?> get props => [name, slug, logo, description, isActive];
}
