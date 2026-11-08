import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/domain/repository/home_repository.dart';
import 'package:accounting_software/app/features/home/domain/usecase/get_home_summary_usecase.dart';
import 'package:accounting_software/app/features/home/data/repository/sample_home_repository.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/model/quick_action.dart';
import 'package:accounting_software/app/features/home/presentation/support/home_format.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingRepository implements HomeRepository {
  @override
  Future<Either<Failure, HomeSummary>> getSummary() async =>
      Left(NetworkFailure());
}

void main() {
  late FlashMessages flash;
  late List<FlashMessage> shown;

  setUp(() {
    flash = FlashMessages();
    shown = [];
    flash.listen(shown.add);
  });

  blocTest<HomeCubit, HomeState>(
    'load emits loading then the summary from the repository',
    build: () => HomeCubit(
      getSummary: const GetHomeSummaryUseCase(SampleHomeRepository()),
      flash: flash,
    ),
    act: (c) => c.load(),
    expect: () => [
      isA<HomeLoading>(),
      isA<HomeLoaded>().having((s) => s.summary.isSample, 'isSample', isTrue),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'load emits HomeFailed with the failure message key',
    build: () => HomeCubit(
      getSummary: GetHomeSummaryUseCase(_FailingRepository()),
      flash: flash,
    ),
    act: (c) => c.load(),
    expect: () => [
      isA<HomeLoading>(),
      HomeFailed(NetworkFailure().messageKey),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'openAction tells the user the module is not available yet',
    build: () => HomeCubit(
      getSummary: const GetHomeSummaryUseCase(SampleHomeRepository()),
      flash: flash,
    ),
    act: (c) => c.openAction(QuickAction.newSale),
    expect: () => <HomeState>[],
    verify: (_) {
      expect(shown, hasLength(1));
      expect(shown.single.key, HomeKeys.comingSoon);
    },
  );

  group('formatting', () {
    test('formatAmount groups thousands and keeps the sign', () {
      expect(formatAmount(0), '0');
      expect(formatAmount(999), '999');
      expect(formatAmount(48250), '48,250');
      expect(formatAmount(1234567), '1,234,567');
      expect(formatAmount(-1500), '-1,500');
    });

    test('greetingFor switches at noon', () {
      expect(greetingFor(DateTime(2026, 1, 1, 9)), HomeKeys.greetingMorning);
      expect(greetingFor(DateTime(2026, 1, 1, 12)), HomeKeys.greetingEvening);
    });
  });
}
