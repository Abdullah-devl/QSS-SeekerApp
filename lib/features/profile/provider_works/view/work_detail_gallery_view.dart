import 'package:flutter/material.dart';
import '../../models/work_model.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';

/// 📂 اسم الملف: work_detail_gallery_view.dart
/// 📝 الوصف: واجهة عرض تفاصيل العمل السابتق بأسلوب معرض صور احترافي (شبيه بإنستقرام).
/// يدعم السحب الأفقي للتنقل بين الأعمال، والتمرير الرأسي لرؤية التفاصيل.
class WorkDetailGalleryView extends StatefulWidget {
  final List<WorkModel> works;
  final int initialIndex;

  const WorkDetailGalleryView({
    super.key,
    required this.works,
    required this.initialIndex,
  });

  @override
  State<WorkDetailGalleryView> createState() => _WorkDetailGalleryViewState();
}

class _WorkDetailGalleryViewState extends State<WorkDetailGalleryView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
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
      backgroundColor:
          Colors.black, // خلفية سوداء للمعرض لتركيز الانتباه على الصور
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'أعمال سابقة',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.works.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final work = widget.works[index];
          return _buildWorkItem(work, colors);
        },
      ),
    );
  }

  Widget _buildWorkItem(WorkModel work, dynamic colors) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📸 عرض الصورة بوضعية ملء العرض
          Hero(
            tag: 'work_image_${work.id}',
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Image.network(
                  work.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 📝 تفاصيل العمل (العنوان والوصف)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Text(
                  work.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                // مساحة إضافية للتمرير في الأسفل
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
