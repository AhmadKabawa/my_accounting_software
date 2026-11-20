class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.description,
    required this.isActive,
  });

  final String id;
  final String name;
  final String slug;
  final String? logo;
  final String? description;
  final bool isActive;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    logo: json['logo'] as String?,
    description: json['description'] as String?,
    isActive: json['is_active'] as bool? ?? true,
  );
}
