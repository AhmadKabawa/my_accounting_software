import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/dialogs/option_set_options_dialog.dart';

Future<void> showOptionSetOptions(BuildContext context, OptionSet optionSet) {
  Widget content() => BlocProvider(
    create: (_) => sl<OptionSetOptionsCubit>()..load(optionSet.id),
    child: OptionSetOptionsDialog(optionSet: optionSet),
  );
  if (MediaQuery.sizeOf(context).width >= 720) {
    return showDialog<void>(context: context, builder: (_) => content());
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .82,
        child: content(),
      ),
    ),
  );
}
