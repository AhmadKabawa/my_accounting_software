import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/main_navigation_bar/presentation/cubit/main_navigation_bar_state.dart';

class MainNavigationBarCubit extends Cubit<MainNavigationBarState> {
  MainNavigationBarCubit() : super(MainNavigationBarState.initial());
  static const routes = [
    '/main/home',
    '/main/chat',
    '/main/favorites',
    '/main/profile',
  ];

  /// تغيير صفحة التنقل
  void changeIndex(int index) {
    // تجنب إعادة بناء غير ضروري
    if (state.currentIndex == index) return;

    emit(state.copyWith(currentIndex: index));
  }

  /// العودة للصفحة الأولى
  void resetIndex() {
    if (state.currentIndex != 0) {
      emit(state.copyWith(currentIndex: 0));
    }
  }
}
