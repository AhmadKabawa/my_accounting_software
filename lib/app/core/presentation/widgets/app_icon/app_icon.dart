import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_tone.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
export 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
export 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_tone.dart';

/// Draws an [AppIconData] at a responsive size ([AppIconSize] token).
///
/// Not tappable on purpose: a tappable icon is an `AppIconButton`, which
/// guarantees the minimum touch target.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIconSize.md,
    this.color,
    this.tone,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  }) : pixelSize = null;

  /// An exact pixel size, for components that already resolved theirs
  /// (e.g. `AppButtonStyle`). Screens use the token constructor instead.
  const AppIcon.fixed(
    this.icon, {
    super.key,
    required double this.pixelSize,
    this.color,
    this.tone,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  }) : size = AppIconSize.md;

  final AppIconData icon;
  final double? pixelSize;
  final AppIconSize size;

  /// Explicit tint retained for compatibility. When both [tone] and [color]
  /// are supplied, [color] wins.
  final Color? color;
  final AppIconTone? tone;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final px = pixelSize ?? context.ui.icon.size(size);
    final tint = color ?? _toneColor(context) ?? _defaultColor(context);

    Widget child = switch (icon) {
      MaterialIconData(:final data) => Icon(data, size: px, color: tint),
      SvgIconData(:final asset) => SvgPicture.asset(
        asset,
        width: px,
        height: px,
        colorFilter: _filter(tint),
        fit: fit,
      ),
      NetworkSvgIconData(:final url) => SvgPicture.network(
        url,
        width: px,
        height: px,
        colorFilter: _filter(tint),
        fit: fit,
        placeholderBuilder: (_) => _placeholder(context, px),
      ),
      ImageIconData(:final asset) => _tinted(
        Image.asset(asset, width: px, height: px, fit: fit),
        tint,
      ),
      NetworkImageIconData(:final url) => Image.network(
        url,
        width: px,
        height: px,
        fit: fit,
        color: tint,
        colorBlendMode: tint != null ? BlendMode.srcIn : null,
        loadingBuilder: (_, image, progress) =>
            progress == null ? image : _placeholder(context, px),
        errorBuilder: (_, _, _) => SizedBox.square(
          dimension: px,
          child: AppIcon.fixed(AppIcons.brokenImage, pixelSize: px * 0.7),
        ),
      ),
    };

    if (semanticsLabel != null) {
      child = Semantics(
        label: semanticsLabel,
        image: icon is! MaterialIconData,
        child: child,
      );
    }
    return child;
  }

  Color? _toneColor(BuildContext context) {
    final colors = context.ui.theme.colors;
    final semantic = context.ui.theme.semanticColors;
    return switch (tone) {
      AppIconTone.neutral => colors.onSurface,
      AppIconTone.primary => colors.primary,
      AppIconTone.success => semantic.success,
      AppIconTone.warning => semantic.warning,
      AppIconTone.info => semantic.info,
      AppIconTone.danger => colors.error,
      null => null,
    };
  }

  ColorFilter? _filter(Color? tint) =>
      tint == null ? null : ColorFilter.mode(tint, BlendMode.srcIn);

  Widget _tinted(Widget image, Color? tint) => tint == null
      ? image
      : ColorFiltered(
          colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          child: image,
        );

  Widget _placeholder(BuildContext context, double px) => SizedBox.square(
    dimension: px,
    child: Center(
      child: SizedBox.square(
        dimension: px * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: AppBorderWidth.thick.of(context),
        ),
      ),
    ),
  );

  Color? _defaultColor(BuildContext context) =>
      icon is MaterialIconData ? Theme.of(context).colorScheme.onSurface : null;
}
