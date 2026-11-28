import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/models/care_instruction_model.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';

void main() {
  test('write payload contains only approved fields and maps dry_cleaning', () {
    const draft = CareInstructionDraft(
      name: '  Wash cold  ', code: ' WASH ', careType: CareType.dryCleaning,
    );
    expect(CareInstructionModel.toWriteJson(draft), {
      'name': 'Wash cold',
      'code': 'WASH',
      'care_type': 'dry_cleaning',
      'description': null,
      'is_active': true,
    });
  });

  test('parses sort order and known relation usage', () {
    final model = CareInstructionModel.fromJson({
      'id': 3, 'name': 'Wash cold', 'code': 'WASH',
      'care_type': 'washing', 'is_active': true, 'sort_order': 4,
      'product_care_instructions': [{'count': 0}],
      'product_type_care_instructions': [{'count': 2}],
    });
    expect(model.careType, CareType.washing);
    expect(model.sortOrder, 4);
    expect(model.toEntity().isUsed, isTrue);
  });
}
