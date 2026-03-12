import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

/// 📂 اسم الملف: auth_repository.dart
/// 📝 الوصف: المستودع (Repository) الخاص بعمليات المصادقة.
/// وظيفته الربط بين طبقة الـ ViewModel وطبقة البيانات (API & Storage).
/// يقوم بتنفيذ عمليات تسجيل الدخول، التسجيل، والخروج، ومعالجة البيانات قبل إرجاعها.

class AuthRepository {
  final ApiService _apiService; // خدمة الاتصال بالشبكة
  final TokenStorage _tokenStorage; // خدمة التخزين المحلي

  AuthRepository(this._apiService, this._tokenStorage);

  // ===========================================================================
  // ✅ تفعيل البريد الإلكتروني (Verify Email)
  // ===========================================================================

  /// يقوم بإرسال كود التفعيل (OTP) والبريد الإلكتروني للسيرفر.
  Future<void> verifyEmail(String email, String otp) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'code': otp},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'فشل تفعيل البريد الإلكتروني: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422) {
          final data = e.response?.data;
          String errorMessage = data['message'] ?? 'بيانات غير صالحة';

          if (data['errors'] != null && data['errors'] is Map) {
            final errorsMap = data['errors'] as Map<String, dynamic>;
            final messages = <String>[];
            errorsMap.forEach((key, value) {
              if (value is List) {
                messages.addAll(value.map((v) => v.toString()));
              } else {
                messages.add(value.toString());
              }
            });
            if (messages.isNotEmpty) {
              errorMessage = messages.join('\n');
            }
          }
          throw Exception(errorMessage);
        }
      }
      rethrow;
    }
  }

  /// 🔄 إعادة إرسال كود التفعيل (Resend Verification Code)
  Future<void> resendVerificationCode(String email) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.resendVerificationCode,
        data: {'email': email},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل إعادة إرسال الكود: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422) {
          final data = e.response?.data;
          String errorMessage = data['message'] ?? 'بيانات غير صالحة';

          if (data['errors'] != null && data['errors'] is Map) {
            final errorsMap = data['errors'] as Map<String, dynamic>;
            final messages = <String>[];
            errorsMap.forEach((key, value) {
              if (value is List) {
                messages.addAll(value.map((v) => v.toString()));
              } else {
                messages.add(value.toString());
              }
            });
            if (messages.isNotEmpty) {
              errorMessage = messages.join('\n');
            }
          }
          throw Exception(errorMessage);
        }
      }
      rethrow;
    }
  }

  // ===========================================================================
  // 🔐 تسجيل الدخول (Login)
  // ===========================================================================

  /// يقوم بإرسال البريد وكلمة المرور للسيرفر.
  /// في حال النجاح، يقوم بحفظ التوكن وبيانات المستخدم محلياً.
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      // التحقق من نجاح الطلب (200 OK أو 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // تحويل الاستجابة إلى موديل مستخدم
        final user = UserModel.fromJson(response.data);

        // حفظ التوكن وبيانات المستخدم فقط إذا كان الحساب مفعلاً
        if (user.isVerified && user.token != null) {
          await _tokenStorage.saveToken(user.token!);
          await _tokenStorage.saveUserData(
            name: user.name,
            email: user.email,
            role:
                user.role ??
                'client', // القيمة الافتراضية 'client' في حال عدم توفر الدور
            phone: user.phone,
            address: user.address,
          );
        }

        return user;
      } else {
        throw Exception('فشل تسجيل الدخول: ${response.statusMessage}');
      }
    } catch (e) {
      // معالجة الأخطاء القادمة من Dio
      if (e is DioException) {
        // خطأ 401: بيانات الدخول غير صحيحة
        if (e.response?.statusCode == 401) {
          throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        }
        // خطأ 422: فشل التحقق من البيانات (Validation Error)
        if (e.response?.statusCode == 422) {
          final data = e.response?.data;
          String errorMessage = data['message'] ?? 'بيانات غير صالحة';

          // تجميع رسائل الأخطاء التفصيلية من السيرفر
          if (data['errors'] != null && data['errors'] is Map) {
            final errorsMap = data['errors'] as Map<String, dynamic>;
            final messages = <String>[];
            errorsMap.forEach((key, value) {
              if (value is List) {
                messages.addAll(value.map((v) => v.toString()));
              } else {
                messages.add(value.toString());
              }
            });
            if (messages.isNotEmpty) {
              errorMessage = messages.join('\n');
            }
          }
          throw Exception(errorMessage);
        }
      }
      rethrow; // إعادة رمي الخطأ في حال لم نتمكن من معالجته هنا
    }
  }

  // ===========================================================================
  // 📝 إنشاء حساب جديد (Register)
  // ===========================================================================

  // /// يقوم بإنشاء حساب جديد للمستخدم.
  // Future<UserModel> register({
  //   required String name,
  //   required String email,
  //   required String password,
  //   required String passwordConfirmation,
  //   required bool isAgreed,
  // }) async {
  //   try {
  //     final response = await _apiService.post(
  //       ApiEndpoints.register,
  //       data: {
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'password_confirmation': passwordConfirmation,
  //         'seeker_policy': isAgreed ? 1 : 0, // إرسال 1 للموافقة على الشروط
  //       },
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       try {
  //         final user = UserModel.fromJson(response.data);
  //         return user;
  //       } catch (_) {
  //         // حالة خاصة: إذا نجح التسجيل ولكن الرد لا يحتوي على بيانات المستخدم الكاملة
  //         return UserModel(id: 0, name: '', email: email, role: 'client');
  //       }
  //     } else {
  //       throw Exception('فشل إنشاء الحساب: ${response.statusMessage}');
  //     }
  //   } catch (e) {
  //     // نفس منطق معالجة الأخطاء في تسجيل الدخول
  //     if (e is DioException) {
  //       if (e.response?.statusCode == 422) {
  //         final data = e.response?.data;
  //         String errorMessage = data['message'] ?? 'بيانات غير صالحة';

  //         if (data['errors'] != null && data['errors'] is Map) {
  //           final errorsMap = data['errors'] as Map<String, dynamic>;
  //           final messages = <String>[];
  //           errorsMap.forEach((key, value) {
  //             if (value is List) {
  //               messages.addAll(value.map((v) => v.toString()));
  //             } else {
  //               messages.add(value.toString());
  //             }
  //           });
  //           if (messages.isNotEmpty) {
  //             errorMessage = messages.join('\n');
  //           }
  //         }
  //         throw Exception(errorMessage);
  //       }
  //     }
  //     rethrow;
  //   }
  // }
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required bool isAgreed,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'seeker_policy': isAgreed ? 1 : 0,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception('فشل إنشاء الحساب');
  }

  // ===========================================================================
  // 🚪 تسجيل الخروج (Logout)
  // ===========================================================================

  /// يقوم بتسجيل الخروج من السيرفر ومسح البيانات المحلية.
  Future<void> logout() async {
    try {
      // إبلاغ السيرفر بإلغاء التوكن
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // نتجاهل الخطأ في حال فشل الطلب (مثلاً انقطاع النت)، لأن الهدف هو الخروج المحلي
    } finally {
      // تنظيف البيانات المحلية دائماً حتى لو فشل الطلب
      await _tokenStorage.clearUserData();
    }
  }

  // ===========================================================================
  // 👤 الدخول كزائر (Guest Login)
  // ===========================================================================

  /// يقوم بتفعيل وضع الزائر وحفظه محلياً.
  Future<void> loginAsGuest() async {
    await _tokenStorage.clearUserData(); // ضمان عدم وجود بقايا بيانات
    await _tokenStorage.saveGuestMode(true);
  }
}
