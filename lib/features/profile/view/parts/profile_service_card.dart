import 'package:flutter/material.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: profile_service_card.dart
/// 📝 الوصف: كارت خدمة مبسط مخصص للعرض في الملف الشخصي للمزود.
class ProfileServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ProfileServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ صورة الخدمة
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  service.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: colors.primary.withValues(alpha: 0.05),
                    child: Icon(Icons.broken_image_outlined, color: colors.textSub.withValues(alpha: 0.5), size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2️⃣ تفاصيل الخدمة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان والتقييم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colors.text,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: colors.warning, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            service.rating.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // اسم المزود
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 12, color: colors.textSub),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.providerName,
                          style: TextStyle(color: colors.textSub, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // السعر
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: colors.primary, fontFamily: 'Cairo'),
                      children: [
                        TextSpan(
                          text: '${service.price.toInt()} ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.sar,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
