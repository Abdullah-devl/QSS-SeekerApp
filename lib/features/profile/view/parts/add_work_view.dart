import 'package:flutter/material.dart';
import 'package:seeker/core/localization/app_localizations.dart';

class AddWorkView extends StatelessWidget {
  const AddWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('add_work_title'))),
      body: Center(child: Text(context.tr('add_work_desc'))),
    );
  }
}
