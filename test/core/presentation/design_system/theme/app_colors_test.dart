import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';

/// WCAG 2 contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Text needs 4.5:1 (AA); non-text elements (control borders, chart marks)
/// need 3:1.
const _text = 4.5;
const _nonText = 3.0;

void _expectText(String label, Color fg, Color bg) =>
    expect(_contrast(fg, bg), greaterThanOrEqualTo(_text), reason: label);

void _expectNonText(String label, Color fg, Color bg) =>
    expect(_contrast(fg, bg), greaterThanOrEqualTo(_nonText), reason: label);

void main() {
  group('role mapping', () {
    test(
      'light: primary is green-600, page is neutral-50, cards are white',
      () {
        final scheme = AppTheme.light().colorScheme;

        expect(scheme.brightness, Brightness.light);
        expect(scheme.primary, AppColors.green600);
        expect(scheme.onPrimary, AppColors.neutral0);
        expect(scheme.primaryContainer, AppColors.green100);
        expect(scheme.surface, AppColors.neutral0);
        expect(
          AppTheme.light().scaffoldBackgroundColor,
          AppLightColors.background,
        );
        expect(AppLightColors.background, AppColors.neutral50);
      },
    );

    test('dark is a separate design, not an inverted light', () {
      final scheme = AppTheme.dark().colorScheme;

      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, AppDarkColors.primary);
      expect(scheme.primary, isNot(AppLightColors.primary));
      expect(scheme.surface, const Color(0xFF1C1C1C));
      expect(AppTheme.dark().scaffoldBackgroundColor, const Color(0xFF171717));
    });

    test('control borders use outline-control, decorations use outline', () {
      final light = AppTheme.light().colorScheme;
      final dark = AppTheme.dark().colorScheme;

      expect(light.outline, AppLightColors.outlineControl);
      expect(light.outlineVariant, AppLightColors.outline);
      expect(dark.outline, AppDarkColors.outlineControl);
      expect(dark.outlineVariant, AppDarkColors.outline);
    });

    test('scrim and shadow follow the design', () {
      expect(AppLightColors.scrim, const Color(0x99171A19));
      expect(AppDarkColors.scrim, const Color(0xB3000000));
      expect(AppTheme.light().colorScheme.shadow, AppColors.neutral900);
    });

    test('debit and credit are neutral, never red and green', () {
      for (final semantic in [
        AppSemanticColors.light,
        AppSemanticColors.dark,
      ]) {
        for (final c in [semantic.debit, semantic.credit]) {
          // Neutral-ish: the channels stay close to each other.
          final spread =
              [c.red, c.green, c.blue].reduce((a, b) => a > b ? a : b) -
              [c.red, c.green, c.blue].reduce((a, b) => a < b ? a : b);
          expect(spread, lessThan(40));
        }
        expect(semantic.balanceNegative, isNot(semantic.debit));
      }
    });
  });

  group('contrast (WCAG AA)', () {
    test('light text colors on their surface', () {
      const s = AppLightColors.surface;
      _expectText('on-surface', AppLightColors.onSurface, s);
      _expectText('on-surface-variant', AppLightColors.onSurfaceVariant, s);
      _expectText('on-surface-muted', AppLightColors.onSurfaceMuted, s);
      _expectText(
        'on-primary on primary',
        AppLightColors.onPrimary,
        AppLightColors.primary,
      );
      _expectText('primary on surface', AppLightColors.primary, s);
      _expectText(
        'nav-item-active',
        AppLightColors.onPrimaryContainer,
        AppLightColors.primaryContainer,
      );
      _expectText('debit', AppLightColors.debit, s);
      _expectText('credit', AppLightColors.credit, s);
      _expectText('balance-negative', AppLightColors.balanceNegative, s);
      _expectText(
        'balance-negative on page',
        AppLightColors.balanceNegative,
        AppLightColors.background,
      );
    });

    test('dark text colors on their surface', () {
      const s = AppDarkColors.surface;
      _expectText('on-surface', AppDarkColors.onSurface, s);
      _expectText('on-surface-variant', AppDarkColors.onSurfaceVariant, s);
      _expectText('on-surface-muted', AppDarkColors.onSurfaceMuted, s);
      _expectText(
        'on-primary on primary',
        AppDarkColors.onPrimary,
        AppDarkColors.primary,
      );
      _expectText('primary on surface', AppDarkColors.primary, s);
      _expectText(
        'nav-item-active',
        AppDarkColors.onPrimaryContainer,
        AppDarkColors.primaryContainer,
      );
      _expectText('debit', AppDarkColors.debit, s);
      _expectText('credit', AppDarkColors.credit, s);
      _expectText('balance-negative', AppDarkColors.balanceNegative, s);
      _expectText('danger button', AppDarkColors.onError, AppDarkColors.error);
    });

    test('semantic colors on their containers and as solid fills', () {
      for (final (name, semantic, error, errorContainer) in [
        (
          'light',
          AppSemanticColors.light,
          AppLightColors.error,
          AppLightColors.errorContainer,
        ),
        (
          'dark',
          AppSemanticColors.dark,
          AppDarkColors.error,
          AppDarkColors.errorContainer,
        ),
      ]) {
        _expectText(
          '$name success',
          semantic.success,
          semantic.successContainer,
        );
        _expectText(
          '$name warning',
          semantic.warning,
          semantic.warningContainer,
        );
        _expectText('$name info', semantic.info, semantic.infoContainer);
        _expectText('$name error', error, errorContainer);
        // Snackbars use the color as a fill with `onX` text.
        _expectText('$name success fill', semantic.onSuccess, semantic.success);
        _expectText('$name warning fill', semantic.onWarning, semantic.warning);
        _expectText('$name info fill', semantic.onInfo, semantic.info);
      }
    });

    test('the five document status badges', () {
      for (final semantic in [
        AppSemanticColors.light,
        AppSemanticColors.dark,
      ]) {
        for (final status in [
          semantic.statusDraft,
          semantic.statusApproved,
          semantic.statusPosted,
          semantic.statusCanceled,
          semantic.statusReversed,
        ]) {
          _expectText('status badge', status.foreground, status.container);
        }
      }
    });

    test('control borders reach 3:1 on a surface', () {
      _expectNonText(
        'light outline-control',
        AppLightColors.outlineControl,
        AppLightColors.surface,
      );
      _expectNonText(
        'dark outline-control',
        AppDarkColors.outlineControl,
        AppDarkColors.surface,
      );
    });

    test('chart series reach 3:1 on a surface', () {
      expect(AppLightColors.chart, hasLength(8));
      expect(AppDarkColors.chart, hasLength(8));
      for (final c in AppLightColors.chart) {
        _expectNonText('light chart', c, AppLightColors.surface);
      }
      for (final c in AppDarkColors.chart) {
        _expectNonText('dark chart', c, AppDarkColors.surface);
      }
    });
  });
}
