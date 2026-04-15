import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_colors.dart'; // Import QSColors definition
import 'package:seeker/features/home/models/category_model.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/features/home/views/home_drawer.dart';
import 'package:seeker/features/home/widgets/custom_nav_bar.dart'; // Import CustomNavBar
import 'package:seeker/features/settings/views/settings_view.dart'; // Import SettingsView
import 'package:seeker/core/network/api_endpoints.dart';
import '../services/viewmodels/service_details_view_model.dart';

import '../services/view/service_details_view.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';
import 'package:seeker/features/favorites/views/favorite_view.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/core/widgets/service_card.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/features/orders/Views/orders_view.dart';

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
            currentScreen = _buildPlaceholderPage(
              context,
              AppLocalizations.of(context)!.search,
            );
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
          drawer: HomeDrawer(
            onLinkTap: (index) {
              // تحديث الاندكس عبر البروفايدر
              context.read<HomeViewModel>().setIndex(index);
            },
          ), // القائمة الجانبية
          body: currentIndex == 4
              ? currentScreen
              : SafeArea(child: currentScreen),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // ⏳ عرض مؤشر تحميل طالما البيانات لم تجهز
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 📄 صفحة مؤقتة (Placeholder Page) لمرعفة العمل  انه شغال او لا
  // ---------------------------------------------------------------------------
  Widget _buildPlaceholderPage(BuildContext context, String title) {
    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: context.qsColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: context.qsColors.text),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Center(
        child: Text(
          '$title - ${AppLocalizations.of(context)!.soon}',
          style: TextStyle(fontSize: 18, color: context.qsColors.textSub),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1️⃣ الهيدر (Header Component)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    // نستخدم select للاستماع فقط للتغييرات في الاسم والموقع لتقليل إعادة البناء غير الضرورية
    final userName = context.select<HomeViewModel, String>((vm) => vm.userName);
    final currentAddress = context.select<HomeViewModel, String>(
      (vm) => vm.currentAddress,
    );
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
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.qsColors.text.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.menu, color: context.qsColors.text),
          ),
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
                  // عرض رسالة خطأ في حال الفشل
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        AppLocalizations.of(context)!.alert,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      content: Text(
                        error,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.ok,
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
        color: context.qsColors.primary,
        borderRadius: BorderRadius.circular(16),
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
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchHint,
          hintStyle: TextStyle(
            color: context.qsColors.text.withValues(alpha: 5),
            fontSize: 14,
          ),
          // زر الفلترة (يسار)
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.qsColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune, color: context.qsColors.text, size: 20),
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
        color: context.qsColors.secondary, // خلفية داكنة افتراضية
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
                    color: const Color(0xFF10B981), // أخضر
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
              style: TextStyle(color: Color(0xFF3B82F6), fontSize: 14),
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
          final colors = [
            const Color(0xFFE0F2FE), // أزرق فاتح
            const Color(0xFFFEF3C7), // أصفر فاتح
            const Color(0xFFFFEDD5), // برتقالي فاتح
            const Color(0xFFF3E8FF), // بنفسجي فاتح
          ];
          final bgColor = colors[index % colors.length];

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
                  create: (context) => ServiceDetailsViewModel(
                    context.read<HomeRepository>(),
                  ),
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

    debugPrint('--------------------------------------------------');
    debugPrint('🔍 Debugging Image Path for Category: ${cat.name}');
    debugPrint('📥 Raw Path from API: "$rawPath"');

    // 1. إذا كان الرابط كاملاً من الإنترنت
    if (rawPath.startsWith('http') || rawPath.startsWith('https')) {
      imageUrl = rawPath;
      debugPrint('✅ Is Full URL: Yes');
    }
    // 2. إذا كان الرابط محلياً (Asset) يبدأ بـ assets
    else if (rawPath.startsWith('assets/')) {
      debugPrint('📂 Is Local Asset: Yes');
      return Image.asset(
        rawPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          debugPrint('❌ Failed to load local asset: $rawPath');
          return const Icon(Icons.category, color: Colors.blueGrey);
        },
      );
    }
    // 3. أي حالة أخرى، نعتبرها مساراً من السيرفر ونقوم بدمجها مع BaseURL
    else {
      // نتأكد أننا لا نكرر الـ slash
      String basePath = ApiEndpoints.storageBaseUrl.endsWith('/')
          ? ApiEndpoints.storageBaseUrl
          : '${ApiEndpoints.storageBaseUrl}/';

      debugPrint('🌐 Base URL: $basePath');

      String imagePath = rawPath.startsWith('/')
          ? rawPath.substring(1)
          : rawPath;

      imageUrl = '$basePath$imagePath';
      debugPrint('🔗 Constructed URL: $imageUrl');
    }

    debugPrint('🖼️ Final Image URL to Load: $imageUrl');
    debugPrint('--------------------------------------------------');

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // طباعة الخطأ لمعرفة السبب
        debugPrint('❌ Image Error for $imageUrl: $error');
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
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
