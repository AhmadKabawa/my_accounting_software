import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

typedef BrandsListState = PagedListState<Brand, BrandListQuery>;
typedef BrandsListStatus = PagedListStatus;
