import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/profile/view/parts/profile_service_card.dart';
import 'package:seeker/features/home/services/models/service_model.dart';
import 'package:seeker/features/profile/viewmodels/parts/services_view_model.dart';
import 'package:seeker/features/home/services/view/service_details_view.dart';
import 'package:seeker/features/home/services/viewmodels/service_details_view_model.dart';
import 'package:seeker/features/home/repositories/home_repository.dart';

class ServicesView extends StatelessWidget {
  final List<ServiceModel> services;
  const ServicesView({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.miscellaneous_services_rounded,
              size: 60,
              color: colors.textSub.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('noServicesAvailable'),
              style: TextStyle(color: colors.textSub, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ProfileServiceCard(
          service: service,
          onTap: () {
            // الانتقال لتفاصيل الخدمة
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (context) =>
                      ServiceDetailsViewModel(context.read<HomeRepository>()),
                  child: ServiceDetailsView(initialService: service),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
