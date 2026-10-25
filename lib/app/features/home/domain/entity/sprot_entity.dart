import 'package:flutter/material.dart';

class SprotEntity {
  final String label;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const SprotEntity({
    required this.label,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}