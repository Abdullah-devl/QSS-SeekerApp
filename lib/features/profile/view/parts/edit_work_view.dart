import 'package:flutter/material.dart';
import 'package:seeker/core/localization/app_localizations.dart';

class EditWorkView extends StatelessWidget {
  const EditWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('edit_work_title'))),
      body: Center(child: Text(context.tr('edit_work_desc'))),
    );
  }
}
