import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_type_links_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';

class ProductTypeDetailsCubit extends BaseCubit<ProductTypeDetailsState, void> {
  ProductTypeDetailsCubit({
    required ProductTypeLinksRepository repository,
    required ProductTypesRepository productTypesRepository,
  }) : _repository = repository,
       _productTypesRepository = productTypesRepository,
       super(const ProductTypeDetailsInitial());

  final ProductTypeLinksRepository _repository;
  final ProductTypesRepository _productTypesRepository;
  int _requestVersion = 0;
  int? _currentProductTypeId;
  int? _publishedProductCount;

  Future<void> load(int productTypeId) async {
    if (_currentProductTypeId != productTypeId) {
      _currentProductTypeId = productTypeId;
      _publishedProductCount = null;
    }
    final version = ++_requestVersion;
    emit(const ProductTypeDetailsLoading());
    final productType = await _productTypesRepository.getById(productTypeId);
    if (isClosed || version != _requestVersion) return;
    final typeFailure = productType.fold((failure) => failure, (_) => null);
    if (typeFailure != null) {
      emit(ProductTypeDetailsFailed(typeFailure));
      return;
    }
    final sizeGroups = await _repository.getSizeGroupLinks(productTypeId);
    final attributes = await _repository.getAttributeLinks(productTypeId);
    final optionSets = await _repository.getOptionSetLinks(productTypeId);
    final sizeOptions = await _repository.getSizeGroupOptions();
    final attributeOptions = await _repository.getAttributeOptions();
    final optionOptions = await _repository.getOptionSetOptions();
    final genders = await _repository.getGenderOptions();
    final publishedCount = await _repository.getPublishedProductCount(
      productTypeId,
    );
    if (isClosed || version != _requestVersion) return;

    final failure =
        _failureFrom(sizeGroups) ??
        _failureFrom(attributes) ??
        _failureFrom(optionSets) ??
        _failureFrom(sizeOptions) ??
        _failureFrom(attributeOptions) ??
        _failureFrom(optionOptions) ??
        _failureFrom(genders);
    if (failure != null) {
      emit(ProductTypeDetailsFailed(failure));
      return;
    }

    _publishedProductCount = publishedCount.fold((_) => null, (count) => count);
    emit(
      ProductTypeDetailsLoaded(
        productType: productType.getOrElse(
          () => throw StateError('Unreachable'),
        ),
        productTypeId: productTypeId,
        sizeGroups: sizeGroups.getOrElse(() => const []),
        attributes: attributes.getOrElse(() => const []),
        optionSets: optionSets.getOrElse(() => const []),
        sizeGroupOptions: sizeOptions.getOrElse(() => const []),
        attributeOptions: attributeOptions.getOrElse(() => const []),
        optionSetOptions: optionOptions.getOrElse(() => const []),
        genderOptions: genders.getOrElse(() => const []),
        publishedProductCount: publishedCount.fold(
          (_) => null,
          (count) => count,
        ),
      ),
    );
  }

  Failure? _failureFrom<T>(Either<Failure, T> result) =>
      result.fold((failure) => failure, (_) => null);

  Future<void> addSizeGroup({
    required int sizeGroupId,
    int? genderId,
    bool isDefault = false,
    int sortOrder = 0,
  }) async {
    final current = _loaded;
    if (current == null) return;
    if (isDefault &&
        current.sizeGroups.any(
          (item) => item.isDefault && item.genderId == genderId,
        )) {
      emit(
        current.copyWith(
          updateFailure: const ProductTypeDefaultSizeGroupConflictFailure(),
        ),
      );
      return;
    }
    await _mutate(
      'size-group-add',
      () => _repository.createSizeGroupLink({
        'product_type_id': current.productTypeId,
        'size_group_id': sizeGroupId,
        'gender_id': genderId,
        'is_default': isDefault,
        'sort_order': sortOrder,
      }),
    );
  }

