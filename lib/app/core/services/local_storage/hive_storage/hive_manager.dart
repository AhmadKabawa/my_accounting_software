// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📁 lib/core/services/local_storage/hive_storage/hive_manager.dart
//
// 🗄️ HiveManager = نقطة التهيئة المركزية لـ Hive
//
// مسؤوليته:
//   - تهيئة Hive مرة واحدة عند بدء التطبيق
//   - فتح صندوق الـ cache العام
//   - openBox: تسجيل adapter وفتح صندوق خاص بميزة (دون استيراد أي ميزة هنا)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:hive_flutter/hive_flutter.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_box_names.dart';

// ─── أسماء الـ Boxes ثوابت (لتجنب typos) ─────────────────────────────────────

class HiveManager {
  HiveManager._(); // Singleton — لا يُنشأ مباشرة
  static final List<String> _featureBoxes = [];
  // ─── التهيئة الكاملة (استدعها في main.dart قبل runApp) ────────────────────
  static Future<void> init() async {
    // 1. تهيئة Hive مع Flutter path
    await Hive.initFlutter();

    // 2. فتح صندوق الـ cache العام (الميزات تفتح صناديقها عبر openBox)
    await Hive.openBox<String>(HiveBoxNames.cache);
  }

  /// تسجّل الميزة الـ adapter الخاص بها وتفتح صندوقها من خلال هذه الدالة،
  /// فلا يحتاج core إلى معرفة أي نموذج يخص ميزة بعينها.
  static Future<Box<T>> openBox<T>(
    String name, {
    TypeAdapter<T>? adapter,
  }) async {
    if (adapter != null && !Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
    if (!_featureBoxes.contains(name)) _featureBoxes.add(name);
    return Hive.openBox<T>(name);
  }

  // ─── Getters للـ DI ────────────────────────────────────────────────────────
  static Box<String> get cacheBox => Hive.box<String>(HiveBoxNames.cache);

  // ─── إغلاق كل شيء (عند الحاجة) ────────────────────────────────────────────
  static Future<void> closeAll() async => Hive.close();

  // ─── حذف كل البيانات (Reset كامل) ─────────────────────────────────────────
  static Future<void> deleteAll() async {
    await Future.wait([
      cacheBox.clear(),
      for (final name in _featureBoxes) Hive.box<dynamic>(name).clear(),
    ]);
  }
}
