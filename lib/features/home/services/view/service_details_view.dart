import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/viewmodels/confirm_order_view_model.dart';
import 'package:seeker/features/home/views/confirm_order_view.dart';
import 'package:seeker/features/profile/view/profile_view.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/home/models/service_schedule_model.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/favorites/viewmodels/favorite_view_model.dart';
import 'package:seeker/features/profile/requests/repository/request_repository.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/features/profile/viewmodels/profile_view_model.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import 'package:seeker/features/profile/models/profile_model.dart';

class ServiceDetailsView extends StatefulWidget {
  final ServiceModel initialService;

  const ServiceDetailsView({super.key, required this.initialService});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  bool _showHiddenReviews = false;

  get lat => null;
  get lng => null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceDetailsViewModel>().fetchServiceDetails(
        widget.initialService.id,
        widget.initialService,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: Consumer<ServiceDetailsViewModel>(
        builder: (context, vm, child) {
          if (vm.service == null) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          final service = vm.service!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(service.imageUrl, colors),
                _buildMainInfo(service, colors),
                _buildProviderCard(service, vm.providerProfile, colors),
                _buildDivider(colors),
                _buildDescription(service.description, colors),
                _buildLocation(vm.providerProfile, colors),
                _buildWorkingHours(service, colors),
                _buildReviews(service, colors),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ServiceDetailsViewModel>(
        builder: (context, vm, child) {
          if (vm.service == null) return const SizedBox.shrink();
          return _buildBottomBar(vm.service!, colors, vm.isLoading);
        },
      ),
    );
  }

  // =========================================================================
  // 🧩 مكونات الشاشة (Widgets)
  // =========================================================================

  PreferredSizeWidget _buildAppBar(BuildContext context, dynamic colors) {
    final vm = context.watch<ServiceDetailsViewModel>();
    final favVm = context
        .watch<FavoriteViewModel>(); // نراقب حالة المفضلة عالمياً
    final service = vm.service;

    // تحديد إذا كانت الخدمة الحالية مفضلة عبر الاستعلام من القائمة العالمية (لضمان المزامنة مع الباك اند)
    final bool isFavorite = service != null
        ? favVm.isServiceFavorite(service.id)
        : false;

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context)!.serviceDetails,
        style: TextStyle(
          color: colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.arrow_back_ios_new
              : Icons.arrow_forward_ios,
          color: colors.text,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (service != null)
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? colors.error : colors.text,
            ),
            onPressed: () {
              favVm.toggleFavorite(service);
            },
          ),
      ],
    );
  }

  Widget _buildHeaderImage(String imageUrl, dynamic colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        image: imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl.isEmpty
          ? Center(
              child: Icon(
                Icons.image,
                size: 50,
                color: colors.textSub.withOpacity(0.3),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMainInfo(ServiceModel service, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.availableNow,
                      style: TextStyle(
                        color: colors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 12,
                      width: 1,
                      color: colors.textSub.withOpacity(0.3),
                    ),
                    Text(
                      '${service.reviewsCount} ${AppLocalizations.of(context)!.customerReviews}',
                      style: TextStyle(color: colors.textSub, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            service.rating > 0
                                ? service.rating.toStringAsFixed(1)
                                : AppLocalizations.of(context)!.newService,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: colors.warning,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star, color: colors.warning, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${service.price.toInt()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  fontFamily: 'Cairo',
                  height: 1.1,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.sar,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                AppLocalizations.of(context)!.perService,
                style: TextStyle(fontSize: 10, color: colors.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    ServiceModel service,
    ProfileModel? providerProfile,
    dynamic colors,
  ) {
    final String jobTitle =
        (providerProfile != null && providerProfile.jobTitle.isNotEmpty)
        ? providerProfile.jobTitle
        : AppLocalizations.of(context)!.provider_role;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colors.primary.withOpacity(0.1),
            backgroundImage:
                providerProfile != null && providerProfile.avatarUrl.isNotEmpty
                ? NetworkImage(providerProfile.avatarUrl)
                : null,
            child: providerProfile == null || providerProfile.avatarUrl.isEmpty
                ? Icon(Icons.person, color: colors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        service.providerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (service.isProviderVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: colors.primary, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  jobTitle,
                  style: TextStyle(color: colors.textSub, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => ProfileViewModel(
                      ProfileRepository(context.read<ApiService>()),
                      targetUserId: service.providerId,
                    ),
                    child: ProfileView(userId: service.providerId),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.visitProfile,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            AppLocalizations.of(context)!.serviceDescription,
            colors,
          ),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty ? description : '...',
            style: TextStyle(color: colors.textSub, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(ProfileModel? providerProfile, dynamic colors) {
    final double? provLat = providerProfile?.latitude;
    final double? provLng = providerProfile?.longitude;
    final bool hasCoords = provLat != null && provLng != null;

    final LatLng serviceLocation = hasCoords
        ? LatLng(provLat, provLng)
        : const LatLng(24.7136, 46.6753);

    final String displayAddress =
        (providerProfile != null &&
            providerProfile.address != null &&
            providerProfile.address!.isNotEmpty)
        ? providerProfile.address!
        : AppLocalizations.of(context)!.locationNotSpecified;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppLocalizations.of(context)!.location, colors),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.text.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                if (hasCoords) ...[
                  SizedBox(
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: IgnorePointer(
                        ignoring: true,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: serviceLocation,
                            zoom: 14.0,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('service_marker'),
                              position: serviceLocation,
                            ),
                          },
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.near_me,
                        color: colors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.providerAddress,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            displayAddress,
                            style: TextStyle(
                              color: colors.textSub,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasCoords) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final Uri googleMapsUrl = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=$provLat,$provLng',
                      );
                      if (await canLaunchUrl(googleMapsUrl)) {
                        await launchUrl(
                          googleMapsUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.openInMaps,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          color: colors.primary,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedDay(BuildContext context, String day) {
    final cleanDay = day.trim().toLowerCase();
    final isAr = Directionality.of(context) == TextDirection.rtl;

    if (isAr) {
      switch (cleanDay) {
        case 'saturday':
          return 'السبت';
        case 'sunday':
          return 'الأحد';
        case 'monday':
          return 'الإثنين';
        case 'tuesday':
          return 'الثلاثاء';
        case 'wednesday':
          return 'الأربعاء';
        case 'thursday':
          return 'الخميس';
        case 'friday':
          return 'الجمعة';
        default:
          return day;
      }
    } else {
      switch (cleanDay) {
        case 'saturday':
          return 'Saturday';
        case 'sunday':
          return 'Sunday';
        case 'monday':
          return 'Monday';
        case 'tuesday':
          return 'Tuesday';
        case 'wednesday':
          return 'Wednesday';
        case 'thursday':
          return 'Thursday';
        case 'friday':
          return 'Friday';
        default:
          return day;
      }
    }
  }

  String _formatTime(BuildContext context, String timeStr) {
    if (timeStr.isEmpty) return timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        final isAr = Directionality.of(context) == TextDirection.rtl;
        final period = hour >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');

        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;

        final minuteStr = minute.toString().padLeft(2, '0');
        return '$displayHour:$minuteStr $period';
      }
    } catch (e) {
      // Fallback
    }
    return timeStr;
  }

  Widget _buildWorkingHours(ServiceModel service, dynamic colors) {
    // 1. تجميع المواعيد حسب الفترة
    final Map<String, List<ServiceScheduleModel>> groups = {};
    for (var schedule in service.schedules) {
      final key =
          '${schedule.label ?? ''}_${schedule.fromTime}_${schedule.toTime}_${schedule.isActive}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(schedule);
    }

    final List<_GroupedSchedule> groupedSchedules = groups.entries.map((entry) {
      final first = entry.value.first;
      final days = entry.value.map((e) => e.day).toList();
      return _GroupedSchedule(
        label: first.label ?? '',
        fromTime: first.fromTime,
        toTime: first.toTime,
        isActive: first.isActive,
        days: days,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            AppLocalizations.of(context)!.workingHours,
            colors,
          ),
          const SizedBox(height: 16),
          if (groupedSchedules.isEmpty)
            _buildEmptyState(
              AppLocalizations.of(context)!.noWorkingHours,
              Icons.event_busy,
              colors,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedSchedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final period = groupedSchedules[index];
                final isActive = period.isActive;

                // 🟢 أولاً: تحديد عنوان الكرت (اسم الفترة أو حالة التوفر)
                final isAr = Directionality.of(context) == TextDirection.rtl;
                String displayTitle = period.label.trim().isNotEmpty
                    ? period.label
                    : (isActive
                          ? (isAr ? 'متاح' : 'Available')
                          : (isAr ? 'غير متاح' : 'Unavailable'));

                // 🕒 ثانياً: تنسيق الوقت بنظام 12 ساعة
                final fromFormatted = _formatTime(context, period.fromTime);
                final toFormatted = _formatTime(context, period.toTime);
                final displayTimeRange = '$fromFormatted - $toFormatted';

                // 🎨 رابعاً: التنسيق البصري التفاعلي حسب الحالة
                Color cardBg = isActive
                    ? colors.card
                    : colors.textSub.withOpacity(0.02);
                Color borderColor = isActive
                    ? colors.primary.withOpacity(0.2)
                    : colors.textSub.withOpacity(0.08);
                double borderThickness = isActive ? 1.5 : 1.0;
                Color titleColor = isActive
                    ? colors.text
                    : colors.textSub.withOpacity(0.6);
                Color timeColor = isActive
                    ? colors.primary
                    : colors.textSub.withOpacity(0.5);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: borderThickness,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصف العلوي: العنوان مع الوقت
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.watch_later_outlined,
                                  size: 18,
                                  color: isActive
                                      ? colors.primary
                                      : colors.textSub.withOpacity(0.4),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    displayTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: titleColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displayTimeRange,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: timeColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Divider(color: colors.text.withOpacity(0.05), height: 1),
                      const SizedBox(height: 12),

                      // 📅 ثالثاً: عرض الأيام النشطة كـ Chips داخل Wrap
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: period.days.map((day) {
                          final dayTranslated = _getTranslatedDay(context, day);

                          Color chipBg = isActive
                              ? colors.primary.withOpacity(0.08)
                              : colors.textSub.withOpacity(0.05);
                          Color chipText = isActive
                              ? colors.primary
                              : colors.textSub.withOpacity(0.5);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? colors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              dayTranslated,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: chipText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, dynamic colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.textSub.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, dynamic colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withOpacity(0.1),
                backgroundImage: review.reviewerImageUrl.isNotEmpty
                    ? NetworkImage(review.reviewerImageUrl)
                    : null,
                child: review.reviewerImageUrl.isEmpty
                    ? Icon(Icons.person, color: colors.primary, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: TextStyle(color: colors.textSub, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: colors.warning,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(color: colors.textSub, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(ServiceModel service, dynamic colors) {
    final visibleReviews = service.reviews.where((r) => !r.isHidden).toList();
    final hiddenReviews = service.reviews.where((r) => r.isHidden).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            AppLocalizations.of(context)!.customerReviews,
            colors,
          ),
          const SizedBox(height: 12),

          // 1. إذا كان المجموع الكلي فارغاً:
          if (visibleReviews.isEmpty && hiddenReviews.isEmpty)
            _buildEmptyState(
              AppLocalizations.of(context)!.noReviews,
              Icons.rate_review_outlined,
              colors,
            )
          else ...[
            // 2. عرض التقييمات الظاهرة (إن وجدت):
            if (visibleReviews.isNotEmpty)
              Column(
                children: visibleReviews
                    .map((r) => _buildReviewCard(r, colors))
                    .toList(),
              )
            else
              _buildEmptyState(
                AppLocalizations.of(context)!.noPublicReviews,
                Icons.rate_review_outlined,
                colors,
              ),

            // 3. عرض زر التحكم بالتقييمات المخفية (إن وجدت):
            if (hiddenReviews.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showHiddenReviews = !_showHiddenReviews;
                    });
                  },
                  icon: Icon(
                    _showHiddenReviews
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.primary,
                    size: 18,
                  ),
                  label: Text(
                    _showHiddenReviews
                        ? AppLocalizations.of(
                            context,
                          )!.hideHiddenReviews(hiddenReviews.length)
                        : AppLocalizations.of(
                            context,
                          )!.showHiddenReviews(hiddenReviews.length),
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: colors.primary.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. عرض التقييمات المخفية إذا تم تفعيل الخيار:
              if (_showHiddenReviews)
                Column(
                  children: hiddenReviews
                      .map((r) => _buildReviewCard(r, colors))
                      .toList(),
                ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      if (dateStr.contains(' ')) {
        return dateStr.split(' ')[0];
      }
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return dateStr;
  }

  Widget _buildBottomBar(
    ServiceModel service,
    dynamic colors,
    bool isDataLoading,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.totalCost}\n${AppLocalizations.of(context)!.estimated}',
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.textSub,
                    height: 1.2,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${service.price.toInt()} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colors.text,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.sar,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.text,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isDataLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (context) => ConfirmOrderViewModel(
                                mainService: service,
                                repository: RequestRepository(
                                  context.read<ApiService>(),
                                ),
                              ),
                              child: const ConfirmOrderView(),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isDataLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.bookNow,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back
                                : Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, dynamic colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
    );
  }

  Widget _buildDivider(dynamic colors) {
    return Divider(
      height: 32,
      thickness: 8,
      color: colors.text.withOpacity(0.02),
    );
  }
}

class _GroupedSchedule {
  final String label;
  final String fromTime;
  final String toTime;
  final bool isActive;
  final List<String> days;

  _GroupedSchedule({
    required this.label,
    required this.fromTime,
    required this.toTime,
    required this.isActive,
    required this.days,
  });
}
