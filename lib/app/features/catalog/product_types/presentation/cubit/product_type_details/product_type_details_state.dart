import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';

sealed class ProductTypeDetailsState extends Equatable {
  const ProductTypeDetailsState();
}

final class ProductTypeDetailsInitial extends ProductTypeDetailsState {
  const ProductTypeDetailsInitial();

  @override
  List<Object?> get props => [];
}

final class ProductTypeDetailsLoading extends ProductTypeDetailsState {
  const ProductTypeDetailsLoading();

  @override
  List<Object?> get props => [];
}

final class ProductTypeDetailsFailed extends ProductTypeDetailsState {
  const ProductTypeDetailsFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class ProductTypeDetailsLoaded extends ProductTypeDetailsState {
  const ProductTypeDetailsLoaded({
    required this.productType,
    required this.productTypeId,
    required this.sizeGroups,
    required this.attributes,
    required this.optionSets,
    required this.sizeGroupOptions,
    required this.attributeOptions,
    required this.optionSetOptions,
    required this.genderOptions,
    this.processing = const {},
    this.updateFailure,
    this.publishedProductCount,
  });

  final ProductType productType;
  final int productTypeId;
  final List<ProductTypeSizeGroupLink> sizeGroups;
  final List<ProductTypeAttributeLink> attributes;
  final List<ProductTypeOptionSetLink> optionSets;
  final List<ProductTypeLinkOption> sizeGroupOptions;
  final List<ProductTypeLinkOption> attributeOptions;
  final List<ProductTypeLinkOption> optionSetOptions;
  final List<ProductTypeLinkOption> genderOptions;
  final Set<String> processing;
  final Failure? updateFailure;
  final int? publishedProductCount;

  ProductTypeDetailsLoaded copyWith({
    List<ProductTypeSizeGroupLink>? sizeGroups,
    List<ProductTypeAttributeLink>? attributes,
    List<ProductTypeOptionSetLink>? optionSets,
    Set<String>? processing,
    Failure? updateFailure,
    bool clearUpdateFailure = false,
    int? publishedProductCount,
  }) => ProductTypeDetailsLoaded(
    productType: productType,
    productTypeId: productTypeId,
    sizeGroups: sizeGroups ?? this.sizeGroups,
    attributes: attributes ?? this.attributes,
    optionSets: optionSets ?? this.optionSets,
    sizeGroupOptions: sizeGroupOptions,
    attributeOptions: attributeOptions,
    optionSetOptions: optionSetOptions,
    genderOptions: genderOptions,
    processing: processing ?? this.processing,
    updateFailure: clearUpdateFailure
        ? null
        : updateFailure ?? this.updateFailure,
    publishedProductCount: publishedProductCount ?? this.publishedProductCount,
  );

  @override
  List<Object?> get props => [
    productType,
    productTypeId,
    sizeGroups,
    attributes,
    optionSets,
    sizeGroupOptions,
    attributeOptions,
    optionSetOptions,
    genderOptions,
    processing,
    updateFailure,
    publishedProductCount,
  ];
}
