// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📁 lib/core/services/local_storage/hive_storage/hive_manager.dart
//
// 🗄️ HiveManager = نقطة التهيئة المركزية لـ Hive
//
// مسؤوليته:
//   - تهيئة Hive مرة واحدة عند بدء التطبيق
//   - تسجيل جميع الـ TypeAdapters
//   - فتح جميع الـ Boxes
//   - توفير الـ Boxes للـ DI
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:hive_flutter/hive_flutter.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_box_names.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

// ─── أسماء الـ Boxes ثوابت (لتجنب typos) ─────────────────────────────────────

class HiveManager {
  HiveManager._(); // Singleton — لا يُنشأ مباشرة
  static const int productTypeId = 1;
  // ─── التهيئة الكاملة (استدعها في main.dart قبل runApp) ────────────────────
  static Future<void> init() async {
    // 1. تهيئة Hive مع Flutter path
    await Hive.initFlutter();

    // 2. تسجيل الـ TypeAdapters (مرتبة حسب typeId)
    _registerAdapters();

    // 3. فتح جميع الـ Boxes
    await _openBoxes();
  }

  // ─── تسجيل الـ Adapters ────────────────────────────────────────────────────
  static void _registerAdapters() {
    // تحقق أولاً قبل التسجيل (تجنب خطأ التسجيل المزدوج)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    // if (!Hive.isAdapterRegistered(ProductModelAdapter.typeId)) {
    //   Hive.registerAdapter(ProductModelAdapter());
    // }
    // أضف هنا كل adapter جديد
  }

  // ─── فتح الـ Boxes ─────────────────────────────────────────────────────────
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<String>(HiveBoxNames.cache),
      Hive.openBox<UserModel>(HiveBoxNames.users),
      // Hive.openBox<ProductModel>(HiveBoxNames.products),
    ]);
  }

  // ─── Getters للـ DI ────────────────────────────────────────────────────────
  static Box<String> get cacheBox => Hive.box<String>(HiveBoxNames.cache);
  static Box<UserModel> get usersBox => Hive.box<UserModel>(HiveBoxNames.users);
  // static Box<ProductModel> get productsBox =>
  //     Hive.box<ProductModel>(HiveBoxNames.products);

  // ─── إغلاق كل شيء (عند الحاجة) ────────────────────────────────────────────
  static Future<void> closeAll() async => Hive.close();

  // ─── حذف كل البيانات (Reset كامل) ─────────────────────────────────────────
  static Future<void> deleteAll() async {
    await Future.wait([
      cacheBox.clear(),
      usersBox.clear(),
      // productsBox.clear(),
    ]);
  }
}
