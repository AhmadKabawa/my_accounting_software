// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📁 lib/core/storage/storage_service.dart
//
// 🎯 أفضل استراتيجية للتخزين المحلي في Flutter
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  نوع البيانات          │  الأداة المناسبة                              │
// ├─────────────────────────────────────────────────────────────────────────┤
// │  إعدادات بسيطة         │  SharedPreferences  (key-value)               │
// │  بيانات حساسة          │  FlutterSecureStorage (مشفرة)                 │
// │  كائنات/قوائم كبيرة    │  Hive / Isar (NoSQL سريع)                    │
// │  بيانات علائقية        │  Drift / sqflite (SQL)                       │
// │  ملفات/صور             │  path_provider + dart:io                     │
// └─────────────────────────────────────────────────────────────────────────┘
//
// 🔑 الاستراتيجية المثلى (3 طبقات):
//   1. SecureStorage  → Token, بيانات تسجيل الدخول
//   2. SharedPreferences → إعدادات المستخدم، Theme, Language
//   3. Hive/Isar     → Cache للـ API responses (مع TTL)
//
// 🔑 SOLID: Dependency Inversion
//   نعرف interface واحدة، والـ implementations تتبادل بسهولة
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Interface عامة للتخزين ───────────────────────────────────────────────────
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';

abstract interface class StorageService {
  Future<void> write<T>(StorageKey key, T value);
  Future<T?> read<T>(StorageKey key);
  Future<void> delete(StorageKey key);
  Future<void> clearAll();
  Future<bool> containsKey(StorageKey key);
}
