import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../viewmodel/provider_works_view_model.dart';
import 'work_detail_gallery_view.dart';

/// 📂 اسم الملف: provider_works_view.dart
/// 📝 الوصف: واجهة عرض الأعمال السابقة لمزود الخدمة في شكل شبكة (Grid).
class ProviderWorksView extends StatelessWidget {
  const ProviderWorksView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ProviderWorksViewModel>();

    // 🚀 عرض حالة التحميل
    if (vm.isLoading && vm.works.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    // ❌ عرض حالة الخطأ
    if (vm.errorMessage != null && vm.works.isEmpty) {
      return Center(
        child: Text(
          vm.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // 📭 حالة عدم وجود أعمال
    if (vm.works.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: colors.textSub.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              'لا توجد أعمال سابقة لهذا المزود.',
              style: TextStyle(color: colors.textSub, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // ✅ عرض الشبكة (Grid)
    return RefreshIndicator(
      color: colors.primary,
      onRefresh: vm.fetchWorks,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 📸 3 أعمدة مثل الانستقرام
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1, // مربعات متساوية
        ),
        itemCount: vm.works.length,
        itemBuilder: (context, index) {
          final work = vm.works[index];
          return Hero(
            tag: 'work_image_${work.id}',
            child: Container(
              color: colors.textSub.withOpacity(0.05),
              child: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    work.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: colors.primary.withOpacity(0.3),
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image_outlined,
                      color: colors.textSub.withOpacity(0.3),
                    ),
                  ),
                  // ℹ️ لمسة تفاعلية عند الضغط (لعرض تفاصيل العمل)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkDetailGalleryView(
                              works: vm.works,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
