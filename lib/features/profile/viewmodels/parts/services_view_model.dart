import 'package:flutter/material.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';

class ServicesViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ServicesViewModel(this._repository);
}
