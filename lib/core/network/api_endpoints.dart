import 'dart:io';
import 'package:flutter/foundation.dart';

/// � اسم الملف: api_endpoints.dart
/// 📝 الوصف: يحتوي هذا الملف على جميع روابط الـ API المستخدمة في التطبيق.
/// الهدف منه هو تجميع الروابط في مكان واحد لسهولة التعديل والإدارة.

class ApiEndpoints {
  /// 🌐 النطاق الأساسي (Domain) للسيرفر.
  /// يتم استخدامه كأساس لجميع الروابط الأخرى.
  // static String get domain => "http://10.0.2.2:8000";
  static String get domain => "http://127.0.0.1:8000";
  // static String get domain => "http://192.168.43.245:8000";
  // static String get domain => "http://localhost:8000/api";

  /// 🗄️ رابط التخزين (Storage).
  /// يستخدم للوصول إلى الملفات والصور المخزنة على السيرفر.
  static String get storageBaseUrl => "$domain/storage/";

  /// 🔗 الرابط الأساسي للـ API (Base URL).
  /// يحتوي على المنطق لتحديد الرابط المناسب بناءً على بيئة التشغيل.
  static String get baseUrl {
    // يمكن إضافة شروط هنا لتغيير الرابط إذا كان التطبيق يعمل على الويب أو المحاكي.
    // حالياً يتم إرجاع رابط الـ API المعتمد على النطاق الأساسي.
    return "$domain/api";
  }

  // ===========================================================================
  // 🔐 روابط المصادقة (Auth Endpoints)
  // ===========================================================================

  /// 🔑 رابط تسجيل الدخول.
  static String get login => "$baseUrl/login";

  /// 📝 رابط إنشاء حساب جديد.
  static String get register => "$baseUrl/register";

  /// 🚪 رابط تسجيل الخروج.
  static String get logout => "$baseUrl/logout";

  /// ✅ رابط تفعيل البريد الإلكتروني (OTP).
  static String get verifyEmail => "$baseUrl/verify-email-code";

  /// 🔄 رابط إعادة إرسال كود التفعيل.
  static String get resendVerificationCode =>
      "$baseUrl/resend-verification-code";

  // ===========================================================================
  // 🏠 روابط الصفحة الرئيسية (Home Endpoints)
  // ===========================================================================

  /// 📊 رابط جلب بيانات الصفحة الرئيسية العامة.
  static String get getHomeData => "$baseUrl/home";

  /// 🗂️ رابط جلب قائمة التصنيفات (Categories).
  static String get categories => "$baseUrl/categories";

  /// ⭐ رابط جلب الخدمات الشائعة (Popular Services).
  static String get popularServices => "$baseUrl/popular-services";

  /// 📂 رابط جلب تفاصيل التصنيف (خدمات، تصنيفات فرعية، موصى بهم).
  /// [id] هو معرف التصنيف.
  // static String categoryDetails(int id) => "$baseUrl/categories/$id";
  static String categoryDetails(int id) => "$baseUrl/categories/$id";

  static String get beProvider => "$baseUrl/provider-requests";
}
