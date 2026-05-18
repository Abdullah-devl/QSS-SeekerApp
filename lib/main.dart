import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seeker/core/services/notification_service.dart';

// --- Imports --- (استيراد الملفات اللازمة)
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/app_theme.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/features/auth/viewmodel/register_view_model.dart';
import 'package:seeker/features/auth/views/register_view.dart';
import 'package:seeker/features/auth/views/verify_email_view.dart';
import 'package:seeker/features/home/views/home_view.dart';
import 'package:seeker/features/provider/theme_provider.dart';

// ViewModels
import 'package:seeker/features/auth/viewmodel/login_view_model.dart';
import 'package:seeker/features/intro/viewmodels/welcome_view_model.dart'; // ✅ تمت الإضافة

import 'package:seeker/features/settings/viewmodels/settings_view_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/home/viewmodels/category_details_view_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/auth/viewmodel/verify_email_view_model.dart'; // ✅ تمت الإضافة

// Views
import 'package:seeker/features/auth/viewmodel/forgot_password_view_model.dart';
import 'package:seeker/features/auth/views/forgot_password_view.dart';
import 'package:seeker/features/auth/views/login_view.dart';
import 'package:seeker/features/intro/splash_view.dart';
import 'package:seeker/features/intro/welcome_view.dart';
import 'package:seeker/features/auth/views/terms_view.dart';
import 'package:seeker/features/auth/viewmodel/change_password_view_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/auth/views/change_password_view.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/settings/repositories/settings_repository.dart';
import 'package:seeker/features/settings/viewmodels/policy_view_model.dart';
import 'package:seeker/features/settings/views/privacy_policy_view.dart';
import 'package:seeker/features/settings/views/settings_view.dart';

// Complaints Feature
import 'package:seeker/features/complaints/repositories/complaints_repository.dart';
import 'package:seeker/features/complaints/viewmodels/system_complaints_viewmodel.dart';
import 'package:seeker/features/complaints/viewmodels/order_complaints_viewmodel.dart';
import 'package:seeker/features/complaints/viewmodels/submit_complaint_viewmodel.dart';
import 'package:seeker/features/complaints/views/complaints_hub_view.dart';
// import 'package:seeker/features/profile/view/profile_view.dart';
import 'package:seeker/features/profile/view/my_profile_view.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/home/views/category_details_view.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/home/models/category_model.dart'; // ✅ تمت الإضافة

// Repositories
import 'package:seeker/features/auth/repositories/auth_repository.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';
import 'package:seeker/features/home/repositories/advertisement_repository.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
// Be Provider Feature
import 'package:seeker/features/beProvider/repositories/be_provider_repository.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/beProvider/viewmodels/be_provider_view_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/beProvider/views/be_provider_view.dart';
// Favorites Feature
import 'package:seeker/features/favorites/data_sources/favorite_remote_data_source.dart';
import 'package:seeker/features/favorites/repositories/favorite_repository.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
// import 'package:seeker/features/favorites/views/favorite_view.dart';
// Orders Feature
import 'package:seeker/features/orders/Repository/orders_repository.dart';
import 'package:seeker/features/orders/ViewModels/orders_viewmodel.dart';
// Payment Feature
import 'package:seeker/features/payment/repositories/payment_repository.dart';
import 'package:seeker/features/payment/viewmodels/payment_viewmodel.dart';
// import 'package:seeker/features/payment/views/payment_view.dart';

// Profile Feature
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import 'package:seeker/features/profile/viewmodels/profile_view_model.dart';

// Notifications Feature
import 'package:seeker/features/notifications/repositories/notification_repository.dart';
import 'package:seeker/features/notifications/viewmodels/notification_view_model.dart';
import 'package:seeker/features/notifications/views/notifications_view.dart';
import 'package:seeker/features/search/repositories/search_repository.dart';
import 'package:seeker/features/search/viewmodels/search_viewmodel.dart';
// Points Feature
import 'package:seeker/features/points/repositories/points_repository.dart';
import 'package:seeker/features/points/viewmodels/points_viewmodel.dart';
import 'package:seeker/features/points/views/points_management_view.dart';
import 'package:seeker/features/points/views/points_packages_view.dart';
import 'package:seeker/features/points/views/my_packages_view.dart';
// import 'package:seeker/features/points/views/submit_points_payment_view.dart';
import 'dart:io';

