part of '../ui_extension.dart';

class DirectionHelper {
  final BuildContext context;
  const DirectionHelper(this.context);

  bool get isRTL => Directionality.of(context) == TextDirection.rtl;

  T value<T>({required T rtl, required T ltr}) {
    return isRTL ? rtl : ltr;
  }

  Widget transformFlip({required Widget child, bool isRtlChild = true}) {
    return (isRTL)
        ? isRtlChild
              ? child
              : Transform.flip(flipX: true, child: child)
        : isRtlChild
        ? Transform.flip(flipX: true, child: child)
        : child;
  }

  IconData icon({required IconData rtl, required IconData ltr}) {
    return isRTL ? rtl : ltr;
  }
}
