import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/presentation/access_status_gate.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

class _Repository implements AccessRepository {
  Either<Failure, AccessSnapshot> result = Left(NetworkFailure());

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => result;
}

AccessSnapshot _snapshot() => const AccessSnapshot(
  userId: 'u1',
  username: 'admin',
  email: null,
  isSuperAdmin: false,
  roles: [],
  permissions: {},
  branches: [],
  warehouses: [],
  posTerminals: [],
);

void main() {
  testWidgets(
    'blocks shell during loading and after failure; retry can unlock it',
    (tester) async {
      final repository = _Repository();
      final access = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
      addTearDown(access.close);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });

      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          assetLoader: MyDartLoader(allKeys),
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: BlocProvider.value(
                value: access,
                child: const AccessStatusGate(child: Text('protected shell')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('protected shell'), findsNothing);

      await access.load();
      await tester.pump();
      expect(find.text('protected shell'), findsNothing);

      repository.result = Right(_snapshot());
      await access.retry();
      await tester.pump();
      expect(find.text('protected shell'), findsOneWidget);
    },
  );
}
