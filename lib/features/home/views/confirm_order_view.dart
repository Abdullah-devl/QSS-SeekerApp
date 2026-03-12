import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import '../models/service_model.dart';
import '../viewmodels/confirm_order_view_model.dart';

/// 📂 اسم الملف: confirm_order_view.dart
/// 📝 الوصف: شاشة تأكيد وتخصيص الطلب.
class ConfirmOrderView extends StatelessWidget {
  const ConfirmOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ConfirmOrderViewModel>();

    // 🚀 نستخدم mainService القادمة من الـ ViewModel
    final service = vm.mainService;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تأكيد وتخصيص الطلب',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 0),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceSummaryCard(context, service, colors),
                    const SizedBox(height: 24),
                    _buildLocationSection(context, colors),
                    const SizedBox(height: 24),
                    
                    // 🚀 قسم التخصيص (الذي يعالج حالة تحميل الخدمات الفرعية من السيرفر)
                    _buildCustomizationSection(context, vm, colors),
                    const SizedBox(height: 24),
                    
                    _buildNotesSection(context, vm, colors),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildBottomCheckoutBar(context, vm, colors),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 🧩 المكونات (Widgets)
  // =========================================================================

  /// 1️⃣ كرت ملخص الخدمة العلوي
  Widget _buildServiceSummaryCard(
    BuildContext context,
    ServiceModel service,
    dynamic colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundColor: colors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 10, color: colors.primary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.providerName,
                    style: TextStyle(fontSize: 12, color: colors.textSub),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    service.rating > 0 ? service.rating.toString() : 'جديد',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag('خدمة فورية', Colors.green, colors),
                  const SizedBox(width: 8),
                  _buildTag('ضمان ذهبي', Colors.amber, colors),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            image: service.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(service.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: service.imageUrl.isEmpty
              ? Icon(Icons.image, color: colors.textSub)
              : null,
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color iconColor, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: iconColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 2️⃣ قسم موقع الخدمة
  Widget _buildLocationSection(BuildContext context, dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'موقع الخدمة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.text.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              // أزرار التبديل (موقعي الحالي / الخريطة)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.my_location,
                              color: colors.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'موقعي الحالي',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: colors.textSub,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الخريطة',
                              style: TextStyle(
                                color: colors.textSub,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // حقل البحث
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن عنوان أو معلم معروف...',
                    hintStyle: TextStyle(color: colors.textSub, fontSize: 12),
                    icon: Icon(Icons.search, color: colors.textSub, size: 18),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // العنوان المحفوظ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.home, color: colors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المنزل',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'الرياض، حي الملقا، شارع الأمير محمد بن سعد',
                            style: TextStyle(
                              color: colors.textSub,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: colors.primary, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // زر التحديد على الخريطة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: colors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'تحديد على الخريطة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3️⃣ قسم تخصيص الخدمات (العدادات)
  Widget _buildCustomizationSection(
    BuildContext context,
    ConfirmOrderViewModel vm,
    dynamic colors,
  ) {
    // 🚀 إذا كانت البيانات لا تزال تُحمل من السيرفر، نعرض مؤشر دوران
    if (vm.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    // 🚀 إذا اكتمل التحميل ولم توجد خدمات فرعية، لا نعرض القسم
    if (vm.subServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, color: colors.text, size: 20),
            const SizedBox(width: 8),
            Text(
              'تخصيص الخدمات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(vm.subServices.length, (index) {
          final subService = vm.subServices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subService.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                        fontSize: 14,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${subService.price.toInt()} ر.س',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          TextSpan(
                            text: ' / خدمة',
                            style: TextStyle(
                              color: colors.textSub,
                              fontSize: 10,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // العداد
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => vm.incrementSubService(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: colors.primary, size: 16),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '${subService.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colors.text,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => vm.decrementSubService(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: colors.textSub,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 4️⃣ قسم الملاحظات الإضافية
  Widget _buildNotesSection(
    BuildContext context,
    ConfirmOrderViewModel vm,
    dynamic colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes, color: colors.text, size: 20),
            const SizedBox(width: 8),
            Text(
              'ملاحظات إضافية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: vm.notesController,
          maxLines: 3,
          style: TextStyle(color: colors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'اكتب أي تعليمات خاصة لمقدم الخدمة هنا...',
            hintStyle: TextStyle(color: colors.textSub, fontSize: 12),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// 🔴 5. البطاقة السفلية الثابتة (إجمالي الحساب وزر التأكيد)
  Widget _buildBottomCheckoutBar(
    BuildContext context,
    ConfirmOrderViewModel vm,
    dynamic colors,
  ) {
    int totalItems = vm.subServices
        .where((a) => a.quantity > 0)
        .fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الفرعي ($totalItems عناصر)',
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
              Text(
                '${vm.subTotal.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  color: colors.textSub,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ضريبة القيمة المضافة (15%)',
                style: TextStyle(color: colors.textSub, fontSize: 12),
              ),
              Text(
                '${vm.vatAmount.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  color: colors.textSub,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي النهائي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                  fontSize: 14,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${vm.finalTotal.toStringAsFixed(1)} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: colors.primary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    TextSpan(
                      text: 'ر.س',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.text,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final success = await vm.confirmOrder();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تأكيد الطلب بنجاح! ✅'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تأكيد الطلب',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
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