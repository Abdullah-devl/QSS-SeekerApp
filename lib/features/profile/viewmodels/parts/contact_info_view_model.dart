import 'package:flutter/material.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import 'package:seeker/features/profile/models/profile_model.dart';

class ContactInfoViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final ProfileModel? profile;

  ContactInfoViewModel(this._repository, {this.profile});
}
