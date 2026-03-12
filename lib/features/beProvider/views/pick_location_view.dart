// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:seeker/l10n/app_localizations.dart';
// import '../../../../core/theme/qs_color_extension.dart';
// // import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// /// 📂 اسم الملف: pick_location_view.dart
// /// 📝 الوصف: شاشة اختيار الموقع من الخريطة بدقة باستخدام Google Maps.
// class PickLocationView extends StatefulWidget {
//   const PickLocationView({super.key});

//   @override
//   State<PickLocationView> createState() => _PickLocationViewState();
// }

// class _PickLocationViewState extends State<PickLocationView> {
//   // ---------------------------------------------------------------------------
//   // 📊 المتغيرات (State)
//   // ---------------------------------------------------------------------------
//   Completer<GoogleMapController> _controller = Completer();
//   LatLng? _currentPosition; // الإحداثيات الحالية للمُشير (منتصف الشاشة)
//   String _address = '';
//   bool _isLoading = true;
//   bool _isAddressing = false;
//   Timer? _debounce;

//   // موقع افتراضي (الرياض) في حال لم نتمكن من جلب الموقع الحالي فوراً
//   static const CameraPosition _kDefaultLocation = CameraPosition(
//     target: LatLng(14.5425, 49.1242), // المكلا
//     zoom: 14,
//   );

//   @override
//   void initState() {
//     super.initState();
//     // _determinePosition();
//   }

//   bool _initialized = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_initialized) {
//       _initialized = true;
//       _determinePosition(); // ✅ context صار جاهز
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // ⚙️ العمليات (Logic)
//   // ---------------------------------------------------------------------------

