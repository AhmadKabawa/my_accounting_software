import 'package:flutter/material.dart';

class CategoryModel {
  final String label;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const CategoryModel({
    required this.label,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}