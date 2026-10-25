// ════════════════════════════════════════════════════════════
//  domain/entities/category_entity.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.productCount = 0,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;
  final int productCount;
}