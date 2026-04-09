import 'package:flutter/material.dart';
import 'package:seeker/features/profile/models/work_model.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';

class EditWorkViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final WorkModel work;

  EditWorkViewModel(this._repository, this.work);
}
