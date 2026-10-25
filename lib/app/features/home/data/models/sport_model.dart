import 'package:flutter/material.dart';

class SprotModel {
  final String label;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const SprotModel({
    required this.label,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}
