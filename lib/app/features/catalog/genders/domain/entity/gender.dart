import 'package:equatable/equatable.dart';
class Gender extends Equatable {
 const Gender({required this.id,required this.name,required this.code,required this.isActive,required this.sortOrder});
 final int id; final String name; final String code; final bool isActive; final int sortOrder;
 @override List<Object?> get props=>[id,name,code,isActive,sortOrder];
}