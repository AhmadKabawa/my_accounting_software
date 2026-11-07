import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => const [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.summary);

  final HomeSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class HomeFailed extends HomeState {
  const HomeFailed(this.messageKey);

  final AppKey messageKey;

  @override
  List<Object?> get props => [messageKey];
}
