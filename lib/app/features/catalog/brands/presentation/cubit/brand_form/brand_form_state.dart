import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

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
