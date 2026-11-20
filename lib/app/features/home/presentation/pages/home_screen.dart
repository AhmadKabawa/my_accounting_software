import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/model/dashboard_card_definition.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/dashboard_card.dart';

/// AUTH-04: a permission-filtered list of implemented destinations.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.registeredRoutes,
    this.definitions = dashboardCardDefinitions,
  });

  final List<RouteItem> registeredRoutes;
  final List<DashboardCardDefinition> definitions;

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessCubit>();
    final available = availableDashboardCards(
      definitions: definitions,
      registeredRoutes: registeredRoutes,
      can: access.can,
    );
    final cards = [
      for (final definition in available)
        DashboardCard(
          definition: definition,
          onTap: () => context.go(definition.destination.path),
        ),
    ];

    return DashboardTemplate(
      titleKey: HomeKeys.dashboardTitle,
      state: cards.isEmpty ? AppPageState.empty : AppPageState.content,
      cards: cards,
      emptyState: AppEmptyState(
        icon: AppIcons.home,
        titleKey: HomeKeys.noAvailableCardsTitle,
        descriptionKey: HomeKeys.noAvailableCardsDescription,
      ),
    );
  }
}
