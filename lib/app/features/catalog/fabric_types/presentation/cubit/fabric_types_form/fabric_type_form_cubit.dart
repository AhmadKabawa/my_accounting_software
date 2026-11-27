import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/failures/fabric_type_failures.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/create_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/update_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';
enum FabricTypeFormStatus{idle,saving}
sealed class FabricTypeFormEffect{const FabricTypeFormEffect();}
class FabricTypeSavedEffect extends FabricTypeFormEffect{const FabricTypeSavedEffect();}
class FabricTypeSaveFailedEffect extends FabricTypeFormEffect{const FabricTypeSaveFailedEffect(this.messageKey);final AppKey messageKey;}
class FabricTypeFormCubit extends BaseCubit<FabricTypeFormStatus,FabricTypeFormEffect>{
 FabricTypeFormCubit({required CreateFabricTypeUseCase create,required UpdateFabricTypeUseCase update,required FlashMessages flashMessages}):_create=create,_update=update,_flash=flashMessages,super(FabricTypeFormStatus.idle);
 final CreateFabricTypeUseCase _create;final UpdateFabricTypeUseCase _update;final FlashMessages _flash;
 Future<void> save({required FabricTypeDraft draft,int? id})async{if(state==FabricTypeFormStatus.saving||isClosed)return;emit(FabricTypeFormStatus.saving);final result=id==null?await _create(draft):await _update(UpdateFabricTypeParams(id,draft));if(isClosed)return;result.fold((failure){emitEffect(FabricTypeSaveFailedEffect(failure is FabricTypeDuplicateFailure? FabricTypesKeys.duplicateError:failure.messageKey));},(_){emitEffect(const FabricTypeSavedEffect());_flash.post(FabricTypesKeys.saved,MessageType.success);});if(!isClosed)emit(FabricTypeFormStatus.idle);}
}