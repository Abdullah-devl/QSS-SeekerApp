import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/viewmodels/confirm_order_view_model.dart';
import 'package:seeker/features/home/views/confirm_order_view.dart';
import 'package:seeker/features/profile/view/profile_view.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/profile/requests/repository/request_repository.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/features/profile/viewmodels/profile_view_model.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';

class ServiceDetailsView extends StatefulWidget {
  final ServiceModel initialService;

  const ServiceDetailsView({super.key, required this.initialService});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
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
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          final service = vm.service!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(service.imageUrl, colors),
                _buildMainInfo(service, colors),
                _buildProviderCard(service, colors),
                _buildDivider(colors),
                _buildDescription(service.description, colors),
                _buildLocation(colors),
                _buildWorkingHours(service, colors),
                _buildReviews(colors),
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
    final service = vm.service; 

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      centerTitle: true,
      title: Text(AppLocalizations.of(context)!.serviceDetails, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            vm.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: vm.isFavorite ? Colors.redAccent : colors.text,
          ),
          onPressed: vm.toggleFavorite,
        ),
        IconButton(
          icon: Icon(Icons.share_outlined, color: colors.text),
          onPressed: () {
            if (service != null) {
              Share.share('مرحباً! اكتشف هذه الخدمة الرائعة: "${service.title}" من ${service.providerName}، بسعر ${service.price.toInt()} ر.س فقط! \nحمل تطبيقنا للحجز الآن.');
            }
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
      ),
      child: imageUrl.isEmpty
          ? Center(child: Icon(Icons.image, size: 50, color: colors.textSub.withOpacity(0.3)))
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
                Text(service.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.text, height: 1.3)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.availableNow, style: TextStyle(color: Colors.greenAccent[700], fontWeight: FontWeight.bold, fontSize: 12)),
                    Container(margin: const EdgeInsets.symmetric(horizontal: 8), height: 12, width: 1, color: colors.textSub.withOpacity(0.3)),
                    Text('120 ${AppLocalizations.of(context)!.customerReviews}', style: TextStyle(color: colors.textSub, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Text(service.rating > 0 ? service.rating.toString() : AppLocalizations.of(context)!.newService, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 12),
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
              Text('${service.price.toInt()}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary, fontFamily: 'Cairo', height: 1.1)),
              Text(AppLocalizations.of(context)!.sar, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary, fontFamily: 'Cairo')),
              Text(AppLocalizations.of(context)!.perService, style: TextStyle(fontSize: 10, color: colors.textSub)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ServiceModel service, dynamic colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: colors.primary.withOpacity(0.1), child: Icon(Icons.person, color: colors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.providerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colors.text)),
                const SizedBox(height: 2),
                Text(AppLocalizations.of(context)!.yearsExperience(4), style: TextStyle(color: colors.textSub, fontSize: 11)),
              ],
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(
                AppLocalizations.of(context)!.visitProfile,
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13),
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
          _buildSectionTitle(AppLocalizations.of(context)!.serviceDescription, colors),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty ? description : '...',
            style: TextStyle(color: colors.textSub, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(dynamic colors) {
    const LatLng serviceLocation = LatLng(24.7136, 46.6753);
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.text.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: IgnorePointer(
                      ignoring: true,
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(target: serviceLocation, zoom: 14.0),
                        markers: {const Marker(markerId: MarkerId('service_marker'), position: serviceLocation)},
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.near_me, color: colors.primary, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الرياض، حي الملقا', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 14)),
                          Text('شارع الأمير محمد بن سعد، مبنى رقم 45', style: TextStyle(color: colors.textSub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    if (await canLaunchUrl(googleMapsUrl)) {
                      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.openInMaps, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, color: colors.primary, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours(ServiceModel service, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppLocalizations.of(context)!.workingHours, colors),
          const SizedBox(height: 12),
          if (service.schedules.isEmpty)
            _buildEmptyState(AppLocalizations.of(context)!.noWorkingHours, Icons.event_busy, colors)
          else
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: service.schedules.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final schedule = service.schedules[index];
                  final isActive = schedule.isActive;
                  return Container(
                    width: 95,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? colors.primary.withOpacity(0.05) : colors.textSub.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isActive ? colors.primary.withOpacity(0.2) : colors.textSub.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(schedule.day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? colors.primary : colors.textSub)),
                        const SizedBox(height: 8),
                        if (isActive) ...[
                          Text(schedule.fromTime, style: TextStyle(fontSize: 10, color: colors.text)),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 10, color: Colors.grey),
                          Text(schedule.toTime, style: TextStyle(fontSize: 10, color: colors.text)),
                        ] else
                          Text('مغلق', style: TextStyle(fontSize: 12, color: Colors.redAccent.withOpacity(0.7), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
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
        color: Theme.of(context).cardColor,
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



  Widget _buildReviews(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppLocalizations.of(context)!.customerReviews, colors),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.text.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: colors.primary.withOpacity(0.1), child: Icon(Icons.person, color: colors.primary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text('سارة العلي', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 14))),
                    Text('منذ يومين', style: TextStyle(color: colors.textSub, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'خدمة ممتازة جداً والفريق وصل في الوقت المحدد. قاموا بتنظيف كل زاوية في المنزل بدقة. أنصح بهم بشدة!',
                  style: TextStyle(color: colors.textSub, fontSize: 12, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ServiceModel service, dynamic colors, bool isDataLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppLocalizations.of(context)!.totalCost}\n${AppLocalizations.of(context)!.estimated}', style: TextStyle(fontSize: 10, color: colors.textSub, height: 1.2)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '${service.price.toInt()} ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colors.text, fontFamily: 'Cairo')),
                      TextSpan(text: AppLocalizations.of(context)!.sar, style: TextStyle(fontSize: 12, color: colors.text, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isDataLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => ConfirmOrderViewModel(
                          mainService: service,
                          repository: RequestRepository(context.read<ApiService>()),
                        ),
                        child: const ConfirmOrderView(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isDataLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.bookNow, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text));
  }

  Widget _buildDivider(dynamic colors) {
    return Divider(height: 32, thickness: 8, color: colors.text.withOpacity(0.02));
  }
}