import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/create_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/update_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';
enum MaterialFormStatus{idle,saving}
sealed class MaterialFormEffect{const MaterialFormEffect();}
class MaterialSavedEffect extends MaterialFormEffect{const MaterialSavedEffect();}
class MaterialSaveFailedEffect extends MaterialFormEffect{const MaterialSaveFailedEffect(this.messageKey);final AppKey messageKey;}
class MaterialFormCubit extends BaseCubit<MaterialFormStatus,MaterialFormEffect>{
 MaterialFormCubit({required CreateMaterialUseCase create,required UpdateMaterialUseCase update,required FlashMessages flashMessages}):_create=create,_update=update,_flash=flashMessages,super(MaterialFormStatus.idle);
 final CreateMaterialUseCase _create;final UpdateMaterialUseCase _update;final FlashMessages _flash;
 Future<void> save({required MaterialDraft draft,int? id})async{if(state==MaterialFormStatus.saving||isClosed)return;emit(MaterialFormStatus.saving);final result=id==null?await _create(draft):await _update(UpdateMaterialParams(id,draft));if(isClosed)return;result.fold((failure)=>emitEffect(MaterialSaveFailedEffect(failure.messageKey)),(_)=>{emitEffect(const MaterialSavedEffect()),_flash.post(MaterialsKeys.saved,MessageType.success)});if(!isClosed)emit(MaterialFormStatus.idle);}
}