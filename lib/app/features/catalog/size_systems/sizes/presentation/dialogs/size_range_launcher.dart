import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/usecase/sizes_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_range/size_range_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_range_dialog.dart';

/// Upper bound of the existing sizes read to find codes to skip. The unique
/// (group, code) constraint still rejects any duplicate the read missed.
const sizeRangeExistingLimit = 1000;

/// Opens the range generator. Returns true when sizes were created.
Future<bool?> showSizeRangeDialog(
  BuildContext context, {
  required int sizeGroupId,
}) async {
  final existing = await sl<GetSizesUseCase>()(
    CatalogSizeListQuery(
      sizeGroupId: sizeGroupId,
      status: SizeStatusFilter.all,
      pageSize: sizeRangeExistingLimit,
    ),
  );
  final sizes = existing.fold<List<CatalogSize>>(
    (_) => const [],
    (page) => page.items,
  );
  final codes = {for (final size in sizes) size.code};
  var nextOrder = 0;
  for (final size in sizes) {
    if (size.sortOrder >= nextOrder) nextOrder = size.sortOrder + 1;
  }
  if (!context.mounted) return null;
  return showAppFormDialog<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<SizeRangeCubit>(),
      child: SizeRangeDialog(
        sizeGroupId: sizeGroupId,
        existingCodes: codes,
        firstSortOrder: nextOrder,
      ),
    ),
  );
}
