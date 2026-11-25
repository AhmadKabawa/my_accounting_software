import 'package:equatable/equatable.dart';

class CategoryFormState extends Equatable {
  const CategoryFormState({
    this.parentId,
    this.name = '',
    this.slug = '',
    this.description = '',
    this.image = '',
    this.sortOrder = '0',
    this.slugManuallyEdited = false,
    this.saving = false,
    this.errors = const {},
  });

  final int? parentId;
  final String name;
  final String slug;
  final String description;
  final String image;
  final String sortOrder;
  final bool slugManuallyEdited;
  final bool saving;
  final Map<String, String?> errors;

  bool get isValid => errors.values.every((message) => message == null);

  String? errorFor(String field) => errors[field];

  CategoryFormState copyWith({
    int? parentId,
    bool clearParent = false,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? sortOrder,
    bool? slugManuallyEdited,
    bool? saving,
    Map<String, String?>? errors,
  }) => CategoryFormState(
    parentId: clearParent ? null : parentId ?? this.parentId,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    description: description ?? this.description,
    image: image ?? this.image,
    sortOrder: sortOrder ?? this.sortOrder,
    slugManuallyEdited: slugManuallyEdited ?? this.slugManuallyEdited,
    saving: saving ?? this.saving,
    errors: errors ?? this.errors,
  );

  @override
  List<Object?> get props => [
    parentId,
    name,
    slug,
    description,
    image,
    sortOrder,
    slugManuallyEdited,
    saving,
    errors,
  ];
}
