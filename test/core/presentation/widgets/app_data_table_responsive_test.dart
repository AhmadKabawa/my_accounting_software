import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

/// المرحلة 0 (UI_SAAS_VERIFY §أ): اختبار توصيفي للسلوك الحالي.
///
/// الجدول يحدد نوع الشاشة من عرض الحاوية (`constraints.maxWidth`)، بينما
/// الشيل يحدد الشريط الجانبي من `ScreenEngine.screenType(context)` (عرض
/// النافذة). فإذا كان الشريط الجانبي (≈256) يشغل جزءاً من العرض، يرى الجدول
/// عرضاً أصغر من النافذة فيُخفي الأعمدة الثانوية رغم أن الشيل يعدّ الشاشة
/// ديسكتوب. تُعكس توقعات هذا الملف في المرحلة 2 بعد توحيد المصدر.
const _name = TestKey('verify.name');
const _status = TestKey('verify.status');
const _sidebarWidth = 256.0;

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Future<void> pump(
    WidgetTester tester, {
    required double window,
    required bool withSidebar,
  }) async {
    setScreenSize(tester, Size(window, 900));
    await tester.pumpWidget(
      buildTestApp(
        direction: TextDirection.ltr,
        home: Scaffold(
          body: Row(
            children: [
              if (withSidebar) const SizedBox(width: _sidebarWidth),
              Expanded(
                child: AppDataTable<String>(
                  columns: [
                    DataTableColumn<String>(
                      labelKey: _name,
                      priority: DataTableColumnPriority.primary,
                      cellBuilder: (_, v) => Text('Name: $v'),
                    ),
                    DataTableColumn<String>(
                      labelKey: _status,
                      cellBuilder: (_, v) => Text('Status: $v'),
                    ),
                  ],
                  rows: const ['Alpha'],
                  rowId: (v) => v,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('360: بطاقات (موبايل)', (tester) async {
    await pump(tester, window: 360, withSidebar: false);
    expect(find.byType(AppCard), findsWidgets);
  });

  testWidgets('600: جدول بلا أعمدة ثانوية (تابلت)', (tester) async {
    await pump(tester, window: 600, withSidebar: false);
    expect(find.text('Name: Alpha'), findsOneWidget);
    expect(find.text('Status: Alpha'), findsNothing);
  });

  testWidgets('900: جدول بلا أعمدة ثانوية (تابلت)', (tester) async {
    await pump(tester, window: 900, withSidebar: false);
    expect(find.text('Status: Alpha'), findsNothing);
  });

  testWidgets('1200 بلا شريط جانبي: كل الأعمدة', (tester) async {
    await pump(tester, window: 1200, withSidebar: false);
    expect(find.text('Status: Alpha'), findsOneWidget);
  });

  testWidgets('خلل: 1200 مع الشريط الجانبي يُخفي العمود الثانوي', (tester) async {
    await pump(tester, window: 1200, withSidebar: true);
    expect(find.text('Name: Alpha'), findsOneWidget);
    expect(find.text('Status: Alpha'), findsNothing);
  });

  testWidgets('خلل: 1366 مع الشريط الجانبي يُخفي العمود الثانوي', (tester) async {
    await pump(tester, window: 1366, withSidebar: true);
    expect(find.text('Status: Alpha'), findsNothing);
  });
}
