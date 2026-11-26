import 'package:equatable/equatable.dart';

class ProductTypeLinkOption extends Equatable {
  const ProductTypeLinkOption({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.detail,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String? detail;

  @override
  List<Object?> get props => [id, name, code, isActive, detail];
}
