import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_picker/app_color_picker.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';
import '../../../helpers/localized_app.dart';

Finder _pickerSurfaces() => find.descendant(
  of: find.byType(AppColorPicker),
  matching: find.byWidgetPredicate(
    (widget) => widget is RawGestureDetector && widget.child is CustomPaint,
  ),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  testWidgets('color selection area uses its actual square hit bounds', (
    t,
  ) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: '#228B22',
            onChanged: (value) => result = value,
          ),
        ),
      ),
    );

    final area = _pickerSurfaces().first;
    expect(t.getSize(area).width, 220);
    expect(t.getSize(area).height, 220);

    await t.tapAt(t.getTopLeft(area) + const Offset(200, 20));
    await t.pump();

    expect(result, isNot('#228B22'));
  });

  testWidgets('null value state', (t) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(body: AppColorPicker(value: null, onChanged: (_) {})),
      ),
    );
    expect(find.text('No color'), findsOneWidget);
  });
  testWidgets('valid HEX edits emit RGB and invalid input is ignored', (
    t,
  ) async {
    String? emitted;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(value: '#228B22', onChanged: (v) => emitted = v),
        ),
      ),
    );
    await t.enterText(find.byType(TextField), '#F57C21');
    await t.pump();
    expect(emitted, '#F57C21');
    await t.enterText(find.byType(TextField), '#12ZZZZ');
    await t.pump();
    expect(emitted, '#F57C21');
  });
  testWidgets('dragging preserves existing alpha', (t) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: '#228B2280',
            onChanged: (v) => result = v,
          ),
        ),
      ),
    );
    await t.drag(find.byType(GestureDetector).first, const Offset(10, 10));
    await t.pump();
    expect(result, endsWith('80'));
  });

  testWidgets('manual RGB edit preserves existing alpha', (t) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: '#228B2280',
            onChanged: (value) => result = value,
          ),
        ),
      ),
    );

    await t.enterText(find.byType(TextField), '#AABBCC');
    await t.pump();

    expect(result, '#AABBCC80');
  });

  testWidgets('manual RGBA HEX edit preserves its alpha channel', (t) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: '#228B2280',
            onChanged: (value) => result = value,
          ),
        ),
      ),
    );

    await t.enterText(find.byType(TextField), '#AABBCC44');
    await t.pump();

    expect(result, '#AABBCC44');
  });

  testWidgets('preset selection preserves an existing alpha channel', (
    t,
  ) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: '#228B2280',
            presets: const ['#AABBCC'],
            onChanged: (value) => result = value,
          ),
        ),
      ),
    );

    await t.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppColorSwatch &&
            widget.hex == '#AABBCC' &&
            widget.onTap == null,
      ),
    );
    await t.pump();

    expect(result, '#AABBCC80');
  });

  testWidgets('invalid presets are ignored and valid preset is selectable', (
    t,
  ) async {
    String? result;
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: null,
            presets: const ['#12ZZZZ', '#AABBCC'],
            onChanged: (value) => result = value,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('#12ZZZZ'), findsNothing);
    await t.tap(find.bySemanticsLabel('#AABBCC'));
    await t.pump();

    expect(result, '#AABBCC');
  });

  testWidgets('external value changes synchronize the HEX field', (t) async {
    var value = '#228B22';
    await t.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                AppColorPicker(
                  value: value,
                  onChanged: (next) => setState(() => value = next ?? ''),
                ),
                TextButton(
                  onPressed: () => setState(() => value = '#123456'),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await t.tap(find.text('Update'));
    await t.pump();

    expect(
      t.widget<TextField>(find.byType(TextField)).controller?.text,
      '#123456',
    );
  });

  testWidgets('mobile starts collapsed for a preset and expands on demand', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: Scaffold(
            body: AppColorPicker(
              value: '#228B22',
              presets: const ['#228B22'],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(_pickerSurfaces(), findsNothing);
    await t.tap(find.text('Custom color'));
    await t.pump();
    expect(_pickerSurfaces(), findsNWidgets(2));
  });

  testWidgets('custom mobile value starts expanded', (t) async {
    await t.pumpWidget(
      buildTestApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: Scaffold(
            body: AppColorPicker(
              value: '#123456',
              presets: const ['#228B22'],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(_pickerSurfaces(), findsNWidgets(2));
  });

  testWidgets('SV and hue drag surfaces do not scroll their parent', (t) async {
    final scrollController = ScrollController();
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 1000,
              child: AppColorPicker(value: '#228B22', onChanged: (_) {}),
            ),
          ),
        ),
      ),
    );
    await t.drag(_pickerSurfaces().first, const Offset(0, 120));
    await t.pump();
    expect(scrollController.offset, 0);
    await t.drag(_pickerSurfaces().last, const Offset(0, 80));
    await t.pump();
    expect(scrollController.offset, 0);
    await t.pumpWidget(const SizedBox.shrink());
    scrollController.dispose();
  });

  testWidgets('preset touch targets use the responsive hit-area token', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: Scaffold(
            body: AppColorPicker(
              value: '#228B22',
              presets: const ['#228B22', '#F57C21'],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    for (final label in ['#228B22', '#F57C21']) {
      final target = find.bySemanticsLabel(label);
      final expected = AppComponentSize.hitArea.of(t.element(target));
      expect(t.getSize(target).width, expected);
      expect(t.getSize(target).height, expected);
    }
  });

  testWidgets('SV and hue expose semantic increase and decrease', (t) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(value: '#228B22', onChanged: (_) {}),
        ),
      ),
    );
    final sliders = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.slider == true,
    );
    expect(sliders, findsNWidgets(2));
    for (var index = 0; index < 2; index++) {
      final properties = t.widget<Semantics>(sliders.at(index)).properties;
      expect(properties.onIncrease, isNotNull);
      expect(properties.onDecrease, isNotNull);
    }
  });

  testWidgets('compact picker fits narrow RTL layout with large text', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(280, 760),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: AppColorPicker(
                value: '#123456',
                presets: const ['#111111', '#222222', '#333333', '#444444'],
                collapsedPresetCount: 2,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.text('Custom color'), findsOneWidget);
  });

  testWidgets('quick colors collapse to a count and expand with More', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AppColorPicker(
              value: null,
              presets: const ['#111111', '#222222', '#333333', '#444444'],
              collapsedPresetCount: 2,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('#222222'), findsOneWidget);
    expect(find.bySemanticsLabel('#333333'), findsNothing);
    await t.tap(find.text('More'));
    await t.pump();
    expect(find.bySemanticsLabel('#444444'), findsOneWidget);
    await t.tap(find.text('Less'));
    await t.pump();
    expect(find.bySemanticsLabel('#444444'), findsNothing);
  });

  testWidgets('preset expansion control stays in the preset header row', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: null,
            presets: const ['#111111', '#222222', '#333333'],
            collapsedPresetCount: 1,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final header = find
        .ancestor(
          of: find.text(AppColorPickerKeys.presets.en),
          matching: find.byType(Row),
        )
        .first;
    expect(
      find.descendant(
        of: header,
        matching: find.text(AppColorPickerKeys.morePresets.en),
      ),
      findsOneWidget,
    );
    final moreTop = t.getTopLeft(find.text(AppColorPickerKeys.morePresets.en));
    await t.tap(find.text(AppColorPickerKeys.morePresets.en));
    await t.pump();
    final fewerTop = t.getTopLeft(
      find.text(AppColorPickerKeys.fewerPresets.en),
    );
    expect((moreTop.dy - fewerTop.dy).abs(), lessThan(1));
  });

  testWidgets('preset expansion control is omitted without a collapse limit', (
    t,
  ) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppColorPicker(
            value: null,
            presets: const ['#111111', '#222222', '#333333'],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text(AppColorPickerKeys.morePresets.en), findsNothing);
    expect(find.text(AppColorPickerKeys.fewerPresets.en), findsNothing);
  });

  testWidgets('the color map can start closed and opens on demand', (t) async {
    await t.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AppColorPicker(
              value: '#123456',
              startWithMapClosed: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(_pickerSurfaces(), findsNothing);
    await t.tap(find.text('Custom color'));
    await t.pump();
    expect(_pickerSurfaces(), findsNWidgets(2));
  });
}
