import 'package:flutter/material.dart';

/// 📂 اسم الملف: image_viewer.dart
/// 📝 الوصف: عارض صور تفاعلي ملء الشاشة بأسلوب إنستغرام يدعم التكبير والتصغير بالقرص (Pinch-to-zoom).
class QsImageViewer extends StatelessWidget {
  final String imageUrl;

  const QsImageViewer({super.key, required this.imageUrl});

  /// 🚀 فتح عارض الصور بلمسة واحدة
  static void show(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      useSafeArea: false,
      builder: (context) => QsImageViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 🛑 النقر في أي مكان فارغ للخروج
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // 🔍 الصورة التفاعلية القابلة للتكبير والتحريك (Pinch & Pan)
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              clipBehavior: Clip.none,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white70,
                  size: 60,
                ),
              ),
            ),
          ),
          
          // ❌ زر الإغلاق الأنيق في الأعلى
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