//   /// 📍 تحديد الموقع الحالي عند فتح الشاشة
//   Future<void> _determinePosition() async {
//     setState(() {
//       _address = AppLocalizations.of(context)!.determiningAddress;
//       _isAddressing = true;
//     });

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception(AppLocalizations.of(context)!.locationServicesDisabled);
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception(
//             AppLocalizations.of(context)!.locationPermissionsDenied,
//           );
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception(
//           AppLocalizations.of(context)!.locationPermissionsPermanentlyDenied,
//         );
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//         _isLoading = false;
//       });

//       // تحريك الكاميرا للموقع الحالي
//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: _currentPosition!, zoom: 17),
//         ),
//       );

//       _getAddressFromLatLng(_currentPosition!);
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       setState(() {
//         _isLoading = false;
//         _isAddressing = false;
//         // نستخدم الموقع الافتراضي
//         // _currentPosition = _kDefaultLocation.target;
//       });
//       _getAddressFromLatLng(_currentPosition!);
//     }
//   }

//   /// 🏠 جلب اسم العنوان من الإحداثيات
//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         // تكوين نص العنوان
//         String street = place.street ?? '';
//         String locality = place.locality ?? '';
//         String subAdminArea = place.subAdministrativeArea ?? '';

//         setState(() {
//           _address = '$street، $locality، $subAdminArea'.replaceAll(
//             RegExp(r'^، |، $'),
//             '',
//           );
//           if (_address.isEmpty)
//             _address = AppLocalizations.of(context)!.unknownLocation;
//           _isAddressing = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error getting address: $e');
//       setState(() {
//         _address = AppLocalizations.of(context)!.unableToDetermineAddress;
//         _isAddressing = false;
//       });
//     }
//   }

//   /// 🎥 عند تحريك الكاميرا
//   void _onCameraMove(CameraPosition position) {
//     _currentPosition = position.target;
//     // لا نجلب العنوان أثناء الحركة المستمرة لتجنب كثرة الطلبات
//     setState(() {
//       _address = AppLocalizations.of(context)!.determiningLocation;
//       _isAddressing = true;
//     });

//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 800), () {
//       if (_currentPosition != null) {
//         _getAddressFromLatLng(_currentPosition!);
//       }
//     });
//   }

//   /// ✅ تأكيد الاختيار
//   void _confirmLocation() {
//     if (_currentPosition != null) {
//       Navigator.pop(context, {'latLng': _currentPosition, 'address': _address});
//     }
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.qsColors;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // 🗺️ الخريطة
//           GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: _kDefaultLocation,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//             },
//             onCameraMove: _onCameraMove,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false, // سنضع زر مخصص
//             zoomControlsEnabled: false,
//           ),

//           // 📍 أيقونة التثبيت في المنتصف
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 bottom: 30,
//               ), // رفع الأيقونة قليلاً لتشير بدقة
//               child: Icon(Icons.location_on, size: 50, color: Colors.red),
//             ),
//           ),

//           // 🔙 زر الرجوع
//           Positioned(
//             top: 50,
//             right: 20,
//             child: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_forward, color: Colors.black),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),

//           // 🎯 زر الذهاب للموقع الحالي
//           Positioned(
//             bottom: 180, // فوق البطاقة السفلية
//             right: 20,
//             child: FloatingActionButton(
//               backgroundColor: Colors.white,
//               onPressed: _determinePosition,
//               child: const Icon(Icons.my_location, color: Colors.black),
//             ),
//           ),

//           // 📝 بطاقة العنوان وزر التأكيد
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(25),
//                   topRight: Radius.circular(25),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.selectedLocation,
//                     style: TextStyle(color: colors.textSub, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on_outlined, color: Colors.red),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _address,
//                           style: TextStyle(
//                             color: colors.text,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _isAddressing ? null : _confirmLocation,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF539DB9),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       AppLocalizations.of(context)!.confirmLocation,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ⏳ مؤشر تحميل أولي
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../../../../core/theme/qs_color_extension.dart';

/// 📂 اسم الملف: pick_location_view.dart
/// 📝 الوصف: شاشة اختيار الموقع من الخريطة بدقة عالية بنظام (الدبوس العائم).
class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  // ---------------------------------------------------------------------------
  // 📊 المتغيرات (State)
  // ---------------------------------------------------------------------------
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  String _address = '';
  bool _isLoading = true;
  bool _isAddressing = false;
  bool _isMoving = false; // 🚀 حالة الدبوس (يطفو أم مستقر)
  Timer? _debounce;
  bool _initialized = false;

  // موقع افتراضي (المكلا) في حال لم نتمكن من جلب الموقع الحالي فوراً
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(14.5425, 49.1242),
    zoom: 15, // تقريب ممتاز للشوارع
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _determinePosition();
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Logic)
  // ---------------------------------------------------------------------------

  /// 📍 تحديد الموقع الحالي (GPS) عند فتح الشاشة
  Future<void> _determinePosition() async {
    setState(() {
      _address = AppLocalizations.of(context)!.determiningAddress;
      _isAddressing = true;
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Denied');
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception('Denied forever');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // 🎥 تحريك الكاميرا للموقع الحالي بدقة
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
        _currentPosition = _kDefaultLocation.target; // استخدام الافتراضي لو فشل
      });
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  /// 🏠 جلب اسم الشارع من الإحداثيات باستخدام (Geocoding)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // تنظيف وتكوين العنوان بشكل أنيق
        String street = place.street ?? '';
        String locality = place.locality ?? '';
        String subAdminArea = place.subAdministrativeArea ?? '';

        setState(() {
          _address = '$street، $locality، $subAdminArea'
              .replaceAll(RegExp(r'^، |، $'), '')
              .trim();

          if (_address.isEmpty || _address == '،') {
            _address =
                'الإحداثيات: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          }
          _isAddressing = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        // في حال فشل جلب النص، نعرض الإحداثيات كبديل موثوق
        _address = 'موقع مخصص (${position.latitude.toStringAsFixed(4)})';
        _isAddressing = false;
      });
    }
  }

  /// 🎥 عند بدء تحريك الخريطة (يقفز الدبوس)
  void _onCameraMoveStarted() {
    setState(() {
      _isMoving = true;
      _address = "جاري تحديد الموقع بدقة...";
      _isAddressing = true;
    });
  }

  /// 🎥 أثناء السحب المستمر
  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  /// 🛑 عند توقف السحب (يستقر الدبوس ونجلب العنوان)
  void _onCameraIdle() {
    setState(() => _isMoving = false); // يعود الدبوس للأسفل

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_currentPosition != null) {
        _getAddressFromLatLng(_currentPosition!);
      }
    });
  }

  /// ✅ زر تأكيد الموقع
  void _confirmLocation() {
    if (_currentPosition != null) {
      // إرجاع الإحداثيات واسم الشارع للشاشة السابقة
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
          // 🗺️ 1. الخريطة تملأ الشاشة
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kDefaultLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMoveStarted: _onCameraMoveStarted, // 🚀 تفعيل القفز
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle, // 🚀 الاستقرار
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // مخفي لنضع زرنا المخصص
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),

          // 📍 2. الدبوس العائم (Floating Pin) في منتصف الشاشة تماماً
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 40,
              ), // يضبط سن الدبوس على المركز
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔴 الدبوس مع أنيميشن القفز
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(
                      0,
                      _isMoving ? -20 : 0,
                      0,
                    ), // يقفز للأعلى عند السحب
                    child: const Icon(
                      Icons.location_on,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                  ),

                  // 🌑 ظل الدبوس (يعطي عمقاً واحترافية)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _isMoving ? 0.2 : 0.6, // يصغر الظل عند القفز
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _isMoving ? 8 : 12,
                      height: _isMoving ? 4 : 6,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔙 3. زر الرجوع الأنيق
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 20,
                ), // سهم عربي
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 🎯 4. زر الذهاب لموقعي (GPS)
          Positioned(
            bottom: 180, // فوق البطاقة السفلية
            right: 20,
            child: FloatingActionButton(
              heroTag: 'myLocationBtn',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // 📝 5. بطاقة العنوان السفلية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
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
                    style: TextStyle(
                      color: colors.textSub,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // مسار العنوان
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
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
                        child: Text(
                          _address,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // زر التأكيد
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isAddressing ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF539DB9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isAddressing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.confirmLocation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ⏳ 6. مؤشر التحميل الأولي (يغطي الشاشة بخفة)
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'جاري البحث عن موقعك...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
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
