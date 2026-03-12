import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/viewmodels/confirm_order_view_model.dart';
import 'package:seeker/features/home/views/confirm_order_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_model.dart';
import '../viewmodels/service_details_view_model.dart';

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
                _buildWorkingHours(colors),
                _buildBankAccounts(context, colors),
                _buildImageGallery(colors),
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
      title: Text('معلومات الخدمة', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18)),
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
          : Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('5 صور', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                    Text('متاح الآن', style: TextStyle(color: Colors.greenAccent[700], fontWeight: FontWeight.bold, fontSize: 12)),
                    Container(margin: const EdgeInsets.symmetric(horizontal: 8), height: 12, width: 1, color: colors.textSub.withOpacity(0.3)),
                    Text('120 تقييم', style: TextStyle(color: colors.textSub, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Text(service.rating > 0 ? service.rating.toString() : 'جديد', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
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
              Text('ر.س', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary, fontFamily: 'Cairo')),
              Text('لكل خدمة/ساعة', style: TextStyle(fontSize: 10, color: colors.textSub)),
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
                Text('خبير تنظيف • 4 سنوات خبرة', style: TextStyle(color: colors.textSub, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.chat_bubble_rounded, color: colors.primary, size: 20),
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
          _buildSectionTitle('وصف الخدمة', colors),
          const SizedBox(height: 12),
          Text(
            description.isNotEmpty ? description : 'نقدم خدمة تنظيف شاملة واحترافية باستخدام أحدث المعدات والمواد الآمنة.',
            style: TextStyle(color: colors.textSub, height: 1.6, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Text('مميزات الخدمة:', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 13)),
          const SizedBox(height: 10),
          _buildFeatureItem('استخدام مواد تعقيم مصرحة وآمنة', colors),
          _buildFeatureItem('فريق عمل محترف ومدرب', colors),
          _buildFeatureItem('ضمان الرضا عن الخدمة', colors),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: colors.textSub, fontSize: 12)),
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
          _buildSectionTitle('موقع الخدمة', colors),
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
                      Text('فتح في الخرائط', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildWorkingHours(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('أوقات الخدمة', colors),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.text.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('ساعات العمل المتاحة', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('من الأحد إلى الخميس', style: TextStyle(color: colors.textSub, fontSize: 12)),
                    Text('08:00 AM - 10:00 PM', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 12)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الجمعة والسبت', style: TextStyle(color: colors.textSub, fontSize: 12)),
                    Text('02:00 PM - 11:00 PM', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccounts(BuildContext context, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('الحسابات البنكية', colors),
          const SizedBox(height: 12),
          _buildBankCard(context, 'مصرف الراجحي', 'أحمد المحمد', 'SA45 8000 0000 6080 1020 3040', colors),
          const SizedBox(height: 12),
          _buildBankCard(context, 'البنك الأهلي SNB', 'أحمد المحمد', 'SA20 1000 0000 4455 6677 8899', colors),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, String bankName, String accountName, String iban, dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bankName, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 14)),
                  Text(accountName, style: TextStyle(color: colors.textSub, fontSize: 11)),
                ],
              ),
              Icon(Icons.account_balance, color: colors.textSub.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IBAN', style: TextStyle(color: colors.textSub, fontSize: 10)),
                      Text(iban, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 12, letterSpacing: 1.2)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: iban));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('تم نسخ رقم الحساب بنجاح ✅', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.copy, color: colors.primary, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('معرض الصور', colors),
              Text('عرض الكل', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.text.withOpacity(0.05)),
                  ),
                  child: Center(child: Icon(Icons.image, color: colors.textSub.withOpacity(0.3))),
                );
              },
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
          _buildSectionTitle('آراء العملاء', colors),
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

  /// 🔘 10. الزر السفلي لطلب الخدمة (مُصلح ومربوط بشاشة التأكيد)
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
                Text('التكلفة الإجمالية\n(تقديرية)', style: TextStyle(fontSize: 10, color: colors.textSub, height: 1.2)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '${service.price.toInt()} ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colors.text, fontFamily: 'Cairo')),
                      TextSpan(text: 'ر.س', style: TextStyle(fontSize: 12, color: colors.text, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                // 🚀 نمنع الضغط إذا كانت البيانات لا تزال تحمل من السيرفر
                onPressed: isDataLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        // 🚀 نمرر الخدمة الكاملة (التي جاءت من السيرفر وبها أبناء) لشاشة التأكيد
                        create: (_) => ConfirmOrderViewModel(mainService: service),
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('طلب الخدمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_back, color: Colors.white, size: 20),
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