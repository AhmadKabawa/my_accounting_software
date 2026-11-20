import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/update_brand_use_case.dart';

sealed class BrandFormState extends Equatable {
  const BrandFormState();
}

final class BrandFormIdle extends BrandFormState {
  const BrandFormIdle();
  @override
  List<Object?> get props => [];
}

final class BrandFormSaving extends BrandFormState {
  const BrandFormSaving();
  @override
  List<Object?> get props => [];
}

final class BrandFormSaved extends BrandFormState {
  const BrandFormSaved(this.brand);
  final Brand brand;
  @override
  List<Object?> get props => [brand];
}

final class BrandFormFailed extends BrandFormState {
  const BrandFormFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// Owns create/edit operations only; it has no dependency on a page or widget.
class BrandFormCubit extends Cubit<BrandFormState> {
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
    if (state is BrandFormSaving) return const Left(
      ValidationFailure(),
    );
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
