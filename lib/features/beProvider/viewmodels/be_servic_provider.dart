import 'package:flutter/material.dart';

class BeServicProvider extends StatelessWidget {
  const BeServicProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [TextFormField()]),
      ),
    );
  }
}

class TextInPut {}
