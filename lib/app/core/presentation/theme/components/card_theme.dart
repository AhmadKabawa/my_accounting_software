import 'package:flutter/material.dart';

CardThemeData buildCardTheme(BuildContext contex,  {required ColorScheme colorScheme}) {
  return CardThemeData(
    color: colorScheme.surface, // لون الكارد من ColorScheme
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}
