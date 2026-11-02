// lib/core/network/cancel/cancellable_mixin.dart

import 'package:dio/dio.dart';
import 'cancel_token_registry.dart';

/// Mixin يُضاف للـ ViewModel أو Cubit
/// يوفر cancelToken تلقائياً ويلغيه عند الـ dispose
///
/// الاستخدام:
///   class ProductsViewModel extends ChangeNotifier with CancellableMixin {
///     void loadProducts() async {
///       final result = await repo.getProducts(cancelToken: cancelToken);
///     }
///     @override
///     void dispose() {
///       cancelRequests(); // ← سطر واحد
///       super.dispose();
///     }
///   } 
mixin CancellableMixin {
  late final String _scope = "${runtimeType}_${identityHashCode(this)}";
  
  CancelToken get cancelToken => CancelTokenRegistry.instance.tokenFor(_scope);

  void cancelRequests() => CancelTokenRegistry.instance.cancelScope(_scope);

  /// أنشئ token جديد (بعد cancel مثلاً لإعادة المحاولة)
  CancelToken renewToken() {
    cancelRequests();
    return CancelTokenRegistry.instance.tokenFor(_scope);
  }
}
