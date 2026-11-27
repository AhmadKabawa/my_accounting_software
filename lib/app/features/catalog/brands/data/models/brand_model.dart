import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
class BrandModel {
  const BrandModel({required this.id, required this.name, required this.slug, this.logo, this.description, required this.isActive, this.productCount, this.createdAt, this.updatedAt});
  final int id; final String name; final String slug; final String? logo; final String? description; final bool isActive; final int? productCount; final DateTime? createdAt; final DateTime? updatedAt;
  factory BrandModel.fromJson(Map<String,dynamic> json) {
    final rawId=json['id']; final id=rawId is int?rawId:int.tryParse(rawId.toString());
    if(id==null) throw const FormatException('Invalid brand id');
    return BrandModel(id:id,name:json['name'] as String,slug:json['slug'] as String,logo:json['logo'] as String?,description:json['description'] as String?,isActive:json['is_active'] as bool???true,productCount:_readProductCount(json['products']),createdAt:DateTime.tryParse(json['created_at']?.toString()??''),updatedAt:DateTime.tryParse(json['updated_at']?.toString()??''));
  }
  static int? _readProductCount(dynamic value) {
    if(value==null)return null; if(value is num)return value.toInt();
    if(value is Map<String,dynamic>){final c=value['count'];return c is num?c.toInt():null;}
    if(value is List){if(value.isEmpty)return 0;final first=value.first;if(first is Map<String,dynamic>){final c=first['count'];return c is num?c.toInt():null;}}
    return null;
  }
  Brand toEntity()=>Brand(id:id,name:name,slug:slug,logo:logo,description:description,isActive:isActive,productCount:productCount,createdAt:createdAt,updatedAt:updatedAt);
}
