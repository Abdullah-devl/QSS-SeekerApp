import 'package:flutter/material.dart';

class AddWorkView extends StatelessWidget {
  const AddWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عمل سابق')),
      body: const Center(child: Text('هنا يمكنك إضافة أعمالك السابقة للمعرض')),
    );
  }
}
