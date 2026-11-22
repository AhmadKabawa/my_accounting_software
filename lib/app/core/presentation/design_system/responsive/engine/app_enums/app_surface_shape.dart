part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// SURFACE SHAPE TOKENS (لوحة الإدارة)
// ═══════════════════════════════════════════════════════════════════

/// أنصاف أقطار الأسطح العامة في مكان واحد: تغيير قيمة هنا يغيّر شكل
/// البطاقة الرئيسية والحبات وأدوات الشريط في كل الشاشات.
///
/// - [card]: البطاقة الرئيسية التي تضم الأدوات والفلاتر والبيانات.
/// - [pill]: حبات الحالة، حقل البحث، وعنصر التنقل النشط.
/// - [tableBand]: شريط رأس الجدول.
/// - [control]: أزرار وقوائم شريط الأدوات.
abstract final class AppSurfaceShape {
  AppSurfaceShape._();

  static const AppRadius card = AppRadius.lg;
  static const AppRadius pill = AppRadius.full;
  static const AppRadius tableBand = AppRadius.md;
  static const AppRadius control = AppRadius.md;
}
