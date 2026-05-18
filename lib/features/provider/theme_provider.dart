import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 📂 اسم الملف: theme_provider.dart
/// 📝 الوصف: مزود حالة (Provider) لإدارة ثيم التطبيق (فاتح/داكن).
/// يقوم بحفظ اختيار المستخدم في الذاكرة المحلية (SharedPreferences) وتطبيقه عند التشغيل.

class ThemeProvider extends ChangeNotifier {
  // مفتاح الحفظ في SharedPreferences
  static const String themeKey = 'isDarkMode';

  ThemeMode _themeMode = ThemeMode.system; // الوضع الافتراضي يتبع النظام
  ThemeMode get themeMode => _themeMode;

  /// 🌙 هل الثيم الحالي داكن؟
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider({bool? initialDarkMode}) {
    if (initialDarkMode != null) {
      _themeMode = initialDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      loadTheme(); // تحميل الثيم المحفوظ عند إنشاء الكلاس
    }
  }

  /// 📥 تحميل الثيم المحفوظ من الذاكرة المحلية.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(themeKey);

    // إذا لم تكن هناك قيمة محفوظة (null)، نستخدم إعدادات النظام
    _themeMode = isDark == null
        ? ThemeMode.system
        : (isDark ? ThemeMode.dark : ThemeMode.light);

    notifyListeners(); // إعلام المستمعين (الواجهات) بالتغيير
  }

  /// 🔄 التبديل بين الوضع الفاتح والداكن يدوياً.
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await prefs.setBool(themeKey, false); // حفظ كـ Light
    } else {
      _themeMode = ThemeMode.dark;
      await prefs.setBool(themeKey, true); // حفظ كـ Dark
    }

    notifyListeners();
  }

  /// ⚙️ (اختياري) ضبط الثيم مباشرة لوضع محدد (System, Light, Dark).
  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = mode;

    if (mode == ThemeMode.system) {
      await prefs.remove(themeKey); // إزالة التفضيل ليعود للنظام
    } else {
      await prefs.setBool(themeKey, mode == ThemeMode.dark);
    }

    notifyListeners();
  }
}
