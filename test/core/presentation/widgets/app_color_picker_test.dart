import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_picker/app_color_picker.dart';
import '../../../helpers/localized_app.dart';
void main(){setUpAll(()=>useTranslations(const Locale('en')));
testWidgets('null value state', (t)async{await t.pumpWidget(buildTestApp(home:Scaffold(body:AppColorPicker(value:null,onChanged:(_){}) )));expect(find.text('No color'),findsOneWidget);});
testWidgets('valid HEX edits emit RGB and invalid input is ignored', (t)async{String? emitted;await t.pumpWidget(buildTestApp(home:Scaffold(body:AppColorPicker(value:'#228B22',onChanged:(v)=>emitted=v))));await t.enterText(find.byType(TextField),'#F57C21');await t.pump();expect(emitted,'#F57C21');await t.enterText(find.byType(TextField),'#12ZZZZ');await t.pump();expect(emitted,'#F57C21');});
testWidgets('dragging preserves existing alpha', (t)async{String? result;await t.pumpWidget(buildTestApp(home:Scaffold(body:AppColorPicker(value:'#228B2280',onChanged:(v)=>result=v))));await t.drag(find.byType(CustomPaint).first,const Offset(10,10));await t.pump();expect(result,endsWith('80'));});
}