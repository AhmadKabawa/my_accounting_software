import 'package:accounting_software/app/features/catalog/age_groups/data/models/age_group_model.dart';
import 'package:flutter_test/flutter_test.dart';
void main(){
  test('maps nullable age bounds and product usage',(){
    final x=AgeGroupModel.fromJson({'id':4,'name':'Children','min_age':2,'max_age':12,'is_active':true,'sort_order':3,'product_age_groups':[{'count':5}] }).toEntity();
    expect(x.id,4);expect(x.name,'Children');expect(x.minAge,2);expect(x.maxAge,12);expect(x.productCount,5);expect(x.canDelete,isFalse);
  });
  test('unknown usage fails closed and null bounds are valid',(){
    final x=AgeGroupModel.fromJson({'id':5,'name':'All ages','min_age':null,'max_age':null,'is_active':true,'sort_order':0}).toEntity();
    expect(x.minAge,isNull);expect(x.maxAge,isNull);expect(x.productCount,isNull);expect(x.canDelete,isFalse);
  });
  test('known zero usage permits deletion',(){
    final x=AgeGroupModel.fromJson({'id':6,'name':'Adults','min_age':18,'max_age':null,'product_age_groups':[{'count':0}]}).toEntity();
    expect(x.canDelete,isTrue);
  });
}
