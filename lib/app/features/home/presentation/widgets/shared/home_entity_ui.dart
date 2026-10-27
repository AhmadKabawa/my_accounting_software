import 'package:flutter/material.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';
import 'package:accounting_software/app/features/home/domain/entity/category_entity.dart';

const _categoryIcons = <String, IconData>{
  'hiking': Icons.terrain_rounded,
  'cycling': Icons.directions_bike_rounded,
  'running': Icons.directions_run_rounded,
  'climbing': Icons.social_distance_rounded,
  'snow': Icons.ac_unit_rounded,
  'swimming': Icons.pool_rounded,
  'yoga': Icons.self_improvement_rounded,
};

extension HeroBannerEntityUi on HeroBannerEntity {
  Color get accentColor => Color(accentColorValue);
}

extension CategoryEntityUi on CategoryEntity {
  Color get accentColor => Color(accentColorValue);

  IconData get icon => _categoryIcons[iconKey] ?? Icons.category_rounded;
}
