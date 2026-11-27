import 'package:equatable/equatable.dart';
class CatalogColor extends Equatable {
  const CatalogColor({required this.id,required this.name,required this.code,this.hexCode,required this.isActive,required this.sortOrder,this.createdAt});
  final int id; final String name; final String code; final String? hexCode; final bool isActive; final int sortOrder; final DateTime? createdAt;
  @override List<Object?> get props=>[id,name,code,hexCode,isActive,sortOrder,createdAt];
}
