import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';

class CareInstructionModel {
  const CareInstructionModel({required this.id, required this.name, required this.code, required this.careType, required this.isActive, this.description, this.sortOrder = 0, this.isUsed = false});
  final int id;
  final String name;
  final String code;
  final CareType careType;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final bool isUsed;

  factory CareInstructionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid care instruction id');
    final careType = CareType.tryParse(json['care_type'] as String?);
    if (careType == null) throw const FormatException('Invalid care_type');
    return CareInstructionModel(
      id: id, name: _requiredString(json, 'name'), code: _requiredString(json, 'code'),
      careType: careType, description: _optionalString(json['description']),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      sortOrder: _integer(json['sort_order']),
      isUsed: _relationCount(json['product_care_instructions']) > 0 ||
          _relationCount(json['product_type_care_instructions']) > 0,
    );
  }

  CareInstruction toEntity() => CareInstruction(
    id: id, name: name, code: code, careType: careType, description: description,
    isActive: isActive, sortOrder: sortOrder, isUsed: isUsed,
  );

  static Map<String, Object?> toWriteJson(CareInstructionDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'care_type': draft.careType.apiValue,
    'description': draft.description?.trim(),
    'is_active': draft.isActive ?? true,
  };

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid $key');
  }
  static String? _optionalString(Object? value) => value is String ? value : null;
  static int _integer(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
  static int _relationCount(Object? value) {
    if (value is List && value.isNotEmpty && value.first is Map) {
      final count = (value.first as Map)['count'];
      return count is int ? count : int.tryParse('$count') ?? 0;
    }
    return 0;
  }
}
