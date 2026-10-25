import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

// ==================== 10. UpdateProfileUseCase ====================
class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    return repository.updateProfile(
      fullName: params.fullName,
      avatarUrl: params.avatarUrl,
      phone: params.phone,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final String? avatarUrl;
  final String? phone;

  const UpdateProfileParams({this.fullName, this.avatarUrl, this.phone});

  @override
  List<Object?> get props => [fullName, avatarUrl, phone];
}
