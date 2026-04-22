import 'package:flutter/material.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../Models/order_model.dart';

/// 📂 اسم الملف: bond_gallery_view.dart
/// 📝 الوصف: معرض ملف السندات (Receipts) بملء الشاشة مع دعم التمرير الأفقي والزوم.
class BondGalleryView extends StatefulWidget {
  final List<OrderBond> bonds;
  final int initialPage;

  const BondGalleryView({
    super.key,
    required this.bonds,
    this.initialPage = 0,
  });

  @override
  State<BondGalleryView> createState() => _BondGalleryViewState();
}

class _BondGalleryViewState extends State<BondGalleryView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1️⃣ المعرض (PageView)
          PageView.builder(
            controller: _pageController,
            itemCount: widget.bonds.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final bond = widget.bonds[index];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: 'bond_${bond.id}',
                    child: Image.network(
                      bond.imagePath,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                            const SizedBox(height: 16),
                            Text(context.tr('image_load_error'), style: const TextStyle(color: Colors.white70)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // 2️⃣ زر الإغلاق
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3️⃣ تفاصيل السند (Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // المؤشر (الإصدار)
                  if (widget.bonds.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.bonds.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? colors.primary
                                  : Colors.white.withOpacity(0.3),
                            ),
                          );
                        }),
                      ),
                    ),
                  
                  // معلومات السند
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('bond_number'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              widget.bonds[_currentPage].bondNumber,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              context.tr('amount_paid'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '${widget.bonds[_currentPage].amount.toInt()} ${context.tr('currency_sar')}',
                              style: TextStyle(color: colors.primary, fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
