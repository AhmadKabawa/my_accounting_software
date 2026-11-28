import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

AppKey attributeTypeLabel(AttributeDataType type) => switch (type) {
  AttributeDataType.text => AttributesKeys.text,
  AttributeDataType.number => AttributesKeys.number,
  AttributeDataType.boolean => AttributesKeys.boolean,
  AttributeDataType.date => AttributesKeys.date,
  AttributeDataType.json => AttributesKeys.json,
  AttributeDataType.option => AttributesKeys.option,
};

String duplicateAttributeCode(String source, {required int maxLength}) {
  final suffix = '-${DateTime.now().microsecondsSinceEpoch}-copy';
  final prefix = source.length > maxLength - suffix.length
      ? source.substring(0, maxLength - suffix.length)
      : source;
  return '$prefix$suffix';
}
