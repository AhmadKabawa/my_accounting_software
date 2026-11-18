// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

/// Loads the app's real texts (every registered `AppKey`) into
/// easy_localization, so a widget under test shows `key.ar` / `key.en`.
void useTranslations(Locale locale) {
  final english = locale.languageCode == 'en';
  Localization.load(
    locale,
    translations: Translations(
      MyDartLoader.build(allKeys, (k) => english ? k.en : k.ar),
    ),
  );
}

/// What `EasyLocalization` provides in the real app: without a
/// `Localization` delegate in the tree, `AppKey.tr(context: context)` (used by
/// `AppText`) throws.
class _LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const _LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Localization> load(Locale locale) =>
      SynchronousFuture<Localization>(Localization.instance);

  @override
  bool shouldReload(covariant LocalizationsDelegate<Localization> old) => false;
}

/// A [MaterialApp] with the app theme, the localization delegate, a forced
/// text [direction] (RTL by default, as the product is Arabic-first) and an
/// optional [textScale]. Pass [home], or a [router] for go_router tests.
///
/// The locale stays `en` on purpose: the Material delegates have no Arabic
/// here. The language of the texts is chosen with [useTranslations].
Widget buildTestApp({
  Widget? home,
  RouterConfig<Object>? router,
  ThemeData? theme,
  TextDirection direction = TextDirection.rtl,
  double textScale = 1,
}) {
  Widget builder(BuildContext context, Widget? child) => Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  );

  const delegates = <LocalizationsDelegate<dynamic>>[_LocalizationDelegate()];
  final appTheme = theme ?? AppTheme.light();

  if (router != null) {
    return MaterialApp.router(
      routerConfig: router,
      theme: appTheme,
      localizationsDelegates: delegates,
      builder: builder,
    );
  }
  return MaterialApp(
    theme: appTheme,
    localizationsDelegates: delegates,
    builder: builder,
    home: home,
  );
}

/// Sets the logical screen size of a widget test (device pixel ratio 1) and
/// restores it afterwards.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
