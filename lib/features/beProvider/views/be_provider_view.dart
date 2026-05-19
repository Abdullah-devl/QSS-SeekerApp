import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
import '../../../../core/theme/qs_color_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'pick_location_view.dart';
import '../viewmodels/be_provider_view_model.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 📂 اسم الملف: be_provider_view.dart
/// 📝 الوصف: واجهة المستخدم لطلب الانضمام كمزود خدمة (مع خريطة احترافية).
class BeProviderView extends StatelessWidget {
  const BeProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final viewModel = context.watch<BeProviderViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.beProviderTitle,
          style: TextStyle(
            color: colors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =================================================================
            // 1. حقل الاسم الكامل
            // =================================================================
            _buildCard(
              context,
              title: AppLocalizations.of(context)!.fullName,
              child: TextField(
                controller: viewModel.nameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterFullName,
                  hintStyle: TextStyle(color: colors.textSub),
                  prefixIcon: Icon(Icons.person, color: colors.textSub),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 2. صورة الهوية
            // =================================================================
            _buildCard(
              context,
              title: AppLocalizations.of(context)!.idCardOrPassport,
              child: GestureDetector(
                onTap: viewModel.pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity, // يمتد على كامل عرض البطاقة
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: viewModel.selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            viewModel.selectedImage!,
                            width: double.infinity,
                            height: double.infinity, // ملء الارتفاع بالكامل
                            fit: BoxFit.cover, // تغطية كامل المساحة
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: colors.primary,
                                size: 35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.uploadIdCard,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.imageSizeHint,
                              style: TextStyle(
                                color: colors.textSub,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 3. وصف الطلب
            // =================================================================
            _buildCard(
              context,
              title: AppLocalizations.of(context)!.requestDescription,
              child: TextField(
                controller: viewModel.descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  )!.requestDescriptionHint,
                  hintStyle: TextStyle(color: colors.textSub),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.textSub.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 4. الموقع (باحترافية تطبيقات التوصيل - الخريطة المصغرة)
            // =================================================================
            _buildCard(
              context,
              title: AppLocalizations.of(context)!.serviceLocation,
              child: viewModel.location.isEmpty
                  // 🔴 الحالة الأولى: لم يقم باختيار موقع بعد
                  ? InkWell(
                      onTap: () => _openMapPicker(context, viewModel),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: colors.primary,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.pickLocationOnMap,
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // 🟢 الحالة الثانية: قام باختيار الموقع (نعرض خريطة مصغرة لموقعه)
                  : Column(
                      children: [
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: IgnorePointer(
                              // نمنع التفاعل مع الخريطة المصغرة لكي لا تزعج المستخدم أثناء التمرير
                              ignoring: true,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    viewModel.latitude,
                                    viewModel.longitude,
                                  ),
                                  zoom: 16.0, // تقريب ممتاز لرؤية الشوارع
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId(
                                      'selected_location',
                                    ),
                                    position: LatLng(
                                      viewModel.latitude,
                                      viewModel.longitude,
                                    ),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueRed,
                                    ),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                                myLocationButtonEnabled: false,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              color: colors.textSub,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.location, // اسم الشارع أو التفاصيل
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _openMapPicker(context, viewModel),
                              icon: Icon(
                                Icons.edit_location_alt,
                                size: 16,
                                color: colors.primary,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.edit,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 30),

            // =================================================================
            // 5. زر الإرسال
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final l10n = AppLocalizations.of(context)!;
                  // 1️⃣ التحقق من إدخال جميع الحقول الأساسية أولاً لتجنب إظهار الديالوجات دون داعٍ
                  if (viewModel.nameController.text.isEmpty ||
                      viewModel.descController.text.isEmpty ||
                      viewModel.selectedImage == null ||
                      viewModel.location.isEmpty) {
                    QSAlerts.showWarning(context, l10n.beProviderValidation);
                    return;
                  }

                  // 2️⃣ إظهار تنبيه تأكيد إرسال الطلب
                  final confirmed = await QSAlerts.showConfirmJoinProvider(context);
                  if (!confirmed) return;

                  // 3️⃣ إظهار ديالوج التحميل الزجاجي الفاخر
                  if (context.mounted) {
                    QSAlerts.showLoading(context);
                  }

                  // 4️⃣ تنفيذ إرسال الطلب للسيرفر
                  final success = await viewModel.submitRequest(context);

                  // 5️⃣ إغلاق ديالوج التحميل
                  if (context.mounted) {
                    QSAlerts.hideLoading(context);
                  }

                  if (success && context.mounted) {
                    // 6️⃣ إظهار أليارت النجاح الفخم والانتظار حتى يضغط المستخدم حسناً
                    await QSAlerts.showSuccess(context, l10n.beProviderSubmitSuccess);
                    
                    // 7️⃣ التوجيه إلى الصفحة الرئيسية وتصفير الملاحة
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    }
                  } else if (context.mounted) {
                    // 8️⃣ إظهار أليارت الفشل بناءً على الرسالة الراجعة من الباك اند
                    final errorMsg = viewModel.errorMessage ?? l10n.beProviderSubmitFailed;
                    await QSAlerts.showError(context, errorMsg);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary, // لون متجاوب من Palette
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.sendRequest,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.send, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🧩 الدوال المساعدة (Helper Methods)
  // =========================================================================

  /// 🗺️ دالة فتح شاشة اختيار الخريطة (PickLocationView) واستقبال البيانات
  Future<void> _openMapPicker(
    BuildContext context,
    BeProviderViewModel viewModel,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickLocationView()),
    );

    // إذا عاد المستخدم ببيانات (ضغط على تأكيد الموقع)
    if (result != null && result is Map) {
      final LatLng latLng = result['latLng'];
      final String address = result['address'];

      // نرسل خطوط الطول والعرض واسم الشارع إلى الـ ViewModel
      viewModel.setLocation(latLng.latitude, latLng.longitude, address);
    }
  }

  /// 🛠️ ودجت مساعدة لبناء البطاقات
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.qsColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.qsColors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: context.qsColors.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
