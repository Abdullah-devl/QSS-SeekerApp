import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../models/advertisement_model.dart';
import '../models/category_model.dart';
import '../viewmodels/home_view_model.dart';
import '../repositories/home_repository.dart';
import '../services/view/service_details_view.dart';
import '../services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/viewmodels/category_details_view_model.dart';
import 'package:seeker/features/home/views/category_details_view.dart';
import 'package:seeker/features/home/repositories/advertisement_repository.dart'; // ✅ تمت الإضافة

/// 📂 اسم الملف: advertisement_carousel.dart
/// 📝 الوصف: ويدجت لعرض الإعلانات بشكل متحرك (Carousel) مع دعم التتبع والتوجيه.

class AdvertisementCarousel extends StatefulWidget {
  final List<AdvertisementModel> advertisements;

  const AdvertisementCarousel({super.key, required this.advertisements});

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  final Set<int> _viewedAds = {}; // لتجنب تكرار تتبع المشاهدة لنفس الإعلان في نفس الجلسة

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // 🕒 إعداد المؤقت للتنقل التلقائي
    if (widget.advertisements.length > 1) {
      _startTimer();
    }

    // تتبع أول إعلان معروض
    _trackView(0);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % widget.advertisements.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// 👁️ منطق تتبع المشاهدة (Impression)
  void _trackView(int index) {
    if (index >= widget.advertisements.length) return;
    final ad = widget.advertisements[index];
    if (!_viewedAds.contains(ad.id)) {
      context.read<HomeViewModel>().trackAdView(ad.id);
      _viewedAds.add(ad.id);
    }
  }

  /// 🖱️ منطق التفاعل (Click & Navigation)
  Future<void> _handleAdTap(AdvertisementModel ad) async {
    debugPrint('📢 [Ad Tap]: ID=${ad.id}, Type=${ad.targetType}, TargetId=${ad.targetId}');
    
    // 1. تتبع النقرة
    try {
      context.read<HomeViewModel>().trackAdClick(ad.id);
    } catch (e) {
      debugPrint('❌ Track Click Error: $e');
    }

    // 2. التوجيه بناءً على target_type (مرونة في حالة الأحرف والمسافات)
    final String target = ad.targetType.toLowerCase().trim();

    switch (target) {
      case 'service':
        if (ad.targetId != null) {
          debugPrint('🚀 Navigating to Service: ${ad.targetId}');
          _navigateToService(ad.targetId!);
        }
        break;
      case 'category':
        if (ad.targetId != null) {
          debugPrint('🚀 Navigating to Category: ${ad.targetId}');
          _navigateToCategory(ad.targetId!);
        }
        break;
      case 'external':
        if (ad.externalLink != null && ad.externalLink!.isNotEmpty) {
          debugPrint('🚀 Opening External Link: ${ad.externalLink}');
          try {
            final url = Uri.parse(ad.externalLink!.trim());
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              debugPrint('❌ Cannot launch URL: ${ad.externalLink}');
            }
          } catch (e) {
            debugPrint('❌ URL Launch Error: $e');
          }
        }
        break;
      default:
        debugPrint('ℹ️ No navigation action for target: $target');
        break;
    }
  }

  /// 🚀 التوجيه لصفحة الخدمة
  void _navigateToService(int serviceId) async {
    try {
      final homeRepo = context.read<HomeRepository>();
      final service = await homeRepo.fetchServiceById(serviceId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => ServiceDetailsViewModel(homeRepo),
              child: ServiceDetailsView(initialService: service),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ad Navigation Error (Service): $e');
    }
  }

  /// 📂 التوجيه لصفحة القسم
  void _navigateToCategory(int categoryId) async {
    try {
      final homeRepo = context.read<HomeRepository>();
      final categories = await homeRepo.fetchCategories();
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => CategoryDetailsViewModel(
                homeRepo,
                context.read<AdvertisementRepository>(),
              ),
              child: CategoryDetailsView(category: category),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ad Navigation Error (Category): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _trackView(index);
            },
            itemCount: widget.advertisements.length,
            itemBuilder: (context, index) {
              final ad = widget.advertisements[index];
              return _buildAdItem(ad);
            },
          ),
        ),
        if (widget.advertisements.length > 1) ...[
          const SizedBox(height: 10),
          _buildIndicator(),
        ],
      ],
    );
  }

  Widget _buildAdItem(AdvertisementModel ad) {
    return GestureDetector(
      onTap: () => _handleAdTap(ad),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(ad.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                ad.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (ad.description != null && ad.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    ad.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (ad.targetType != 'none')
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.qsColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'تفاصيل',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.advertisements.length,
        (index) => Container(
          width: _currentPage == index ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? context.qsColors.primary
                : context.qsColors.textSub.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