import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: main.dart
/// 📝 الوصف: نقطة انطلاق التطبيق (Entry Point).
/// يقوم بتهيئة الاعتمادات (Dependency Injection) باستخدام Provider، وإعداد الثيم، واللغة، والمسارات (Routes).

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📦 تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();

  // 🌙 تحميل تفضيل الثيم مبكراً لمنع الوميض وتأخر التحميل
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode');

  // 🔥 تهيئة Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('❌ Firebase Initialization Error: $e');
  }



  HttpOverrides.global = BadCertificateHttpOverrides();

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

        // AdvertisementRepository يعتمد على ApiService فقط
        ProxyProvider<ApiService, AdvertisementRepository>(
          update: (_, apiService, __) => AdvertisementRepository(apiService),
        ),

        // BeProviderRepository يعتمد على ApiService فقط
        ProxyProvider<ApiService, BeProviderRepository>(
          update: (_, apiService, __) => BeProviderRepository(apiService),
        ),

        // FavoriteRepository
        ProxyProvider<ApiService, FavoriteRemoteDataSource>(
          update: (_, apiService, __) => FavoriteRemoteDataSource(apiService),
        ),
        ProxyProvider<FavoriteRemoteDataSource, FavoriteRepository>(
          update: (_, dataSource, __) => FavoriteRepository(dataSource),
        ),

        // OrdersRepository
        ProxyProvider<ApiService, OrdersRepository>(
          update: (_, apiService, __) => OrdersRepository(apiService),
        ),

        // 💳 PaymentRepository
        ProxyProvider<ApiService, PaymentRepository>(
          update: (_, apiService, __) => PaymentRepository(apiService),
        ),

        // 🔍 SearchRepository
        ProxyProvider<ApiService, SearchRepository>(
          update: (_, apiService, __) => SearchRepository(apiService),
        ),
      
        // 👤 ProfileRepository
        ProxyProvider<ApiService, ProfileRepository>(
          update: (_, apiService, __) => ProfileRepository(apiService),
        ),

        // 🔔 NotificationRepository
        ProxyProvider<ApiService, NotificationRepository>(
          update: (_, apiService, __) => NotificationRepository(apiService),
        ),

        // 💰 PointsRepository
        ProxyProvider<ApiService, PointsRepository>(
          update: (_, apiService, __) => PointsRepository(apiService),
        ),

        // ⚙️ SettingsRepository
        ProxyProvider<ApiService, SettingsRepository>(
          update: (_, apiService, __) => SettingsRepository(apiService),
        ),

        // 🛡️ ComplaintsRepository
        ProxyProvider<ApiService, ComplaintsRepository>(
          update: (_, apiService, __) => ComplaintsRepository(apiService),
        ),

        // ----------------------------------------------------------
        // 3️⃣ طبقة إدارة الحالة (ViewModels Layer)
        // ----------------------------------------------------------
        // مزود الثيم (Theme)
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialDarkMode: isDarkMode)),

        // Login ViewModel - يحتاج AuthRepository
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),

        // Welcome ViewModel - لإدارة صفحة الترحيب
        ChangeNotifierProvider(create: (_) => WelcomeViewModel()),

        // Register ViewModel - يحتاج AuthRepository
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) =>
              RegisterViewModel(authRepository: context.read<AuthRepository>()),
        ),

        // Home ViewModel - يحتاج HomeRepository و AdvertisementRepository و TokenStorage
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<HomeRepository>(),
            context.read<AdvertisementRepository>(), // ✅ تمت الإضافة
            context.read<TokenStorage>(),
          ),
        ),

        // Settings ViewModel - يحتاج TokenStorage
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(context.read<TokenStorage>()),
        ),

        // Be Provider ViewModel - يحتاج BeProviderRepository
        ChangeNotifierProvider<BeProviderViewModel>(
          create: (context) =>
              BeProviderViewModel(context.read<BeProviderRepository>()),
        ),
        //
        ChangeNotifierProvider<VerifyEmailViewModel>(
          create: (context) => VerifyEmailViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<ForgotPasswordViewModel>(
          create: (context) => ForgotPasswordViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        // Favorite ViewModel
        ChangeNotifierProvider<FavoriteViewModel>(
          create: (context) => FavoriteViewModel(
            context.read<FavoriteRepository>(),
            context.read<HomeRepository>(),
          ),
        ),

        // Orders ViewModel
        ChangeNotifierProvider<OrdersViewModel>(
          create: (context) =>
              OrdersViewModel(context.read<OrdersRepository>()),
        ),

        // 💳 Payment ViewModel
        ChangeNotifierProvider<PaymentViewModel>(
          create: (context) =>
              PaymentViewModel(context.read<PaymentRepository>()),
        ),

        // 🔍 Search ViewModel
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) =>
              SearchViewModel(context.read<SearchRepository>()),
        ),

        // 👤 Profile ViewModel
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) =>
              ProfileViewModel(context.read<ProfileRepository>()),
        ),
        // ChangePassword ViewModel
        ChangeNotifierProvider<ChangePasswordViewModel>(
          create: (context) => ChangePasswordViewModel(
            context.read<AuthRepository>(),
          ),
        ),

        // Policy ViewModel
        ChangeNotifierProvider<PolicyViewModel>(
          create: (context) => PolicyViewModel(
            context.read<SettingsRepository>(),
          ),
        ),

        // 🛡️ Complaints ViewModels
        ChangeNotifierProvider<SystemComplaintsViewModel>(
          create: (context) => SystemComplaintsViewModel(
            context.read<ComplaintsRepository>(),
          ),
        ),
        ChangeNotifierProvider<OrderComplaintsViewModel>(
          create: (context) => OrderComplaintsViewModel(
            context.read<ComplaintsRepository>(),
          ),
        ),
        ChangeNotifierProvider<SubmitComplaintViewModel>(
          create: (context) => SubmitComplaintViewModel(
            context.read<ComplaintsRepository>(),
          ),
        ),
        // 🔔 Notification ViewModel
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) => NotificationViewModel(
            context.read<NotificationRepository>(),
          ),
        ),
        // 💰 Points ViewModel
        ChangeNotifierProvider<PointsViewModel>(
          create: (context) => PointsViewModel(
            context.read<PointsRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 🔔 تهيئة خدمة الإشعارات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🚩 [MAIN]: Initializing NotificationService...');
      try {
        final notificationRepo = context.read<NotificationRepository>();
        await NotificationService().initialize(notificationRepo);
        
        // الاستماع لتيار الإشعارات للتوجيه الذكي
        NotificationService().notificationStream.listen((data) {
          _handleNotificationNavigation(data);
        });
      } catch (e) {
        print('❌ [MAIN]: Error initializing NotificationService: $e');
      }
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'];
    final requestId = data['request_id'];

    if (type != null && requestId != null) {
      // توجيه المستخدم لصفحة تفاصيل الطلب (مثال)
      // Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: requestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // نراقب SettingsViewModel للحصول على اللغة الحالية
    final settingsViewModel = context.watch<SettingsViewModel>();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp
        (
          title: 'QSS',
          debugShowCheckedModeBanner: false,

          // 🌍 إعدادات اللغة (Localization)
          locale: settingsViewModel.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          // 🎨 الثيمات (فاتح / داكن)
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // 📍 المسارات (Navigation Routes)
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashView(), // شاشة البداية
            AppRoutes.welcome: (context) => WelcomeView(), // شاشة الترحيب
            AppRoutes.login: (context) => LoginView(), // تسجيل الدخول
            AppRoutes.register: (context) => RegisterView(), // تسجيل جديد
            AppRoutes.terms: (context) => TermsView(), // الشروط والأحكام
            AppRoutes.verifyEmail: (context) => ChangeNotifierProvider(
              create: (_) => VerifyEmailViewModel(
                authRepository: context.read<AuthRepository>(),
              ),
              child:  VerifyEmailView(),
            ),
            AppRoutes.home: (context) => HomeView(title: 'Home'), // الرئيسية
            AppRoutes.settings: (context) => SettingsView(), // الإعدادات
            AppRoutes.profile: (context) =>
                const MyProfileView(), // الملف الشخصي الجديد
            // التعامل مع تمرير البيانات (CategoryModel) عبر المسار
            AppRoutes.categoryDetails: (context) {
              final category =
                  ModalRoute.of(context)!.settings.arguments as CategoryModel;
              return ChangeNotifierProvider(
                create: (context) => CategoryDetailsViewModel(
                  context.read<HomeRepository>(),
                  context.read<AdvertisementRepository>(),
                ),
                child: CategoryDetailsView(category: category),
              );
            },
            AppRoutes.beProvider: (context) => const BeProviderView(),
            AppRoutes.changePassword: (context) => const ChangePasswordView(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordView(),
            '/notifications': (context) => const NotificationsView(),
            AppRoutes.privacyPolicy: (context) => ChangeNotifierProvider(
              create: (context) => PolicyViewModel(
                context.read<SettingsRepository>(),
              ),
              child: const PrivacyPolicyView(),
            ),
            AppRoutes.systemComplaints: (context) => const ComplaintsView(),

            // 💰 مسارات النقاط
            AppRoutes.pointsManagement: (context) => const PointsManagementView(),
            AppRoutes.availablePackages: (context) => const PointsPackagesView(),
            AppRoutes.myPackages: (context) => const MyPackagesView(),
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
