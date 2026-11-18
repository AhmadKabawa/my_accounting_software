import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';

import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _message = ErrorKeys.validation;
const _title = MessageKeys.validationTitle;

Future<void> _pump(
  WidgetTester tester,
  InlineBanner banner, {
  ThemeData? theme,
  TextDirection direction = TextDirection.rtl,
  double width = 360,
  double textScale = 1,
}) {
  setScreenSize(tester, Size(width, 800));
  return tester.pumpWidget(
    buildTestApp(
      theme: theme,
      direction: direction,
      textScale: textScale,
      home: Scaffold(body: Column(children: [banner])),
    ),
  );
}

BoxDecoration _surface(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(InlineBanner),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  group('variants: colors from the theme, in light and dark', () {
    for (final (themeName, theme, semantic) in [
      ('light', AppTheme.light(), AppSemanticColors.light),
      ('dark', AppTheme.dark(), AppSemanticColors.dark),
    ]) {
      final expected = {
        InlineBannerVariant.success: (
          semantic.successContainer,
          semantic.success,
          AppIcons.success,
        ),
        InlineBannerVariant.error: (
          theme.colorScheme.errorContainer,
          theme.colorScheme.error,
          AppIcons.error,
        ),
        InlineBannerVariant.warning: (
          semantic.warningContainer,
          semantic.warning,
          AppIcons.warning,
        ),
        InlineBannerVariant.info: (
          semantic.infoContainer,
          semantic.info,
          AppIcons.info,
        ),
      };

      for (final variant in InlineBannerVariant.values) {
        testWidgets('${variant.name} in $themeName', (tester) async {
          final (container, foreground, icon) = expected[variant]!;
          await _pump(
            tester,
            InlineBanner(
              variant: variant,
              titleKey: _title,
              messageKey: _message,
            ),
            theme: theme,
          );

          final surface = _surface(tester);
          expect(surface.color, container);
          expect((surface.border! as Border).top.color, foreground);

          // Text and icon use the same foreground color.
          expect(
            tester.widget<Text>(find.text(_message.ar)).style?.color,
            foreground,
          );
          expect(
            tester.widget<Text>(find.text(_title.ar)).style?.color,
            foreground,
          );
          final shown = tester.widget<AppIcon>(find.byType(AppIcon));
          expect(shown.icon, icon);
          expect(shown.color, foreground);
        });
      }
    }
  });

  group('content', () {
    testWidgets('shows the message, and the title only when given', (
      tester,
    ) async {
      await _pump(tester, const InlineBanner(messageKey: _message));
      expect(find.text(_message.ar), findsOneWidget);
      expect(find.text(_title.ar), findsNothing);

      await _pump(
        tester,
        const InlineBanner(messageKey: _message, titleKey: _title),
      );
      expect(find.text(_message.ar), findsOneWidget);
      expect(find.text(_title.ar), findsOneWidget);
    });

    testWidgets('follows the current language', (tester) async {
      useTranslations(const Locale('en'));
      await _pump(
        tester,
        const InlineBanner(messageKey: _message, titleKey: _title),
        direction: TextDirection.ltr,
      );

      expect(find.text(_message.en), findsOneWidget);
      expect(find.text(_title.en), findsOneWidget);
    });

    testWidgets('the icon can be hidden', (tester) async {
      await _pump(
        tester,
        const InlineBanner(messageKey: _message, showIcon: false),
      );

      expect(find.byType(AppIcon), findsNothing);
    });

    testWidgets('a long text wraps at 2x text scale and is not clipped', (
      tester,
    ) async {
      const longKey = TestKey(
        'a-long-message-that-has-to-wrap-over-several-lines-at-a-narrow-'
        'width-and-a-large-text-scale-without-being-cut-off-or-overflowing',
      );
      await _pump(
        tester,
        const InlineBanner(
          messageKey: longKey,
          titleKey: _title,
          onDismiss: _noop,
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.text(longKey.key));
      expect(text.maxLines, isNull);
      expect(text.overflow, isNull);
    });
  });

  group('closing', () {
    testWidgets('has no close button without onDismiss', (tester) async {
      await _pump(tester, const InlineBanner(messageKey: _message));

      expect(find.byType(AppIconButton), findsNothing);
    });

    testWidgets('onDismiss shows a close button that calls it', (tester) async {
      var closed = 0;
      await _pump(
        tester,
        InlineBanner(messageKey: _message, onDismiss: () => closed++),
      );

      expect(find.byType(AppIconButton), findsOneWidget);
      await tester.tap(find.byType(AppIconButton));

      expect(closed, 1);
    });

    testWidgets('the banner does not remove itself: the parent decides', (
      tester,
    ) async {
      await _pump(tester, InlineBanner(messageKey: _message, onDismiss: () {}));
      await tester.tap(find.byType(AppIconButton));
      await tester.pump();

      expect(find.byType(InlineBanner), findsOneWidget);
    });
  });

  group('direction', () {
    testWidgets('RTL: icon at the right, close button at the left', (
      tester,
    ) async {
      await _pump(tester, InlineBanner(messageKey: _message, onDismiss: () {}));

      final text = tester.getCenter(find.text(_message.ar)).dx;
      final icon = tester.getCenter(find.byType(AppIcon).first).dx;
      final close = tester.getCenter(find.byType(AppIconButton)).dx;
      expect(icon, greaterThan(text));
      expect(close, lessThan(text));
    });

    testWidgets('LTR: icon at the left, close button at the right', (
      tester,
    ) async {
      useTranslations(const Locale('en'));
      await _pump(
        tester,
        InlineBanner(messageKey: _message, onDismiss: () {}),
        direction: TextDirection.ltr,
      );

      final text = tester.getCenter(find.text(_message.en)).dx;
      final icon = tester.getCenter(find.byType(AppIcon).first).dx;
      final close = tester.getCenter(find.byType(AppIconButton)).dx;
      expect(icon, lessThan(text));
      expect(close, greaterThan(text));
    });
  });

  group('density', () {
    Future<double> heightWith(
      WidgetTester tester,
      AppDensity? density,
      double width,
    ) async {
      final banner = InlineBanner(messageKey: _message, onDismiss: () {});
      setScreenSize(tester, Size(width, 900));
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Column(
              children: [
                density == null
                    ? banner
                    : AppDensityScope(density: density, child: banner),
              ],
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(InlineBanner)).height;
    }

    testWidgets('compact is shorter on a desktop screen', (tester) async {
      final comfortable = await heightWith(tester, null, 1400);
      final compact = await heightWith(tester, AppDensity.compact, 1400);

      expect(compact, lessThan(comfortable));
    });

    testWidgets('compact never changes a phone', (tester) async {
      final comfortable = await heightWith(tester, null, 360);
      final compact = await heightWith(tester, AppDensity.compact, 360);

      expect(compact, comfortable);
    });
  });

  group('accessibility and text selection', () {
    testWidgets('the content is a live region named by its kind', (
      tester,
    ) async {
      await _pump(
        tester,
        const InlineBanner(
          variant: InlineBannerVariant.warning,
          messageKey: _message,
        ),
      );

      final live = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(InlineBanner),
              matching: find.byType(Semantics),
            ),
          )
          .where((s) => s.properties.liveRegion == true)
          .toList();
      expect(live, hasLength(1));
      expect(live.single.properties.label, MessageKeys.warningLabel.ar);
    });

    testWidgets('the text is selectable by default and can be turned off', (
      tester,
    ) async {
      await _pump(tester, const InlineBanner(messageKey: _message));
      expect(find.byType(SelectionArea), findsOneWidget);

      await _pump(
        tester,
        const InlineBanner(messageKey: _message, selectable: false),
      );
      expect(find.byType(SelectionArea), findsNothing);
    });
  });
}

void _noop() {}
