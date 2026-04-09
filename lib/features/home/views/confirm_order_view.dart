import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../services/models/service_model.dart';
import '../viewmodels/confirm_order_view_model.dart';
import '../../beProvider/views/pick_location_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 📂 اسم الملف: confirm_order_view.dart
/// 📝 الوصف: شاشة تأكيد وتخصيص الطلب بتصميم عصري (Premium).
class ConfirmOrderView extends StatelessWidget {
  const ConfirmOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ConfirmOrderViewModel>();
    final service = vm.mainService;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تأكيد وتخصيص الطلب',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ كرت الخدمة الاحترافي
                  _buildServiceCard(context, service, colors),
                  const SizedBox(height: 24),

                   // 2️⃣ مربع بيانات طالب الخدمة
                  _buildUserInfoSection(context, vm, colors),
                  const SizedBox(height: 24),

                  // 📍 جديد: قسم اختيار الموقع
                  _buildLocationSection(context, vm, colors),
                  const SizedBox(height: 24),

                  // 3️⃣ قسم الخدمات الفرعية (التخصيص)
                  _buildCustomizationSection(context, vm, colors),
                  const SizedBox(height: 24),

                  // 4️⃣ قسم الملاحظات
                  _buildNotesSection(context, vm, colors),
                ],
              ),
            ),
            const SizedBox(height: 100), // مساحة للبار السفلي
          ],
        ),
      ),
      bottomSheet: _buildBottomCheckoutBar(context, vm, colors),
    );
  }

  /// 🌟 1. كرت الخدمة المطور (صورة، اسم، تقييم، سعر)
  Widget _buildServiceCard(BuildContext context, ServiceModel service, dynamic colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // صورة الخدمة
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: service.imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(service.imageUrl), fit: BoxFit.cover)
                  : null,
              color: colors.primary.withOpacity(0.1),
            ),
            child: service.imageUrl.isEmpty ? Icon(Icons.image, size: 50, color: colors.textSub) : null,
          ),
          // تفاصيل الخدمة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.text)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            service.rating > 0 ? '${service.rating}' : 'جديد',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors.text),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.person_outline, color: colors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(service.providerName, style: TextStyle(fontSize: 12, color: colors.textSub)),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary, fontFamily: 'Cairo'),
                    ),
                    Text('ر.س', style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 👤 2. مربع بيانات العميل (Requester Info)
  Widget _buildUserInfoSection(BuildContext context, ConfirmOrderViewModel vm, dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.text.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Text('بيانات طلب الخدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(vm.userNameController, 'اسم المستلم', Icons.person_outline, colors),
          const SizedBox(height: 16),
          _buildTextField(vm.userPhoneController, 'رقم الجوال', Icons.phone_android_rounded, colors, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  /// 📍 3. قسم اختيار الموقع من الخريطة
  Widget _buildLocationSection(BuildContext context, ConfirmOrderViewModel vm, dynamic colors) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PickLocationView()),
        );

        if (result != null && result is Map) {
          final latLng = result['latLng'] as LatLng;
          final address = result['address'] as String;
          vm.setLocation(latLng.latitude, latLng.longitude, address);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: vm.selectedLatitude != null ? colors.primary.withOpacity(0.3) : colors.text.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Text('موقع تقديم الخدمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
                const Spacer(),
                if (vm.selectedLatitude != null)
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: vm.selectedLatitude != null ? Colors.redAccent : colors.textSub, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vm.selectedAddress ?? 'اضغط لتحديد موقعك على الخريطة',
                      style: TextStyle(
                        color: vm.selectedAddress != null ? colors.text : colors.textSub,
                        fontSize: 14,
                        fontWeight: vm.selectedAddress != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: colors.textSub, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, dynamic colors, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textSub, fontSize: 13),
        prefixIcon: Icon(icon, color: colors.primary, size: 20),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  /// 🛠️ 3. قسم الخدمات الفرعية
  Widget _buildCustomizationSection(BuildContext context, ConfirmOrderViewModel vm, dynamic colors) {
    if (vm.subServices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: colors.text, size: 20),
              const SizedBox(width: 8),
              Text('الخدمات الإضافية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: List.generate(vm.subServices.length, (index) {
              final sub = vm.subServices[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: index != vm.subServices.length - 1 ? Border(bottom: BorderSide(color: colors.text.withOpacity(0.05))) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sub.title, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 14)),
                          Text('${sub.price.toInt()} ر.س', style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildCounterBtn(Icons.remove, () => vm.decrementSubService(index), colors, isSub: true),
                        SizedBox(width: 40, child: Center(child: Text('${sub.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.text)))),
                        _buildCounterBtn(Icons.add, () => vm.incrementSubService(index), colors),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap, dynamic colors, {bool isSub = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSub ? colors.background : colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isSub ? colors.textSub : colors.primary, size: 18),
      ),
    );
  }

  /// 📝 4. قسم الملاحظات
  Widget _buildNotesSection(BuildContext context, ConfirmOrderViewModel vm, dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note_rounded, color: colors.text, size: 24),
            const SizedBox(width: 8),
            Text('ملاحظات إضافية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: vm.notesController,
          maxLines: 4,
          style: TextStyle(color: colors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'اكتب هنا أي تفاصيل تريد لمقدم الخدمة معرفتها...',
            hintStyle: TextStyle(color: colors.textSub, fontSize: 12),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  /// 🏁 5. بار الدفع السفلي
  Widget _buildBottomCheckoutBar(BuildContext context, ConfirmOrderViewModel vm, dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي النهائي', style: TextStyle(fontWeight: FontWeight.bold, color: colors.textSub, fontSize: 14)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${vm.finalTotal.toStringAsFixed(1)} ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: colors.primary, fontFamily: 'Cairo')),
                    TextSpan(text: 'ر.س', style: TextStyle(fontSize: 14, color: colors.text, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : () async {
                final success = await vm.confirmOrder();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح! 🚀')));
                  Navigator.pop(context);
                } else if (vm.errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.redAccent));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تأكيد وحجز الخدمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}