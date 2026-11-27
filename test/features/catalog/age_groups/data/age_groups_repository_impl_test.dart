import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/datasources/age_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/models/age_group_model.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/repositories/age_groups_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failures.dart';
import 'package:flutter_test/flutter_test.dart';
class _Remote implements AgeGroupsRemoteDataSource {
  ApiResult<AgeGroupModel> write=ApiFailure(ApiException.conflict(errorCode:'23514'));
  ApiResult<Unit> remove=ApiFailure(ApiException.conflict(errorCode:'23503'));
  @override Future<ApiResult<AgeGroupModel>> createAgeGroup(AgeGroupDraft d) async=>write;
  @override Future<ApiResult<AgeGroupModel>> updateAgeGroup({required int id,required AgeGroupDraft draft}) async=>write;
  @override Future<ApiResult<Unit>> deleteAgeGroup(int id) async=>remove;
  @override Future<ApiResult<Unit>> setAgeGroupActive({required int id,required bool isActive}) async=>ApiFailure(ApiException.unknown());
  @override Future<ApiResult<PaginatedResult<AgeGroupModel>>> getAgeGroups(AgeGroupListQuery q) async=>ApiFailure(ApiException.unknown());
}
void main(){
  late _Remote remote;late AgeGroupsRepositoryImpl repository;
  setUp(() { remote=_Remote(); repository=AgeGroupsRepositoryImpl(remote); });
  test('23514 maps to localized range failure on create',() async{
    final r=await repository.createAgeGroup(const AgeGroupDraft(name:'Children',minAge:12,maxAge:2));
    r.fold((f)=>expect(f,isA<AgeGroupInvalidRangeFailure>()),(_)=>fail('Expected failure'));
  });
  test('23514 maps to localized range failure on update',() async{
    final r=await repository.updateAgeGroup(id:1,draft:const AgeGroupDraft(name:'Children',minAge:12,maxAge:2));
    r.fold((f)=>expect(f,isA<AgeGroupInvalidRangeFailure>()),(_)=>fail('Expected failure'));
  });
  test('23503 maps to in-use failure on delete',() async{
    final r=await repository.deleteAgeGroup(1);
    r.fold((f)=>expect(f,isA<AgeGroupInUseFailure>()),(_)=>fail('Expected failure'));
  });
}
