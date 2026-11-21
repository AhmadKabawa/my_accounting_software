import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

const sampleColor = CatalogColor(
  id: 7,
  name: 'Navy',
  code: 'NAVY',
  hexCode: '#1E3A8A',
  isActive: true,
  sortOrder: 2,
);

class FakeColorsRepository implements ColorsRepository {
  final List<ColorListQuery> queries = [];
  final List<CatalogColorDraft> created = [];
  final List<(int, CatalogColorDraft)> updated = [];
  final List<(int, bool)> statusUpdates = [];
  Future<Either<Failure, PaginatedResult<CatalogColor>>> Function(
    ColorListQuery,
  )?
  onGetColors;
  Either<Failure, CatalogColor>? saveResult;
  Either<Failure, Unit> statusResult = const Right(unit);

  @override
  Future<Either<Failure, PaginatedResult<CatalogColor>>> getColors(
    ColorListQuery query,
  ) {
    queries.add(query);
    final handler = onGetColors;
    if (handler != null) return handler(query);
    return Future.value(Right(page()));
  }

  static PaginatedResult<CatalogColor> page({
    List<CatalogColor> items = const [sampleColor],
  }) => PaginatedResult<CatalogColor>(
    items: items,
    totalCount: items.length,
    currentPage: 1,
    totalPages: items.isEmpty ? 0 : 1,
  );

  @override
  Future<Either<Failure, CatalogColor>> createColor(CatalogColorDraft draft) {
    created.add(draft);
    return Future.value(saveResult ?? const Right(sampleColor));
  }

  @override
  Future<Either<Failure, CatalogColor>> updateColor({
    required int id,
    required CatalogColorDraft draft,
  }) {
    updated.add((id, draft));
    return Future.value(saveResult ?? const Right(sampleColor));
  }

  @override
  Future<Either<Failure, Unit>> setColorActive({
    required int id,
    required bool isActive,
  }) {
    statusUpdates.add((id, isActive));
    return Future.value(statusResult);
  }
}
