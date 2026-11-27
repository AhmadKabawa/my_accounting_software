import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_unit_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_option_set_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';
import '../support/fake_attributes_repository.dart';

class _Failure extends Failure {
  const _Failure() : super(messageKey: AttributesKeys.loadError);
}

void main() {
  test('one lookup failure does not hide the other lookup choices', () async {
    final repository = FakeAttributesRepository()
      ..unitChoicesResult = const Left(_Failure());
    final cubit = AttributeLookupsCubit(
      getUnits: GetAttributeUnitChoicesUseCase(repository),
      getOptionSets: GetAttributeOptionSetChoicesUseCase(repository),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.loading, isFalse);
    expect(cubit.state.unitFailure, isA<_Failure>());
    expect(cubit.state.optionSetFailure, isNull);
    expect(cubit.state.optionSets, hasLength(1));
  });
}
