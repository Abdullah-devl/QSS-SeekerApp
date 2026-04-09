import 'package:flutter/material.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';

class AddWorkViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  AddWorkViewModel(this._repository);
}
