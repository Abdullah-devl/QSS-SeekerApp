import 'package:flutter/material.dart';

class EditWorkView extends StatelessWidget {
  const EditWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل العمل')),
      body: const Center(child: Text('شاشة تعديل بيانات عمل سابق')),
    );
  }
}
