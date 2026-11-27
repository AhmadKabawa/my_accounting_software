import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
class AgeGroupEditorFields extends StatelessWidget {
  const AgeGroupEditorFields({super.key,required this.name,required this.minAge,required this.maxAge,required this.sortOrder,required this.active,required this.onChanged,required this.onActiveChanged});
  final TextEditingController name,minAge,maxAge,sortOrder; final bool active;
  final ValueChanged<String> onChanged; final ValueChanged<bool>? onActiveChanged;
  int? _optional(String s)=>s.trim().isEmpty?null:int.tryParse(s.trim());
  String? _ageError(BuildContext c,String? value){
    final s=value?.trim()??'';if(s.isEmpty)return null;final n=int.tryParse(s);
    if(n==null||n<0)return AgeGroupsKeys.invalidInteger.tr(context:c);
    final lo=_optional(minAge.text),hi=_optional(maxAge.text);
    if(lo!=null&&hi!=null&&lo>hi)return AgeGroupsKeys.invalidRange.tr(context:c);
    return null;
  }
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    AppTextField(controller:name,labelKey:AgeGroupsKeys.name,onChanged:onChanged,validator:(v){final s=v?.trim()??'';if(s.isEmpty)return AgeGroupsKeys.required.tr(context:context);if(s.length>100)return AgeGroupsKeys.nameTooLong.tr(context:context);return null;}),
    context.ui.spacing.gap(AppSpacing.sm),
    AppTextField(controller:minAge,labelKey:AgeGroupsKeys.minAge,keyboardType:TextInputType.number,textDirection:TextDirection.ltr,onChanged:onChanged,validator:(v)=>_ageError(context,v)),
    context.ui.spacing.gap(AppSpacing.sm),
    AppTextField(controller:maxAge,labelKey:AgeGroupsKeys.maxAge,keyboardType:TextInputType.number,textDirection:TextDirection.ltr,onChanged:onChanged,validator:(v)=>_ageError(context,v)),
    context.ui.spacing.gap(AppSpacing.sm),
    AppTextField(controller:sortOrder,labelKey:AgeGroupsKeys.sortOrder,keyboardType:TextInputType.number,textDirection:TextDirection.ltr,onChanged:onChanged,validator:(v){final n=int.tryParse((v??'').trim());return n==null||n<0?AgeGroupsKeys.invalidInteger.tr(context:context):null;}),
    context.ui.spacing.gap(AppSpacing.sm),
    AppSwitch(value:active,labelKey:AgeGroupsKeys.active,onChanged:onActiveChanged),
  ]);
}
