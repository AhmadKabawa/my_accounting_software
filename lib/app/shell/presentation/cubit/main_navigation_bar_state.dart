import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_navigation_bar_state.freezed.dart';

@freezed
class MainNavigationBarState with _$MainNavigationBarState {
  const factory MainNavigationBarState({
    /// الفهرس الحالي للصفحة  @Default(0)
   required int currentIndex,

    ///  عدد الصفحات@  Default(4)
    required int pageCount,
  }) = _MainNavigationBarState;
 factory MainNavigationBarState.initial() =>
      const MainNavigationBarState(currentIndex: 0, pageCount: 4);
}
