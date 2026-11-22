import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_saas_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('AppSaasColors', () {
    test('يُسجَّل في الثيمين الفاتح والداكن', () {
      expect(AppTheme.light().extension<AppSaasColors>(), AppSaasColors.light);
      expect(AppTheme.dark().extension<AppSaasColors>(), AppSaasColors.dark);
    });

    test('canvas يختلف عن surface في الفاتح (البطاقة تبرز)', () {
      expect(AppSaasColors.light.canvas, isNot(AppSaasColors.light.surface));
    });

    test('خلفية الـ Scaffold هي canvas', () {
      expect(
        AppTheme.light().scaffoldBackgroundColor,
        AppSaasColors.light.canvas,
      );
      expect(
        AppTheme.dark().scaffoldBackgroundColor,
        AppSaasColors.dark.canvas,
      );
    });

    for (final (name, colors) in [
      ('light', AppSaasColors.light),
      ('dark', AppSaasColors.dark),
    ]) {
      test('$name: تباين حبات الحالة والعنصر النشط ≥ 4.5', () {
        final pairs = <String, (Color, Color)>{
          'success': (
            colors.pillSuccess.foreground,
            colors.pillSuccess.container,
          ),
          'error': (colors.pillError.foreground, colors.pillError.container),
          'warning': (
            colors.pillWarning.foreground,
            colors.pillWarning.container,
          ),
          'info': (colors.pillInfo.foreground, colors.pillInfo.container),
          'neutral': (
            colors.pillNeutral.foreground,
            colors.pillNeutral.container,
          ),
          'selected': (colors.onSelected, colors.selected),
          'tableHeader': (colors.onTableHeader, colors.tableHeaderBand),
        };
        pairs.forEach((label, pair) {
          expect(
            _contrast(pair.$1, pair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '$name/$label',
          );
        });
      });
    }

    test('lerp وcopyWith وتساوي القيم', () {
      const a = AppSaasColors.light;
      expect(a.copyWith(), a);
      expect(a.lerp(AppSaasColors.dark, 0).canvas, a.canvas);
      expect(a.lerp(AppSaasColors.dark, 1).canvas, AppSaasColors.dark.canvas);
      expect(a.hashCode, a.copyWith().hashCode);
    });

    test('الحبة تطابق حاويات الدلالات (مصدر واحد)', () {
      expect(
        AppSaasColors.light.pillSuccess.container,
        AppSemanticColors.light.successContainer,
      );
      expect(
        AppSaasColors.dark.pillInfo.container,
        AppSemanticColors.dark.infoContainer,
      );
    });
  });
}
