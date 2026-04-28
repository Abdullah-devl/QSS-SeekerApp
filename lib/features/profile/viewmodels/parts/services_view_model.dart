import 'package:flutter/material.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';

import 'package:seeker/features/home/services/models/service_model.dart';

class ServicesViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final List<ServiceModel> services;

  ServicesViewModel(this._repository, {this.services = const []});
}