  Future<void> updateSizeGroup({
    required ProductTypeSizeGroupLink link,
    bool? isDefault,
    int? sortOrder,
  }) async {
    final current = _loaded;
    if (current == null) return;
    if (isDefault == true &&
        current.sizeGroups.any(
          (item) =>
              item.id != link.id &&
              item.isDefault &&
              item.genderId == link.genderId,
        )) {
      emit(
        current.copyWith(
          updateFailure: const ProductTypeDefaultSizeGroupConflictFailure(),
        ),
      );
      return;
    }
    await _mutate(
      'size-group-${link.id}',
      () => _repository.patchSizeGroupLink(link.id, {
        if (isDefault != null) 'is_default': isDefault,
        if (sortOrder != null) 'sort_order': sortOrder,
      }),
    );
  }

  Future<void> removeSizeGroup(ProductTypeSizeGroupLink link) async {
    await _mutate(
      'size-group-${link.id}',
      () => _repository.deleteSizeGroupLink(link.id),
    );
  }

  Future<void> addAttribute({
    required int attributeId,
    bool isRequired = false,
    int sortOrder = 0,
  }) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'attribute-add',
      () => _repository.createAttributeLink({
        'product_type_id': current.productTypeId,
        'attribute_id': attributeId,
        'is_required': isRequired,
        'sort_order': sortOrder,
      }),
      checkPublishedProducts: isRequired,
    );
  }

  Future<void> updateAttribute(
    ProductTypeAttributeLink link, {
    bool? isRequired,
    int? sortOrder,
  }) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'attribute-${link.attributeId}',
      () => _repository
          .patchAttributeLink(current.productTypeId, link.attributeId, {
            if (isRequired != null) 'is_required': isRequired,
            if (sortOrder != null) 'sort_order': sortOrder,
          }),
      checkPublishedProducts: isRequired == true,
    );
  }

  Future<void> removeAttribute(ProductTypeAttributeLink link) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'attribute-${link.attributeId}',
      () => _repository.deleteAttributeLink(
        current.productTypeId,
        link.attributeId,
      ),
    );
  }

  Future<void> addOptionSet({
    required int optionSetId,
    bool isRequired = false,
    int sortOrder = 0,
  }) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'option-set-add',
      () => _repository.createOptionSetLink({
        'product_type_id': current.productTypeId,
        'option_set_id': optionSetId,
        'is_required': isRequired,
        'sort_order': sortOrder,
      }),
      checkPublishedProducts: isRequired,
    );
  }

  Future<void> updateOptionSet(
    ProductTypeOptionSetLink link, {
    bool? isRequired,
    int? sortOrder,
  }) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'option-set-${link.optionSetId}',
      () => _repository
          .patchOptionSetLink(current.productTypeId, link.optionSetId, {
            if (isRequired != null) 'is_required': isRequired,
            if (sortOrder != null) 'sort_order': sortOrder,
          }),
      checkPublishedProducts: isRequired == true,
    );
  }

  Future<void> removeOptionSet(ProductTypeOptionSetLink link) async {
    final current = _loaded;
    if (current == null) return;
    await _mutate(
      'option-set-${link.optionSetId}',
      () => _repository.deleteOptionSetLink(
        current.productTypeId,
        link.optionSetId,
      ),
    );
  }

  ProductTypeDetailsLoaded? get _loaded => state is ProductTypeDetailsLoaded
      ? state as ProductTypeDetailsLoaded
      : null;

  Future<void> _mutate(
    String key,
    Future<Either<Failure, Unit>> Function() request, {
    bool checkPublishedProducts = false,
  }) async {
    final current = _loaded;
    if (current == null || current.processing.contains(key)) return;
    emit(
      current.copyWith(
        processing: {...current.processing, key},
        clearUpdateFailure: true,
      ),
    );

    if (checkPublishedProducts && current.publishedProductCount == null) {
      final count = await _repository.getPublishedProductCount(
        current.productTypeId,
      );
      count.fold((_) {}, (value) {
        final latest = _loaded;
        if (latest != null && !isClosed) {
          _publishedProductCount = value;
          emit(latest.copyWith(publishedProductCount: value));
        }
      });
    }

    final result = await request();
    final latest = _loaded;
    if (latest == null || isClosed) return;
    final nextProcessing = {...latest.processing}..remove(key);
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(
          latest.copyWith(processing: nextProcessing, updateFailure: failure),
        ),
        (_) {},
      );
      return;
    }
    emit(latest.copyWith(processing: nextProcessing));
    await load(latest.productTypeId);
  }
}
