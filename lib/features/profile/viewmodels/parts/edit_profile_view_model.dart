import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/profile/models/profile_model.dart';
import 'package:seeker/features/profile/models/phone_model.dart'; // ✅ تمت الإضافة
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import 'dart:developer' as developer;

class PhoneEntry {
  final int? id;
  final TextEditingController controller;
  String originalValue;

  PhoneEntry({this.id, required this.controller, this.originalValue = ''});
}

class EditProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final ProfileModel profile;

  EditProfileViewModel(this._repository, this.profile) {
    nameController.text = profile.name;
    bioController.text = profile.bio;
    
    // تهيئة هواتف المستخدم مع حفظ الـ IDs
    for (var phone in profile.phones) {
      _phoneEntries.add(PhoneEntry(
        id: phone.id,
        controller: TextEditingController(text: phone.phone),
        originalValue: phone.phone,
      ));
    }
    
    if (_phoneEntries.isEmpty) {
      addPhoneField();
    }

    // محاولة جلب العنوان النصي عند البداية إذا وجد إحداثيات
    if (profile.latitude != null && profile.longitude != null) {
      _getAddressFromCoords(profile.latitude!, profile.longitude!);
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  
  final List<PhoneEntry> _phoneEntries = [];
  List<PhoneEntry> get phoneEntries => _phoneEntries;
  
  final List<int> _deletedPhoneIds = [];

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude ?? profile.latitude;
  double? get longitude => _longitude ?? profile.longitude;

  String? _address; // العنوان النصي
  String? get address => _address;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  void addPhoneField() {
    _phoneEntries.add(PhoneEntry(controller: TextEditingController()));
    notifyListeners();
  }

  void removePhoneField(int index) {
    final entry = _phoneEntries[index];
    if (entry.id != null) {
      _deletedPhoneIds.add(entry.id!);
    }
    entry.controller.dispose();
    _phoneEntries.removeAt(index);
    notifyListeners();
  }

  Future<void> updateLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      
      // جلب العنوان النصي
      await _getAddressFromCoords(_latitude!, _longitude!);
      
      developer.log('📍 New Location & Address: $_latitude, $_longitude, $_address');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _address = "${place.street != null && place.street!.isNotEmpty ? place.street : ''} ${place.locality}, ${place.country}";
        _address = _address!.trim();
      }
    } catch (e) {
      developer.log('⚠️ Geocoding Error: $e');
      _address = "خط العرض: $lat, خط الطول: $lng";
    }
  }

  Future<bool> saveChanges() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحديث الملف الشخصي الأساسي
      await _repository.updateProfile(
        profileId: profile.id,
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        avatarPath: _selectedImage?.path,
        latitude: _latitude,
        longitude: _longitude,
      );

      // 2. معالجة هواتف الجوال (إضافة، تحديث، حذف)
      
      // أ) حذف الأرقام المحذوفة
      for (var id in _deletedPhoneIds) {
        await _repository.deletePhone(id);
      }

      // ب) إضافة أو تحديث الأرقام الحالية
      for (var entry in _phoneEntries) {
        final phoneText = entry.controller.text.trim();
        if (phoneText.isEmpty) continue;

        if (entry.id == null) {
          // رقم جديد
          await _repository.addPhone(phone: phoneText);
        } else if (phoneText != entry.originalValue) {
          // رقم تم تعديله
          await _repository.updatePhone(phoneId: entry.id!, phone: phoneText);
        }
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      developer.log('❌ EditProfileViewModel Save Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    for (var entry in _phoneEntries) {
      entry.controller.dispose();
    }
    super.dispose();
  }
}
