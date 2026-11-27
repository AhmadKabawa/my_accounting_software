import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
class FabricTypeModel {
 const FabricTypeModel({required this.id,required this.name,required this.code,required this.isActive,required this.isNamedFabric,this.fabricCategory,this.description});
 final int id;final String name;final String code;final bool isActive;final bool isNamedFabric;final FabricCategory? fabricCategory;final String? description;
 factory FabricTypeModel.fromJson(Map<String,dynamic> json){final raw=json['id'];final id=raw is int?raw:int.tryParse(raw.toString());if(id==null)throw const FormatException('Invalid fabric type id');return FabricTypeModel(id:id,name:json['name'] as String,code:json['code'] as String,isActive:json['is_active'] as bool? ?? true,isNamedFabric:json['is_named_fabric'] as bool? ?? false,fabricCategory:FabricCategory.values.where((e)=>e.name==json['fabric_category']).firstOrNull,description:json['description'] as String?);}
 CatalogFabricType toEntity()=>CatalogFabricType(id:id,name:name,code:code,isActive:isActive,isNamedFabric:isNamedFabric,fabricCategory:fabricCategory,description:description);
 Map<String,Object?> toJson()=>{'name':name,'code':code,'fabric_category':fabricCategory?.name,'is_named_fabric':isNamedFabric,'description':description,'is_active':isActive};
}