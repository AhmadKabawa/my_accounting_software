import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/upload_collection_image_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_form/collection_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/dialogs/collections_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';

Future<bool?> showCollectionEditor(
  BuildContext context, {
  CatalogCollection? item,
  bool duplicate = false,
  ImagePickerPort? imagePicker,
  FileDropTargetAdapter? dropTargetAdapter,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<CollectionFormCubit>(),
    child: CollectionEditorDialog(
      item: item,
      imageUploader: (upload) async {
        final result = await sl<UploadCollectionImageUseCase>()(upload);
        return result.leftMap(
          (failure) => failure is PermissionFailure
              ? PermissionFailure(
                  messageKey: CollectionsKeys.imageUploadPermission,
                )
              : failure,
        );
      },
      imagePicker: imagePicker ??
          (sl.isRegistered<ImagePickerPort>() ? sl<ImagePickerPort>() : null),
      dropTargetAdapter: dropTargetAdapter ??
          (sl.isRegistered<FileDropTargetAdapter>()
              ? sl<FileDropTargetAdapter>()
              : null),
    ),
  ),
);
