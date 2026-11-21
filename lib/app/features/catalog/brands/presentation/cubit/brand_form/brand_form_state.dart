import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

enum BrandFormStatus { idle, saving, saved, failure }

class BrandFormState extends Equatable {
  const BrandFormState({
    this.status = BrandFormStatus.idle,
    this.brand,
    this.failure,
  });

  final BrandFormStatus status;
  final Brand? brand;
  final Failure? failure;

  bool get isSaving => status == BrandFormStatus.saving;

  @override
  List<Object?> get props => [status, brand, failure];
}
