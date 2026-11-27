import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
abstract final class AgeGroupsFilterBar {
  static AppKey statusLabel(AgeGroupStatusFilter v)=>switch(v){AgeGroupStatusFilter.all=>AgeGroupsKeys.allStatuses,AgeGroupStatusFilter.active=>AgeGroupsKeys.active,AgeGroupStatusFilter.inactive=>AgeGroupsKeys.inactive};
  static List<FilterBarFilter> activeFilters(BuildContext context,AgeGroupListQuery q,{required ValueChanged<String> onSearchChanged,required ValueChanged<AgeGroupStatusFilter> onStatusChanged})=>[
    if(q.search.isNotEmpty) FilterBarFilter(id:FilterBar.searchFilterId,label:AgeGroupsKeys.searchHint,value:q.search,onRemove:()=>onSearchChanged('')),
    if(q.status!=AgeGroupStatusFilter.all) FilterBarFilter(id:'status',label:AgeGroupsKeys.status,value:statusLabel(q.status).tr(context:context),onRemove:()=>onStatusChanged(AgeGroupStatusFilter.all)),
  ];
  static List<Widget> controls(BuildContext context,AgeGroupListQuery q,{required ValueChanged<AgeGroupStatusFilter> onStatusChanged})=>[
    SearchableDropdown<AgeGroupStatusFilter>(options:const [AgeGroupStatusFilter.active,AgeGroupStatusFilter.inactive],labelKey:AgeGroupsKeys.status,optionLabel:(v)=>statusLabel(v).tr(context:context),value:q.status==AgeGroupStatusFilter.all?null:q.status,allOptionLabel:AgeGroupsKeys.allStatuses,mode:SearchableDropdownMode.panel,onChanged:(v)=>onStatusChanged(v??AgeGroupStatusFilter.all)),
  ];
}
