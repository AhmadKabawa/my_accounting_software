// // import 'package:flutter/material.dart';
// // import 'package:accounting_software/l10n/app_localizations.dart';

// // extension LocalizationExt on BuildContext {
// //   AppLocalizations get tr =>
// //       AppLocalizations.of(this)!;
// // }//context.tr.serverError
import 'package:flutter/material.dart';

extension DirectionExtension on BuildContext {
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  /// للأيقونات
  IconData directionalIcon({required IconData rtl, required IconData ltr}) {
    return isRTL ? rtl : ltr;
  }

  /// لأي قيمة عامة (double, Alignment, Color, EdgeInsets...)
  T directionalValue<T>({required T rtl, required T ltr}) {
    return isRTL ? rtl : ltr;
  }

  Widget transformFlip({required Widget child, bool isRtlChild = true}) {
    return (isRtlChild && isRTL)
        ? child
        : Transform.flip(flipX: true, child: child);
  }
}
