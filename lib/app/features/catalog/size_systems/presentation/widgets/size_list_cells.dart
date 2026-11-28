import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// An embedded usage count; unknown (null) shows a dash, never zero.
class SizeCountText extends StatelessWidget {
  const SizeCountText(this.count, {super.key});

  final int? count;

  @override
  Widget build(BuildContext context) => AppText.raw(
    count?.toString() ?? CommonKeys.noValue.tr(context: context),
  );
}

/// Codes are always left-to-right, also inside RTL screens.
class SizeCodeText extends StatelessWidget {
  const SizeCodeText(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: AppText.raw(code),
  );
}

String formatSizeDate(DateTime? value, {String noValue = ''}) {
  if (value == null) return noValue;
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}
