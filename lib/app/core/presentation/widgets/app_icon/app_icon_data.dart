import 'package:flutter/widgets.dart';

/// Describes where an icon comes from, without drawing it.
///
/// Screens never pass `IconData` or asset paths: they pass an entry of
/// `AppIcons`, so swapping an icon (Material → SVG) is a one-line change there.
sealed class AppIconData {
  const AppIconData();

  const factory AppIconData.material(IconData data) = MaterialIconData;
  const factory AppIconData.svg(String asset) = SvgIconData;
  const factory AppIconData.networkSvg(String url) = NetworkSvgIconData;
  const factory AppIconData.image(String asset) = ImageIconData;
  const factory AppIconData.networkImage(String url) = NetworkImageIconData;
}

final class MaterialIconData extends AppIconData {
  const MaterialIconData(this.data);
  final IconData data;
}

final class SvgIconData extends AppIconData {
  const SvgIconData(this.asset);
  final String asset;
}

final class NetworkSvgIconData extends AppIconData {
  const NetworkSvgIconData(this.url);
  final String url;
}

final class ImageIconData extends AppIconData {
  const ImageIconData(this.asset);
  final String asset;
}

final class NetworkImageIconData extends AppIconData {
  const NetworkImageIconData(this.url);
  final String url;
}
