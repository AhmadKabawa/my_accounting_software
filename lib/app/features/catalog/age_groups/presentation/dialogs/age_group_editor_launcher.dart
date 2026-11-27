import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_group_form/age_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/dialogs/age_group_editor_dialog.dart';
Future<bool?> showAgeGroupEditor(BuildContext context,{AgeGroup? ageGroup})=>showAppFormDialog<bool>(context,(_)=>BlocProvider(create:(_)=>sl<AgeGroupFormCubit>(),child:AgeGroupEditorDialog(ageGroup:ageGroup)));
