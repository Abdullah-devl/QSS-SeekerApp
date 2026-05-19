import 'package:flutter/material.dart';
import 'package:seeker/core/localization/app_localizations.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('edit_profile_placeholder'))),
      body: Center(child: Text(context.tr('edit_profile_desc'))),
    );
  }
}
