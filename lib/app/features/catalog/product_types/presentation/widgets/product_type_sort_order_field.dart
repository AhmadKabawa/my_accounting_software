import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

class ProductTypeSortOrderField extends StatefulWidget {
  const ProductTypeSortOrderField({
    super.key,
    required this.value,
    required this.enabled,
    required this.onCommit,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onCommit;

  @override
  State<ProductTypeSortOrderField> createState() =>
      _ProductTypeSortOrderFieldState();
}

class _ProductTypeSortOrderFieldState extends State<ProductTypeSortOrderField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(ProductTypeSortOrderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null) {
      _controller.text = widget.value.toString();
      return;
    }
    if (value != widget.value) widget.onCommit(value);
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: _controller,
    labelKey: ProductTypesKeys.sortOrder,
    enabled: widget.enabled,
    keyboardType: const TextInputType.numberWithOptions(signed: true),
    textInputAction: TextInputAction.done,
    onSubmitted: _commit,
  );
}
