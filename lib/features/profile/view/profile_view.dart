import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/features/profile/repositories/profile_repository.dart';
import 'package:seeker/features/profile/viewmodels/profile_view_model.dart';
import 'package:seeker/features/profile/viewmodels/parts/services_view_model.dart';
import 'package:seeker/features/profile/viewmodels/parts/contact_info_view_model.dart';
import 'package:seeker/features/profile/models/profile_model.dart';
import 'package:seeker/features/profile/view/parts/services_view.dart';
import 'package:seeker/features/profile/view/parts/contact_info_view.dart';
import '../provider_works/view/provider_works_view.dart';
import '../provider_works/viewmodel/provider_works_view_model.dart';
import '../requests/custom/view/custom_request_view.dart';
import '../requests/custom/viewmodel/custom_request_view_model.dart';
import '../requests/meeting/view/meeting_request_view.dart';
import '../requests/meeting/viewmodel/meeting_request_view_model.dart';
import '../requests/repository/request_repository.dart';

/// 📂 اسم الملف: profile_view.dart
/// 📝 الوصف: شاشة الملف الشخصي بتصميم عصري (Instagram-style).
/// تدعم التبويبات المتعددة، عرض الإحصائيات، وإدارة معرض الأعمال.
class ProfileView extends StatelessWidget {
  final int? userId; // إذا كان null، نعرض ملف المستخدم الحالي (أو نتركه للـ ViewModel)

  const ProfileView({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<ProfileViewModel>();
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context, vm, colors, bgColor),
      body: _buildBody(context, vm, colors, bgColor),
    );
  }

  Widget _buildBody(BuildContext context, ProfileViewModel vm, dynamic colors, Color bgColor) {
    if (vm.isLoading && vm.profile == null) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }
    
    if (vm.errorMessage != null && vm.profile == null) {
      return Center(child: Text(vm.errorMessage!, style: TextStyle(color: colors.error)));
    }

    if (vm.profile == null) {
      return const SizedBox();
    }

    final profile = vm.profile!;

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () => vm.fetchProfile(),
      child: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildProfileHeader(context, profile, colors),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, vm, colors),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  _buildTabBar(context, colors) as TabBar,
                  bgColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ChangeNotifierProvider(
                create: (context) => ProviderWorksViewModel(
                  ProfileRepository(context.read<ApiService>()),
                  userId: (profile.id != 0) ? profile.id : (userId ?? 0),
                  initialWorks: profile.previousWorks,
                ),
                child: const ProviderWorksView(),
              ),
              ServicesView(services: profile.mainServices),
              const Center(child: Text('التقييمات قريباً')),
              ChangeNotifierProvider(
                create: (context) => ContactInfoViewModel(ProfileRepository(context.read<ApiService>())),
                child: ContactInfoView(profile: profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ProfileViewModel vm, dynamic colors, Color bgColor) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            vm.profile?.name ?? '...',
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (vm.profile?.verificationProvider == true) ...[
            const SizedBox(width: 4),
            Icon(Icons.verified, color: colors.primary, size: 16),
          ],
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.more_vert, color: colors.primary),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.arrow_forward, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 3),
                  image: profile.avatarUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(profile.avatarUrl), fit: BoxFit.cover)
                      : const DecorationImage(image: AssetImage('assets/images/user_avatar.png'), fit: BoxFit.cover),
                ),
              ),
              _buildStatItem(context, '${profile.yearsExperience}+', AppLocalizations.of(context)!.yearsExperience(profile.yearsExperience).split(' ').last, colors),
              _buildStatItem(context, '${profile.ratingAvg}', 'التقييم', colors),
              _buildStatItem(context, '${profile.completedJobs}', 'عمل منجز', colors),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.text)),
                    if (profile.verificationProvider) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified, color: colors.primary, size: 22),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(profile.jobTitle, style: TextStyle(fontSize: 14, color: colors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.bio.isNotEmpty == true ? profile.bio : 'وصف فني محترف...',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 13, color: colors.textSub, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, dynamic colors) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.text)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colors.primary)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileViewModel vm, dynamic colors) {
    if (vm.profile == null) return const SizedBox.shrink();
    final profile = vm.profile!;

    // 🛡️ التحقق من صلاحيات العرض:

    // 2. لا تظهر أزرار الطلبات إذا كان هذا بروفايل المستخدم نفسه.
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<TokenStorage>().getUserData(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data?['id'];
        
        // إذا كان هذا بروفايلي (UserId متطابق)، لا تظهر الأزرار
        if (currentUserId == profile.id || userId == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => CustomRequestViewModel(
                            RequestRepository(context.read<ApiService>()),
                            providerId: profile.id,
                          ),
                          child: const CustomRequestView(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('طلب مخصص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => MeetingRequestViewModel(
                            RequestRepository(context.read<ApiService>()),
                            providerId: profile.id,
                          ),
                          child: const MeetingRequestView(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.text.withValues(alpha: 0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('طلب حضور', textAlign: TextAlign.center, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, dynamic colors) {
    return TabBar(
      labelColor: colors.primary,
      unselectedLabelColor: colors.textSub,
      indicatorColor: colors.primary,
      indicatorWeight: 3,
      tabs: [
        Tab(icon: const Icon(Icons.grid_view_rounded), text: AppLocalizations.of(context)!.previousWorks),
        const Tab(icon: Icon(Icons.build_rounded), text: 'الخدمات'),
        Tab(icon: const Icon(Icons.star_rate_rounded), text: AppLocalizations.of(context)!.customerReviews),
        Tab(icon: const Icon(Icons.contact_phone_rounded), text: AppLocalizations.of(context)!.contactInfo),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: backgroundColor, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
