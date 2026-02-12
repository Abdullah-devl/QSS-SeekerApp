import 'package:connectivity_plus/connectivity_plus.dart';

/// 📂 ConnectivityService
/// 📝 مسؤول فقط عن معرفة هل يوجد إنترنت أم لا

/// 
/// فقط يرجع true أو false

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();

    return result != ConnectivityResult.none;
  }
}
