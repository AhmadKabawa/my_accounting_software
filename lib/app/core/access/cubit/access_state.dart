part of 'access_cubit.dart';

class AccessState extends Equatable {
  final Role role;
  const AccessState(this.role);

  @override
  List<Object?> get props => [role];
}
