import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {

  /// عندما يتم إنشاء Cubit
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);

    debugPrint(
      '🟢 Created: ${bloc.runtimeType}',
    );
  }

  /// عندما تتغير الحالة
  @override
  void onChange(
    BlocBase bloc,
    Change change,
  ) {
    super.onChange(bloc, change);

    debugPrint(
      '''
🔄 Change detected
Cubit: ${bloc.runtimeType}
Current: ${change.currentState}
Next: ${change.nextState}
''',
    );
  }

  /// للأخطاء
  @override
  void onError(
    BlocBase bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      '''
🔴 Error detected
Cubit: ${bloc.runtimeType}
Error: $error
''',
    );

    super.onError(
      bloc,
      error,
      stackTrace,
    );
  }

  /// عند الإغلاق
  @override
  void onClose(BlocBase bloc) {
    debugPrint(
      '🔴 Closed: ${bloc.runtimeType}',
    );

    super.onClose(bloc);
  }
}