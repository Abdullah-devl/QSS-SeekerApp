# Seeker Project Skill & Guidelines 🚀

هذا الملف يمثل الدليل المرجعي الكامل للمعايير البرمجية والتصميمية المتبعة في مشروع **Seeker**.

## 1. المعمارية (Architecture) 🏗️
يتبع المشروع نمط **MVVM (Model-View-ViewModel)** مع تقسيم العمل بناءً على **الميزات (Feature-First)**.

- **Directory Structure:**
  - `lib/core`: يحتوي على الخدمات المشتركة، الثيمات، والتنبيهات.
  - `lib/features/{feature_name}`: يحتوي على:
    - `models/`: نماذج البيانات.
    - `viewmodel/`: إدارة الحالة (State Management) ومنطق الواجهة.
    - `views/`: واجهات المستخدم (UI).
    - `repositories/`: التعامل مع البيانات (API/Local).

---

## 2. نظام الألوان (Color System) 🎨
يتم تعريف الألوان في `lib/core/theme/custm_color.dart`.

### ☀️ الوضع الفاتح (Light Mode):
- **Primary:** `#1CB0F6` (أزرق حيوي)
- **Background:** `#F1FAFF`
- **Text:** `#2D3436`
- **Secondary:** `#74B9FF`

### 🌙 الوضع الداكن (Dark Mode):
- **Primary:** `#189AD3` (أزرق هادئ)
- **Background:** `#0A0E10`
- **Text:** `#DFE6E9`
- **Secondary:** `#0984E3`

### 🛠️ ألوان الوظائف (Functional):
- **Success:** `#2ECC71` (أخضر)
- **Error:** `#FF4757` (أحمر)
- **Warning:** `#FFA502` (برتقالي)

---

## 3. التنبيهات والرسائل (Alerts & UI Messages) 🔔
نستخدم كلاس `QSAlerts` الموجود في `lib/core/widgets/qs_alerts.dart` لعرض التنبيهات بتصميم **Glassmorphism**.

### الطرق المتاحة:
```dart
QSAlerts.showSuccess(context, "تمت العملية بنجاح");
QSAlerts.showError(context, "حدث خطأ ما");
QSAlerts.showWarning(context, "يرجى التأكد من البيانات");
QSAlerts.showInfo(context, "معلومات إضافية");
```

---

## 4. الترجمة وتعدد اللغات (Localization) 🌍
التطبيق يدعم العربية والإنجليزية باستخدام `flutter_localizations`.
- ملفات الترجمة (JSON/ARB) تُدار عبر `AppLocalizations`.
- استخدام النصوص في الكود:
```dart
AppLocalizations.of(context)!.translate('key_name')
```

---

## 5. التخزين المحلي (Local Storage) 💾
- **Token Management:** نستخدم `TokenStorage` لإدارة التوكنات بشكل آمن.
- **General Data:** نستخدم `SharedPreferences` للإعدادات البسيطة و `Hive` للبيانات الأكثر تعقيداً.

---

## 6. قواعد عامة للتطوير 📏
- **الخطوط:** نستخدم خط `Cairo` للنصوص العربية لضمان مظهر احترافي.
- **التواصل مع الشبكة:** نستخدم مكتبة `Dio` مع Interceptors لمعالجة الأخطاء والتوكنات.
- **الاستجابة (Responsiveness):** يجب أن تكون الواجهات مرنة وتدعم مختلف أحجام الشاشات.
