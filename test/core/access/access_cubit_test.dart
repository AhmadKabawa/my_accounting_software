import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository(this.result);
  Either<Failure, AccessSnapshot> result;
  int calls = 0;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async {
    calls++;
    return result;
  }
}

AccessSnapshot snapshot({List<AccessBranch>? branches}) => AccessSnapshot(
  userId: 'u1',
  username: 'admin',
  email: null,
  isSuperAdmin: false,
  roles: const [AccessRole(code: 'MANAGER', name: 'مدير')],
  permissions: const {Permission('sales.view'), Permission('sales.post')},
  branches:
      branches ??
      const [
        AccessBranch(
          id: 1,
          code: 'MAIN',
          name: 'Main',
          canView: true,
          canOperate: true,
        ),
        AccessBranch(
          id: 2,
          code: 'SEC',
          name: 'Second',
          canView: true,
          canOperate: false,
        ),
      ],
  warehouses: const [],
  posTerminals: const [],
);

void main() {
  late FakeAccessRepository repository;
  late AccessCubit cubit;

  setUp(() {
    repository = FakeAccessRepository(Right(snapshot()));
    cubit = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
  });
  tearDown(() => cubit.close());

  test('starts closed and grants nothing before a successful fetch', () {
    expect(cubit.state.status, AccessStatus.initial);
    expect(cubit.can(const Permission('sales.view')), isFalse);
  });

  test('loads permissions from the server snapshot', () async {
    await cubit.load();
    expect(cubit.state.status, AccessStatus.ready);
    expect(cubit.can(const Permission('sales.view')), isTrue);
    expect(cubit.state.selectedBranchId, isNull);
  });

  test('selects the only visible branch automatically', () async {
    repository.result = Right(
      snapshot(
        branches: const [
          AccessBranch(
            id: 1,
            code: 'MAIN',
            name: 'Main',
            canView: true,
            canOperate: true,
          ),
        ],
      ),
    );
    await cubit.load();
    expect(cubit.state.selectedBranchId, 1);
  });

  test('branch selection refreshes and retains the requested branch', () async {
    await cubit.load();
    await cubit.selectBranch(2);
    expect(repository.calls, 2);
    expect(cubit.state.selectedBranchId, 2);
    expect(cubit.canOperateInSelectedBranch, isFalse);
  });

  test(
    'read-only branch keeps view permission but denies operations',
    () async {
      await cubit.load();
      await cubit.selectBranch(2);
      const permission = Permission('sales.post');
      expect(cubit.can(permission), isTrue);
      expect(cubit.canOperate(permission), isFalse);
    },
  );

  test('rejects a branch not in the server snapshot', () async {
    await cubit.load();
    await cubit.selectBranch(999);
    expect(repository.calls, 1);
    expect(cubit.state.selectedBranchId, isNull);
  });

  test('failure clears permissions and retry fetches again', () async {
    repository.result = Left(NetworkFailure());
    await cubit.load();
    expect(cubit.state.status, AccessStatus.failure);
    expect(cubit.state.snapshot, isNull);
    expect(cubit.can(const Permission('sales.view')), isFalse);

    repository.result = Right(snapshot());
    await cubit.retry();
    expect(repository.calls, 2);
    expect(cubit.can(const Permission('sales.view')), isTrue);
  });

  test('clear removes snapshot and selected branch', () async {
    await cubit.load();
    cubit.clear();
    expect(cubit.state.status, AccessStatus.initial);
    expect(cubit.state.snapshot, isNull);
    expect(cubit.can(const Permission('sales.view')), isFalse);
  });
}
