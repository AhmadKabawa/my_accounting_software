import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_state.dart';

/// Owns create/edit operations only; it has no dependency on a page or widget.
class BrandFormCubit extends BaseCubit<BrandFormState, void> {
  BrandFormCubit({
    required CreateBrandUseCase createBrand,
    required UpdateBrandUseCase updateBrand,
  }) : _createBrand = createBrand,
       _updateBrand = updateBrand,
       super(const BrandFormState());

  final CreateBrandUseCase _createBrand;
  final UpdateBrandUseCase _updateBrand;

  Future<Either<Failure, Brand>> save({
    required BrandDraft draft,
    int? id,
  }) async {
    if (state.isSaving) return const Left(ValidationFailure());
    emit(const BrandFormState(status: BrandFormStatus.saving));
    final response = id == null
        ? await _createBrand(draft)
        : await _updateBrand(UpdateBrandParams(id: id, draft: draft));
    if (isClosed) return response;
    response.fold(
      (failure) => emit(BrandFormState(
        status: BrandFormStatus.failure,
        failure: failure,
      )),
      (brand) => emit(BrandFormState(
        status: BrandFormStatus.saved,
        brand: brand,
      )),
    );
    return response;
  }

  void reset() => emit(const BrandFormState());
}
