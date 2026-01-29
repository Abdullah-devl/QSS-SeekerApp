import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'pick_location_view.dart';
import '../viewmodels/be_provider_view_model.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 📂 اسم الملف: be_provider_view.dart
/// 📝 الوصف: واجهة المستخدم لطلب الانضمام كمزود خدمة.
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
                  height: 150,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.textSub.withOpacity(0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: viewModel.selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            viewModel.selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Color(0xFF1E88E5),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.uploadIdCard,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
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
            // 4. الموقع
            // =================================================================
            _buildCard(
              context,
              title: AppLocalizations.of(context)!.serviceLocation,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFD7CCC8,
                  ), // لون خلفية مقارب للتصميم (بني فاتح)
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEFEBE9), Color(0xFFA1887F)],
                  ),
                ),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PickLocationView(),
                        ),
                      );

                      if (result != null && result is Map) {
                        final LatLng latLng = result['latLng'];
                        final String address = result['address'];
                        viewModel.setLocation(
                          latLng.latitude,
                          latLng.longitude,
                          address,
                        );
                      }
                    },
                    icon: const Icon(Icons.near_me, color: Color(0xFF00796B)),
                    label: Text(
                      viewModel.location.isEmpty
                          ? AppLocalizations.of(context)!.pickLocationOnMap
                          : viewModel.location,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
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
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.submitRequest();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.requestSentSuccess,
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } else if (viewModel.errorMessage != null &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(viewModel.errorMessage!)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF539DB9,
                  ), // لون أزرق سماوي مثل التصميم
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            // AppLocalizations.of(context)!.sendRequest,
                            "Send Request",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
