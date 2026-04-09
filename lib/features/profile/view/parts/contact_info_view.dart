import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

class ContactInfoView extends StatelessWidget {
  final ProfileModel profile;
  const ContactInfoView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('بيانات التواصل والحسابات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          const Divider(),
          const Text('الحسابات البنكية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ...profile.banks.map((bank) => ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(bank.bankName),
            subtitle: Text(bank.iban),
          )),
        ],
      ),
    );
  }
}
