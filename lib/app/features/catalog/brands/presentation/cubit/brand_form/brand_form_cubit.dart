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
       super(const BrandFormIdle());

  final CreateBrandUseCase _createBrand;
  final UpdateBrandUseCase _updateBrand;

  Future<Either<Failure, Brand>> save({
    required BrandDraft draft,
    int? id,
  }) async {
    if (state is BrandFormSaving) return const Left(ValidationFailure());
    emit(const BrandFormSaving());
    final result = id == null
        ? await _createBrand(draft)
        : await _updateBrand(UpdateBrandParams(id: id, draft: draft));
    if (isClosed) return result;
    result.fold(
      (failure) => emit(BrandFormFailed(failure)),
      (brand) => emit(BrandFormSaved(brand)),
    );
    return result;
  }

  void reset() => emit(const BrandFormIdle());
}
