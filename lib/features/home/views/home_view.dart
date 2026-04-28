import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_colors.dart'; // Import QSColors definition
import 'package:seeker/features/home/models/category_model.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/features/notifications/viewmodels/notification_view_model.dart';
import 'package:seeker/features/home/views/home_drawer.dart';
import 'package:seeker/features/home/widgets/custom_nav_bar.dart'; // Import CustomNavBar
import 'package:seeker/features/orders/ViewModels/orders_viewmodel.dart';
import 'package:seeker/features/search/viewmodels/search_viewmodel.dart';
import 'package:seeker/features/search/views/search_view.dart';
import 'package:seeker/features/settings/views/settings_view.dart'; // Import SettingsView
import 'package:seeker/core/network/api_endpoints.dart';
import 'package:seeker/core/services/notification_service.dart';

import '../services/viewmodels/service_details_view_model.dart';

import '../services/view/service_details_view.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';
import 'package:seeker/features/favorites/views/favorite_view.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/core/widgets/service_card.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/features/orders/Views/orders_view.dart';
import 'package:seeker/features/profile/viewmodels/profile_view_model.dart'; // ✅ تمت الإضافة


class HomeView extends StatefulWidget {
  final String title;
  const HomeView({super.key, required this.title});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // 🔄 تحميل البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
      // 🚀 جلب الطلبات لتحديث العداد في القائمة الجانبية (Drawer)
      context.read<OrdersViewModel>().fetchOrders();
      // 🚀 جلب بيانات الملف الشخصي الحية للترحيب بالاسم الصحيح
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  /// 🏗️ دالة بناء الواجهة
  @override
  Widget build(BuildContext context) {
    // الوصول للألوان بناءً على الثيم الحالي (فاتح/داكن)
    final colors = context.qsColors;

    // ✅ تم استبدال Selector بـ Consumer
    // السبب: Selector كان يستمع فقط لتغير currentIndex
    // وهذا يمنع إعادة بناء الصفحة عند تحديث البيانات (التصنيفات / الخدمات)
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final currentIndex = viewModel.currentIndex;

        // تحديد الشاشة المعروضة بناءً على المؤشر
        Widget currentScreen;
        switch (currentIndex) {
          case 0:
            currentScreen = _buildHomeContent(colors);
            break;
          case 1:
            currentScreen = const OrdersView();
            break;
          case 2:
            currentScreen = const SearchView();
            break;
          case 3:
            currentScreen = const FavoriteView();
            break;
          case 4:
            currentScreen = SettingsView(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            );
            break;
          default:
            currentScreen = _buildHomeContent(colors);
        }

        return Scaffold(
          key: _scaffoldKey, // لفتح القائمة الجانبية برمجياً
          backgroundColor: context.qsColors.background,
          extendBody: true, // 🚀 تمديد الجسم خلف الناف بار لجعله شفافاً
          drawer: HomeDrawer(
            onLinkTap: (index) {
              // تحديث الاندكس عبر البروفايدر
              context.read<HomeViewModel>().setIndex(index);
            },
          ), // القائمة الجانبية
          body: currentIndex == 4
              ? currentScreen
              : SafeArea(bottom: false, child: currentScreen),
          // شريط التنقل السفلي المخصص
          bottomNavigationBar: CustomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              // تحديث الاندكس عبر البروفايدر
              context.read<HomeViewModel>().setIndex(index);
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🏠 محتوى الصفحة الرئيسية
  // ---------------------------------------------------------------------------
  Widget _buildHomeContent(QSColors colors) {
    return RefreshIndicator(
      onRefresh: () async { 
        // 🔄 تحديث جميع البيانات عند السحب باستخدام الموديلات مباشرة لتجنب تحذيرات Context
        final homeVM = context.read<HomeViewModel>();
        final ordersVM = context.read<OrdersViewModel>();
        final profileVM = context.read<ProfileViewModel>();
        
        await Future.wait([
          homeVM.loadHomeData(),
          ordersVM.fetchOrders(),
          profileVM.fetchProfile(),
        ]);
      },
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // لضمان عمل السحب حتى لو كان المحتوى قصيراً
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            // ⏳ عرض مؤشر تحميل طالما البيانات لم تجهز
            if (viewModel.isLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===========================================
                // 1️⃣ الهيدر (الموقع + الترحيب + زر القائمة)
                // ===========================================
                _buildHeader(context),
                const SizedBox(height: 20),

                // ===========================================
                // 2️⃣ شريط البحث
                // ===========================================
                _buildSearchBar(context),
              const SizedBox(height: 24),

              // ===========================================
              // 3️⃣ البانر (عرض ترويجي خاص)
              // ===========================================
              _buildPromoBanner(),
              const SizedBox(height: 24),

              // ===========================================
              // 4️⃣ قسم التصنيفات (Categories)
              // ===========================================
              _buildSectionTitle(
                AppLocalizations.of(context)!.categories,
                onSeeAll: () {},
              ),
              const SizedBox(height: 16),
              _buildCategoriesList(viewModel.categories),
              const SizedBox(height: 24),

              // ===========================================
              // 5️⃣ قسم الأكثر طلباً (Popular Services)
              // ===========================================
              _buildSectionTitle(AppLocalizations.of(context)!.mostPopular),
              const SizedBox(height: 16),
              _buildPopularServicesList(viewModel.popularServices),

              // مساحة إضافية في الأسفل لتجنب تغطية المحتوى بالـ NavBar
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    ),
  );
}


  // ---------------------------------------------------------------------------
  // 1️⃣ الهيدر (Header Component)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    // نستخدم select للاستماع فقط للتغييرات في الاسم والموقع لتقليل إعادة البناء غير الضرورية
    final profileName = context.select<ProfileViewModel, String>((vm) => vm.profile?.name ?? '');
    final cachedName = context.select<HomeViewModel, String>((vm) => vm.userName);
    final String userName;
    if (profileName.isNotEmpty) {
      userName = profileName;
    } else if (cachedName == 'Guest') {
      userName = AppLocalizations.of(context)!.guest;
    } else {
      userName = cachedName;
    }
    
    String currentAddress = context.select<HomeViewModel, String>(
      (vm) => vm.currentAddress,
    );
    // ✅ ترجمة المواقع الافتراضية
    if (currentAddress == 'unknownLocation') {
      currentAddress = AppLocalizations.of(context)!.unknownLocation;
    } else if (currentAddress == 'Yemen') {
      currentAddress = AppLocalizations.of(context)!.defaultCountry;
    }

    final isLocationLoading = context.select<HomeViewModel, bool>(
      (vm) => vm.isLocationLoading,
    );

    return Row(
      children: [
        // زر فتح القائمة الجانبية (Drawer)
        InkWell(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.qsColors.card,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu, color: context.qsColors.text),
          ),
        ),

        const SizedBox(width: 12),
        // زر الإشعارات (الجرس)
        Consumer<NotificationViewModel>(
          builder: (context, notificationVm, _) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.qsColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded, color: context.qsColors.text),
                  ),
                  if (notificationVm.unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.qsColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationVm.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const Spacer(),

        // معلومات المستخدم والموقع
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // زر تحديث الموقع
            GestureDetector(
              onTap: () async {
                // 📍 عند الضغط يتم تحديث الموقع وطلب الصلاحيات
                final error = await context
                    .read<HomeViewModel>()
                    .updateLocation();

                if (error != null && context.mounted) {
                  // ✅ استخراج الرسالة المترجمة بناءً على الـ key الراجع من الـ ViewModel
                  String translatedError;
                  final l10n = AppLocalizations.of(context)!;

                  switch (error) {
                    case 'locationServiceDisabled':
                      translatedError = l10n.locationServicesDisabled;
                      break;
                    case 'locationPermissionDenied':
                      translatedError = l10n.locationPermissionsDenied;
                      break;
                    case 'locationPermissionForeverDenied':
                      translatedError = l10n.locationPermissionForeverDenied;
                      break;
                    case 'locationUpdateFailed':
                      translatedError = l10n.locationUpdateFailed;
                      break;
                    default:
                      translatedError = error;
                  }

                  // عرض رسالة خطأ في حال الفشل
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        l10n.alert,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      content: Text(
                        translatedError,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.ok,
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: context.qsColors.primary,
                  ),
                  // عرض مؤشر تحميل صغير عند جلب الموقع
                  if (isLocationLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Text(
                      currentAddress,
                      style: TextStyle(
                        color: context.qsColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.location_on,
                    color: context.qsColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // الترحيب بالمستخدم
            Row(
              children: [
                const Text(' 👋', style: TextStyle(fontSize: 20)),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      color: context.qsColors.text,
                      fontFamily: 'Cairo', // تأكيد استخدام خط Cairo
                    ),
                    children: [
                      TextSpan(text: AppLocalizations.of(context)!.welcome),
                      TextSpan(
                        text: userName, // ✅ الاسم ديناميكي
                        style: TextStyle(
                          color: context.qsColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              AppLocalizations.of(context)!.lookingForService,
              style: TextStyle(color: context.qsColors.textSub, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2️⃣ شريط البحث (Search Bar Component)
  // ---------------------------------------------------------------------------
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        textAlign: TextAlign.right,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            // 1. تعيين النص في البحث
            context.read<SearchViewModel>().setQuery(value);
            // 2. الانتقال لتبويب البحث
            context.read<HomeViewModel>().setIndex(2);
            // 3. تشغيل البحث
            context.read<SearchViewModel>().performSearch();
          }
        },
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchHint,
          hintStyle: TextStyle(
            color: context.qsColors.background.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          // زر الفلترة (يسار)
          prefixIcon: InkWell(
            onTap: () {
              // 1. تفعيل طلب فتح الفلاتر
              context.read<SearchViewModel>().triggerFilters();
              // 2. الانتقال لتبويب البحث مباشرة
              context.read<HomeViewModel>().setIndex(2);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.qsColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.tune, color: context.qsColors.text, size: 20),
            ),
          ),
          // أيقونة البحث (يمين)
          suffixIcon: Icon(Icons.search, color: context.qsColors.text),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3️⃣ البانر الترويجي (Promo Banner Component)
  // ---------------------------------------------------------------------------
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 200, // ✅ ارتفاع ثابت لتجنب مشاكل العرض (Overflow)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            context.qsColors.primary,
            context.qsColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // طبقة تدرج لوني لإبراز النصوص
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  context.qsColors.text.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),

          // محتوى البانر
          Positioned(
            right: 20,
            top: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شارة "عرض خاص" small badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.qsColors.success, // أخضر متجاوب
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.specialOffer,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.cleaningDiscount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.getShinier,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.qsColors.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.bookNow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 عنوان القسم مع زر "عرض الكل"
  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              AppLocalizations.of(context)!.seeAll,
              style: TextStyle(color: context.qsColors.primary, fontSize: 14),
            ),
          ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4️⃣ قائمة التصنيفات (Categories List)
  // ---------------------------------------------------------------------------
  Widget _buildCategoriesList(List<CategoryModel> categories) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true, // لتبدأ القائمة من اليمين
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          // ألوان خلفية مختلفة لكل عنصر لإضفاء حيوية
          final categoryColors = [
            context.qsColors.primary.withValues(alpha: 0.1),
            context.qsColors.secondary.withValues(alpha: 0.1),
            context.qsColors.success.withValues(alpha: 0.1),
            context.qsColors.warning.withValues(alpha: 0.1),
          ];
          final bgColor = categoryColors[index % categoryColors.length];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.categoryDetails,
                arguments: cat,
              );
            },
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildCategoryImage(cat),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5️⃣ قائمة الخدمات الأكثر طلباً (Popular Services List)
  // ---------------------------------------------------------------------------
  Widget _buildPopularServicesList(List<ServiceModel> services) {
    return Column(
      children: services.map((service) {
        return ServiceCard(
          service: service,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) =>
                      ServiceDetailsViewModel(context.read<HomeRepository>()),
                  child: ServiceDetailsView(initialService: service),
                ),
              ),
            );
          },
          onFavoriteToggle: () {
            context.read<FavoriteViewModel>().toggleFavorite(service);
          },
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // 🖼️ معالجة صور التصنيفات (Image Handling)
  // ---------------------------------------------------------------------------
  Widget _buildCategoryImage(CategoryModel cat) {
    String imageUrl;

    // تنظيف الرابط من المسافات الزائدة
    String rawPath = cat.iconPath.trim();

    // تنظيف الرابط من المسافات الزائدة
    cat.iconPath.trim();

    // 1. إذا كان الرابط كاملاً من الإنترنت
    if (rawPath.startsWith('http') || rawPath.startsWith('https')) {
      imageUrl = rawPath;
    }
    // 2. إذا كان الرابط محلياً (Asset) يبدأ بـ assets
    else if (rawPath.startsWith('assets/')) {
      return Image.asset(
        rawPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(Icons.category, color: context.qsColors.textSub);
        },
      );
    }
    // 3. أي حالة أخرى، نعتبرها مساراً من السيرفر ونقوم بدمجها مع BaseURL
    else {
      // نتأكد أننا لا نكرر الـ slash
      String basePath = ApiEndpoints.storageBaseUrl.endsWith('/')
          ? ApiEndpoints.storageBaseUrl
          : '${ApiEndpoints.storageBaseUrl}/';

      String imagePath = rawPath.startsWith('/')
          ? rawPath.substring(1)
          : rawPath;

      imageUrl = '$basePath$imagePath';
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: context.qsColors.background,
          child: Icon(Icons.broken_image, color: context.qsColors.textSub),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
