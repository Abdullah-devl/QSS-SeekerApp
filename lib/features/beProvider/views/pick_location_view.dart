import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 📂 اسم الملف: pick_location_view.dart
/// 📝 الوصف: شاشة اختيار الموقع من الخريطة بدقة باستخدام Google Maps.
class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition; // الإحداثيات الحالية للمُشير (منتصف الشاشة)
  String _address = '';
  bool _isLoading = true;
  bool _isAddressing = false;
  Timer? _debounce;

  // موقع افتراضي (الرياض) في حال لم نتمكن من جلب الموقع الحالي فوراً
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(14.5425, 49.1242), // المكلا
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    // _determinePosition();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _determinePosition(); // ✅ context صار جاهز
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Logic)
  // ---------------------------------------------------------------------------

  /// 📍 تحديد الموقع الحالي عند فتح الشاشة
  Future<void> _determinePosition() async {
    setState(() {
      _address = AppLocalizations.of(context)!.determiningAddress;
      _isAddressing = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(AppLocalizations.of(context)!.locationServicesDisabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
            AppLocalizations.of(context)!.locationPermissionsDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          AppLocalizations.of(context)!.locationPermissionsPermanentlyDenied,
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // تحريك الكاميرا للموقع الحالي
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 17),
        ),
      );

      _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoading = false;
        _isAddressing = false;
        // نستخدم الموقع الافتراضي
        // _currentPosition = _kDefaultLocation.target;
      });
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  /// 🏠 جلب اسم العنوان من الإحداثيات
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // تكوين نص العنوان
        String street = place.street ?? '';
        String locality = place.locality ?? '';
        String subAdminArea = place.subAdministrativeArea ?? '';

        setState(() {
          _address = '$street، $locality، $subAdminArea'.replaceAll(
            RegExp(r'^، |، $'),
            '',
          );
          if (_address.isEmpty)
            _address = AppLocalizations.of(context)!.unknownLocation;
          _isAddressing = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _address = AppLocalizations.of(context)!.unableToDetermineAddress;
        _isAddressing = false;
      });
    }
  }

  /// 🎥 عند تحريك الكاميرا
  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
    // لا نجلب العنوان أثناء الحركة المستمرة لتجنب كثرة الطلبات
    setState(() {
      _address = AppLocalizations.of(context)!.determiningLocation;
      _isAddressing = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (_currentPosition != null) {
        _getAddressFromLatLng(_currentPosition!);
      }
    });
  }

  /// ✅ تأكيد الاختيار
  void _confirmLocation() {
    if (_currentPosition != null) {
      Navigator.pop(context, {'latLng': _currentPosition, 'address': _address});
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ الخريطة
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kDefaultLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // سنضع زر مخصص
            zoomControlsEnabled: false,
          ),

          // 📍 أيقونة التثبيت في المنتصف
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 30,
              ), // رفع الأيقونة قليلاً لتشير بدقة
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),

          // 🔙 زر الرجوع
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 🎯 زر الذهاب للموقع الحالي
          Positioned(
            bottom: 180, // فوق البطاقة السفلية
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // 📝 بطاقة العنوان وزر التأكيد
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectedLocation,
                    style: TextStyle(color: colors.textSub, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isAddressing ? null : _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF539DB9),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirmLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ⏳ مؤشر تحميل أولي
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
