import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Imports --- (استيراد الملفات اللازمة)
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/app_theme.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/features/auth/viewmodel/register_view_model.dart';
import 'package:seeker/features/auth/views/register_view.dart';
import 'package:seeker/features/home/views/home_view.dart';
import 'package:seeker/features/provider/theme_provider.dart';

// ViewModels
import 'package:seeker/features/auth/viewmodel/login_view_model.dart';
import 'package:seeker/features/intro/viewmodels/welcome_view_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/settings/viewmodels/settings_view_model.dart'; // ✅ تمت الإضافة

// Views
import 'package:seeker/features/auth/views/login_view.dart';
import 'package:seeker/features/intro/splash_view.dart';
import 'package:seeker/features/intro/welcome_view.dart';
import 'package:seeker/features/auth/views/terms_view.dart';
import 'package:seeker/features/auth/views/verify_email_view.dart';
import 'package:seeker/features/settings/views/settings_view.dart'; // ✅ تمت الإضافة

// Repositories
import 'package:seeker/features/auth/repositories/auth_repository.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';

import 'dart:io';

/// 📂 اسم الملف: main.dart
/// 📝 الوصف: نقطة انطلاق التطبيق (Entry Point).
/// يقوم بتهيئة الاعتمادات (Dependency Injection) باستخدام Provider، وإعداد الثيم، واللغة، والمسارات (Routes).

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global =
      BadCertificateHttpOverrides(); // ⚠️ هام: لتجاوز مشكلة شهادات SSL أثناء التطوير

  runApp(
    MultiProvider(
      // ==========================================================
      // 🛠️ حقن الاعتمادات (Dependency Injection) لكامل التطبيق
      // يتم ترتيبها بحيث يعتمد كل Provide على ما قبله إذا لزم
      // ==========================================================
      providers: [
        // ----------------------------------------------------------
        // 1️⃣ الطبقة الأساسية (Core Layer)
        // ----------------------------------------------------------
        Provider<TokenStorage>(
          create: (_) => TokenStorage(),
        ), // تخزين التوكن محلياً
        // ApiService يعتمد على TokenStorage لإرفاق التوكن في الطلبات
        ProxyProvider<TokenStorage, ApiService>(
          update: (_, tokenStorage, __) => ApiService(tokenStorage),
        ),

        // ----------------------------------------------------------
        // 2️⃣ طبقة المستودعات (Repository Layer)
        // ----------------------------------------------------------
        // AuthRepository يعتمد على ApiService للاتصال و TokenStorage للحفظ
        ProxyProvider2<ApiService, TokenStorage, AuthRepository>(
          update: (_, apiService, tokenStorage, __) =>
              AuthRepository(apiService, tokenStorage),
        ),

        // HomeRepository يعتمد على ApiService فقط
        ProxyProvider<ApiService, HomeRepository>(
          update: (_, apiService, __) => HomeRepository(apiService),
        ),

        // ----------------------------------------------------------
        // 3️⃣ طبقة إدارة الحالة (ViewModels Layer)
        // ----------------------------------------------------------
        // مزود الثيم (Theme)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Login ViewModel - يحتاج AuthRepository
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) =>
              LoginViewModel(authRepository: context.read<AuthRepository>()),
        ),

        // Welcome ViewModel - لإدارة صفحة الترحيب
        ChangeNotifierProvider(create: (_) => WelcomeViewModel()),

        // Register ViewModel - يحتاج AuthRepository
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) =>
              RegisterViewModel(authRepository: context.read<AuthRepository>()),
        ),

        // Home ViewModel - يحتاج HomeRepository و TokenStorage
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<HomeRepository>(),
            context.read<TokenStorage>(),
          ),
        ),

        // Settings ViewModel - يحتاج TokenStorage
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(context.read<TokenStorage>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer<ThemeProvider> لتحديث التطبيق عند تغيير الثيم
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Seeker App',
          debugShowCheckedModeBanner: false, // إخفاء شريط Debug
          // 🌍 إعدادات اللغة (Localization) - التطبيق عربي بالكامل
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 🎨 الثيمات (فاتح / داكن)
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode, // تبديل الثيم ديناميكياً
          // 📍 المسارات (Navigation Routes)
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashView(), // شاشة البداية
            AppRoutes.welcome: (context) => WelcomeView(), // شاشة الترحيب
            AppRoutes.login: (context) => LoginView(), // تسجيل الدخول
            AppRoutes.register: (context) => RegisterView(), // تسجيل جديد
            AppRoutes.terms: (context) => TermsView(), // الشروط والأحكام
            AppRoutes.verifyEmail: (context) =>
                VerifyEmailView(), // تفعيل البريد
            AppRoutes.home: (context) => HomeView(title: 'Home'), // الرئيسية
            AppRoutes.settings: (context) => SettingsView(), // الإعدادات
          },
        );
      },
    );
  }
}

// 🔐 تجاوز فحص شهادات SSL (يستخدم فقط أثناء التطوير إذا كان السيرفر محلي أو بدون HTTPS صحيح)
class BadCertificateHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
