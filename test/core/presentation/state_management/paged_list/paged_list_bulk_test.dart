import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
void main() {
  test('bulk success reloads once and clears selection', () async {
    final flashes = FlashMessages();
    final cubit = TestPagedCubit(flashMessages: flashes);
    cubit.selection.selectPage([1, 2]);
    final bulk = cubit.bulkItems([1, 2], (_) async => const Right(unit));
    await Future<void>.delayed(Duration.zero);
    cubit.requests.single.complete(Right(TestPagedPage([3])));
    final result = await bulk;
    expect(result.successCount, 2);
    expect(result.failureCount, 0);
    expect(cubit.selection.count, 0);
    expect(cubit.requestedQueries, hasLength(1));
    expect(flashes.pendingCount, 1);
    await cubit.close();
  });
  test('bulk partial failure retains failed item and reason', () async {
    final flashes = FlashMessages();
    final cubit = TestPagedCubit(flashMessages: flashes);
    cubit.selection.selectPage([1, 2, 3]);
    final bulk = cubit.bulkItems([1, 2, 3], (item) async =>
        item == 2 ? const Left(TestPagedFailure()) : const Right(unit));
    await Future<void>.delayed(Duration.zero);
    cubit.requests.single.complete(Right(TestPagedPage([4])));
    final result = await bulk;
    expect(result.successCount, 2);
    expect(result.failureCount, 1);
    expect(result.failures.single.item, 2);
    expect(result.failures.single.reason, isA<TestPagedFailure>());
    expect(cubit.selection.count, 0);
    expect(flashes.pendingCount, 0);
    await cubit.close();
  });
  test('bulk complete failure still reloads once and reports zero successes', () async {
    final flashes = FlashMessages();
    final cubit = TestPagedCubit(flashMessages: flashes);
    final bulk = cubit.bulkItems([1, 2], (_) async => const Left(TestPagedFailure()));
    await Future<void>.delayed(Duration.zero);
    cubit.requests.single.complete(Right(TestPagedPage([])));
    final result = await bulk;
    expect(result.successCount, 0);
    expect(result.failureCount, 2);
    expect(cubit.requestedQueries, hasLength(1));
    expect(flashes.pendingCount, 0);
    await cubit.close();
  });
  test('selection clears immediately when search query changes', () async {
    final cubit = TestPagedCubit();
    cubit.selection.selectPage([1, 2]);
    cubit.searchChanged('new');
    expect(cubit.selection.count, 0);
    await cubit.close();
  });
}
