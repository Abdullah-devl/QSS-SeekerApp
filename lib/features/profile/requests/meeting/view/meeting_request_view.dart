import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
import '../viewmodel/meeting_request_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seeker/features/beProvider/views/pick_location_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 📂 اسم الملف: meeting_request_view.dart
/// 📝 الوصف: شاشة طلب حضور (لقاء جسدي) لمقدم الخدمة.
class MeetingRequestView extends StatelessWidget {
  const MeetingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<MeetingRequestViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلب حضور',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colors),
            const SizedBox(height: 32),
            _buildLocationSection(context, vm, colors),
            const SizedBox(height: 48),
            _buildSubmitButton(context, vm, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طلب لقاء جسدي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك طلب حضور مقدم الخدمة لموقعك لمناقشة العمل أو معاينة المشكلة.',
          style: TextStyle(fontSize: 14, color: colors.textSub, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    MeetingRequestViewModel vm,
    dynamic colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'موقع اللقاء',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () async {
                try {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                  }
                  if (permission == LocationPermission.whileInUse ||
                      permission == LocationPermission.always) {
                    Position position = await Geolocator.getCurrentPosition();
                    String address = '';
                    try {
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                            position.latitude,
                            position.longitude,
                          );
                      if (placemarks.isNotEmpty) {
                        Placemark place = placemarks[0];
                        address = '${place.street}، ${place.locality}';
                      }
                    } catch (e) {
                      address = 'موقع مخصص';
                    }
                    vm.updateLocation(
                      position.latitude,
                      position.longitude,
                      address,
                    );
                  }
                } catch (e) {
                  QSAlerts.showError(context, 'فشل تحديد الموقع');
                }
              },
              icon: Icon(Icons.my_location, size: 18, color: colors.primary),
              label: Text(
                'تحديد موقعي الحالي',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PickLocationView()),
            );
            if (result != null && result is Map<String, dynamic>) {
              final LatLng latLng = result['latLng'];
              final String address = result['address'];
              vm.updateLocation(latLng.latitude, latLng.longitude, address);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'اختيار من الخريطة',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: colors.primary),
              ],
            ),
          ),
        ),
        if (vm.address != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.address!,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        Text(
          'تأكد من دقة الموقع لضمان وصول مقدم الخدمة.',
          style: TextStyle(
            fontSize: 12,
            color: colors.textSub.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    MeetingRequestViewModel vm,
    dynamic colors,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : () => _handleSubmission(context, vm),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: vm.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'إرسال طلب الحضور',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _handleSubmission(
    BuildContext context,
    MeetingRequestViewModel vm,
  ) async {
    await vm.sendRequest();
    if (context.mounted) {
      if (vm.successMessage != null) {
        QSAlerts.showSuccess(context, vm.successMessage!);
        Navigator.pop(context); // Close the view on success
      } else if (vm.errorMessage != null) {
        QSAlerts.showError(context, vm.errorMessage!);
      }
    }
  }
}
