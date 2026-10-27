import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';

void main() {
  group('ApiResult.toEither', () {
    test('success becomes Right with the same data', () {
      const ApiResult<int> result = ApiSuccess(7);

      expect(result.toEither(), const Right<Failure, int>(7));
    });

    test('failure becomes Left with a mapped Failure', () {
      final ApiResult<int> result = ApiFailure(ApiException.unauthorized());

      final either = result.toEither();

      expect(either.isLeft(), isTrue);
      expect(either.fold((f) => f, (_) => null), isA<Failure>());
    });
  });

  group('ApiResult.toEitherAsync', () {
    test('runs the async step on success and wraps its value', () async {
      const ApiResult<int> result = ApiSuccess(2);
      var calls = 0;

      final either = await result.toEitherAsync((n) async {
        calls++;
        return n * 10;
      });

      expect(either, const Right<Failure, int>(20));
      expect(calls, 1);
    });

    test('does not run the async step on failure', () async {
      final ApiResult<int> result = ApiFailure(ApiException.timeout());
      var calls = 0;

      final either = await result.toEitherAsync((n) async {
        calls++;
        return n;
      });

      expect(either.isLeft(), isTrue);
      expect(calls, 0);
    });
  });
}
