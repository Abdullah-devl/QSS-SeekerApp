import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
          await _tokenStorage.savePolicyAgreement(user.seekerPolicy);
          await _tokenStorage.saveUserData(
            id: user.id,
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
  // 🌐 تسجيل الدخول عبر جوجل (Google Login)
  // ===========================================================================

  Future<UserModel> loginWithGoogle() async {
    try {
      // 1. إنشاء كائن GoogleSignIn مع الـ scopes المطلوبة (الإصدار 6.x)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // serverClientId: Web Client ID لتوليد id_token يمكن التحقق منه في السيرفر
        serverClientId: '507923305565-e3s7epoas985u037hbfb9kv4eefrhr9n.apps.googleusercontent.com',
      );

      // 2. فتح واجهة اختيار حساب جوجل
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء عملية تسجيل الدخول بجوجل');
      }

      // 3. الحصول على التوكنات
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      // 4. إرسال التوكنات للسيرفر
      final response = await _apiService.post(
        ApiEndpoints.googleLogin,
        data: {
          'id_token': idToken,
          if (accessToken != null) 'access_token': accessToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = UserModel.fromJson(response.data);

        // 💾 تخزين البيانات والتوكن فوراً (Store First)
        if (user.token != null) {
          await _tokenStorage.saveToken(user.token!);
          await _tokenStorage.savePolicyAgreement(user.seekerPolicy);
          await _tokenStorage.saveUserData(
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role ?? 'client',
            phone: user.phone,
            address: user.address,
          );
          debugPrint('✅ Google Login: Data stored successfully.');
        }
        
        return user;
      } else {
        throw Exception('فشل تسجيل الدخول عبر جوجل من قبل السيرفر');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'خطأ في الاتصال بالسيرفر');
      }
      rethrow;
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
      // 1. تسجيل الخروج من حساب جوجل (لإجبار النظام على إظهار قائمة الحسابات في المرة القادمة)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        debugPrint('🚪 Google Account signed out successfully.');
      }

      // 2. إبلاغ السيرفر بإلغاء التوكن
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // نتجاهل الخطأ في حال فشل الطلب (مثلاً انقطاع النت)، لأن الهدف هو الخروج المحلي
    } finally {
      // 3. تنظيف البيانات المحلية دائماً حتى لو فشل الطلب
      await _tokenStorage.clearUserData();
    }
  }

  // ===========================================================================
  // 🔐 تغيير كلمة المرور (Change Password)
  // ===========================================================================

  /// يتيح للمستخدم المسجل دخولهم حالياً استبدال كلمة المرور القديمة بأخرى جديدة.
  Future<void> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل تغيير كلمة المرور');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422 || e.response?.statusCode == 400) {
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
  // 👤 الدخول كزائر (Guest Login)
  // ===========================================================================

  /// يقوم بتفعيل وضع الزائر وحفظه محلياً.
  Future<void> loginAsGuest() async {
    await _tokenStorage.clearUserData(); // ضمان عدم وجود بقايا بيانات
    await _tokenStorage.saveGuestMode(true);
  }
}
