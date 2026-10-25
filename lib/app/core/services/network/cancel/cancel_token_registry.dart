// lib/core/network/cancel/cancel_token_registry.dart

import 'package:dio/dio.dart';

/// سجل مركزي لإدارة CancelTokens
/// كل scope (screen/viewmodel) له token خاص
/// عند الخروج: يُلغى الـ token تلقائياً
class CancelTokenRegistry {
  CancelTokenRegistry._();
  static final instance = CancelTokenRegistry._();

  final Map<String, CancelToken> _tokens = {};

  /// احصل على token لـ scope معين (أو أنشئ واحداً جديداً)
  CancelToken tokenFor(String scope) {
    if (_tokens[scope]?.isCancelled ?? true) {
      _tokens[scope] = CancelToken();
    }
    return _tokens[scope]!;
  }

  /// ألغِ كل requests لـ scope معين (عند الخروج من الصفحة)
  void cancelScope(String scope) {
    _tokens[scope]?.cancel('$scope: disposed');
    _tokens.remove(scope);
  }

  /// ألغِ كل شيء (عند logout مثلاً)
  void cancelAll() {
    for (final token in _tokens.values) {
      token.cancel('Global cancel');
    }
    _tokens.clear();
  }

  /// تحقق هل الـ scope نشط
  bool isActive(String scope) =>
      _tokens.containsKey(scope) && !(_tokens[scope]?.isCancelled ?? true);
}