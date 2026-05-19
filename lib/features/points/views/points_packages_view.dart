import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import '../models/points_package_model.dart';
import '../viewmodels/points_viewmodel.dart';
import 'submit_points_payment_view.dart';

class PointsPackagesView extends StatefulWidget {
  const PointsPackagesView({super.key});

  @override
  State<PointsPackagesView> createState() => _PointsPackagesViewState();
}

class _PointsPackagesViewState extends State<PointsPackagesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointsViewModel>().fetchAvailablePackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PointsViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('pointsPackages'),
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: () async => await vm.fetchAvailablePackages(),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.errorMessage != null
                ? _buildErrorWidget(context, vm.errorMessage!)
                : vm.packages.isEmpty
                    ? _buildEmptyWidget(context, colors)
                    : _buildPackagesGrid(context, vm.packages, colors),
      ),
    );
  }

  Widget _buildPackagesGrid(BuildContext context, List<PointsPackageModel> packages, dynamic colors) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return _buildPointCard(context, packages[index], colors);
      },
    );
  }

  Widget _buildPointCard(BuildContext context, PointsPackageModel package, dynamic colors) {
    final bool hasBonus = package.bonusPoints > 0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.text.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Icon(Icons.stars_rounded, color: colors.primary, size: 40),
              const SizedBox(height: 12),
              Text(
                package.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${package.points} ${context.tr('points')}',
                style: TextStyle(fontSize: 13, color: colors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '${package.price.toInt()} ${context.tr('currency_sar')}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => SubmitPointsPaymentView(package: package),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    context.tr('buyNow'),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasBonus)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.warning,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.warning.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '+${package.bonusPoints} ${context.tr('gift')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final colors = context.qsColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 48),
          const SizedBox(height: 16),
          Text(context.tr('errorLoadingPackages')),
          TextButton(
            onPressed: () => context.read<PointsViewModel>().fetchAvailablePackages(),
            child: Text(context.tr('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, dynamic colors) {
    return Center(
      child: Text(context.tr('noPackagesAvailable')),
    );
  }
}
