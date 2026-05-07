import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Consumer<FavoriteViewModel>(
      builder: (context, favVm, child) {
        // نتحقق من حالة المفضلة من الـ ViewModel لضمان المزامنة مع الباك اند
        final bool isFavorite = favVm.isServiceFavorite(service.id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20), // زوايا أكثر نعومة
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
                // 1️⃣ صورة الخدمة (جهة اليمين)
                Stack(
                  children: [
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
                          width: 100, // حجم أكبر قليلاً للصورة
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
                    // القلب (فوق الصورة)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? colors.error : colors.textSub.withValues(alpha: 0.4),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // 2️⃣ تفاصيل الخدمة (جهة اليسار في RTL)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // القسم والتقييم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(), // مساحة فارغة بدلاً من تاق العرض الخاص
                          Row(
                            children: [
                              Icon(Icons.star, color: colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                service.rating.toString(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // العنوان
                      Text(
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
                      const SizedBox(height: 4),
                      
                      // اسم المزود
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: colors.textSub),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              service.providerName,
                              style: TextStyle(color: colors.textSub, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (service.isProviderVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: colors.primary, // أو استخدم لون التوثيق الخاص بك
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // السعر والزر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          // زر الحجز
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                               AppLocalizations.of(context)!.book,
                              style: TextStyle(color: colors.background, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
