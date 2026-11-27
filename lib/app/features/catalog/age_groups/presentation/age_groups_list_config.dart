import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_groups_list/age_groups_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_groups_list/age_groups_list_effect.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/dialogs/age_group_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/widgets/age_group_status_badge.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/widgets/age_groups_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
const _labels=CrudLabels(edit:AgeGroupsKeys.edit,delete:AgeGroupsKeys.delete,activate:AgeGroupsKeys.activate,deactivate:AgeGroupsKeys.deactivate,deleteConfirmationTitle:AgeGroupsKeys.deleteTitle,deleteConfirmationMessage:AgeGroupsKeys.deleteMessage,deactivateConfirmationTitle:AgeGroupsKeys.deactivateTitle,deactivateConfirmationMessage:AgeGroupsKeys.deactivateMessage);
CrudListConfig<AgeGroup,AgeGroupListQuery,AgeGroupsListCubit,AgeGroupsListEffect> get ageGroupsListConfig=>CrudListConfig(
  screenId:'catalog.ageGroups',titleKey:AgeGroupsKeys.title,manageAccess:Permissions.masterData.manage,
  searchHintKey:AgeGroupsKeys.searchHint,addLabelKey:AgeGroupsKeys.add,createCubit:()=>sl<AgeGroupsListCubit>(),
  rowId:(x)=>x.id,itemLabel:(x)=>x.name,
  sort:CrudSortConfig<AgeGroupListQuery,AgeGroupsListCubit>(
    options:const [FilterBarSortOption(key:'order',label:AgeGroupsKeys.sortOrder),FilterBarSortOption(key:'name',label:AgeGroupsKeys.name)],
    current:(q)=>[FilterBarSort(q.sortField.name,q.sortAscending)],tableKey:(q)=>q.sortField.name,tableAscending:(q)=>q.sortAscending,
    apply:(c,s){if(s.isEmpty)return;final f=AgeGroupSortField.tryParse(s.first.key);if(f!=null)c.setSort(f,s.first.ascending);},
    applyTable:(c,s){final f=AgeGroupSortField.tryParse(s.key);if(f!=null)c.setSort(f,s.ascending);},
  ),
  filterControls:(slot)=>AgeGroupsFilterBar.controls(slot.context,slot.state.query,onStatusChanged:slot.cubit.setStatus),
  activeFilters:(slot)=>AgeGroupsFilterBar.activeFilters(slot.context,slot.state.query,onSearchChanged:slot.cubit.searchChanged,onStatusChanged:slot.cubit.setStatus),
  breadcrumb:(context)=>AppBreadcrumb(items:[AppBreadcrumbItem(label:NavKeys.catalog,onTap:()=>context.go(CatalogRoutes.hub.path)),const AppBreadcrumbItem(label:AgeGroupsKeys.title)]),
  viewModes:const [AppViewMode.table,AppViewMode.cards],
  capabilities:const CrudCapabilities(showCount:true,duplicate:false,bulkSelection:false),
  flows:CrudFlowsConfig<AgeGroup,AgeGroupsListCubit>(
    showEditor:(context,{item,duplicate=false})=>showAgeGroupEditor(context,ageGroup:item),
    onSaved:(c,{required isNew})=>c.onAgeGroupSaved(isNew:isNew),itemLabel:(x)=>x.name,
    delete:(c,x)=>c.delete(x),activate:(c,x)=>c.activate(x.id),deactivate:(c,x)=>c.deactivate(x.id),
    labels:_labels,isActive:(x)=>x.isActive,canDelete:(x)=>x.canDelete,hideDeleteWhenCannotDelete:true,
  ),
  dataSection:(data)=>CrudDataSection<AgeGroup,AgeGroupListQuery,AgeGroupsListCubit>(
    data:data,columns:[
      DataTableColumn(labelKey:AgeGroupsKeys.name,sortKey:'name',priority:DataTableColumnPriority.primary,flex:3,cellBuilder:(_,x)=>AppText.raw(x.name)),
      DataTableColumn(labelKey:AgeGroupsKeys.minAge,numeric:true,priority:DataTableColumnPriority.secondary,cellBuilder:(_,x)=>x.minAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.minAge.toString())),
      DataTableColumn(labelKey:AgeGroupsKeys.maxAge,numeric:true,priority:DataTableColumnPriority.secondary,cellBuilder:(_,x)=>x.maxAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.maxAge.toString())),
      DataTableColumn(labelKey:AgeGroupsKeys.sortOrder,sortKey:'order',numeric:true,priority:DataTableColumnPriority.secondary,cellBuilder:(_,x)=>AppText.raw(x.sortOrder.toString())),
    ],labels:_labels,statusColumn:CrudStatusColumnConfig<AgeGroup>(labelKey:AgeGroupsKeys.status,isActive:(x)=>x.isActive,badgeBuilder:(_,x)=>AgeGroupStatusBadge(x)),
    cardBuilder:(_,x)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText.raw(x.name,type:AppTextType.titleMedium),AppText(AgeGroupsKeys.minAge),x.minAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.minAge.toString()),AppText(AgeGroupsKeys.maxAge),x.maxAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.maxAge.toString()),AgeGroupStatusBadge(x)]),
    gridBuilder:(_,x)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[AppText.raw(x.name,type:AppTextType.titleMedium),AppText(AgeGroupsKeys.minAge),x.minAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.minAge.toString()),AppText(AgeGroupsKeys.maxAge),x.maxAge==null?const AppText(CommonKeys.noValue):AppText.raw(x.maxAge.toString()),AgeGroupStatusBadge(x)]),
    icon:AppIcons.catalog,emptyTitleKey:AgeGroupsKeys.empty,emptyDescriptionKey:AgeGroupsKeys.emptyDescription,noResultsTitleKey:AgeGroupsKeys.noResults,noResultsDescriptionKey:AgeGroupsKeys.noResultsDescription,
  ),
);
