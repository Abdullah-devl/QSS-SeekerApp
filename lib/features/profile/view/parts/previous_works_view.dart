import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';

import '../../models/profile_model.dart';
import '../../viewmodels/parts/previous_works_view_model.dart';

class PreviousWorksView extends StatelessWidget {
  final ProfileModel profile;

  const PreviousWorksView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final vm = context.watch<PreviousWorksViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n?.previousWorks ?? 'الأعمال السابقة',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: colors.textSub),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: colors.text),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: vm.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.primary),
            )
          : vm.errorMessage != null
          ? Center(
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : vm.works.isEmpty
          ? const Center(child: Text('لا توجد أعمال سابقة'))
          : RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.card,
              onRefresh: vm.fetchWorks,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: vm.works.length,
                itemBuilder: (context, index) {
                  final work = vm.works[index];
                  return _buildWorkCard(context, work);
                },
              ),
            ),
    );
  }

  Widget _buildWorkCard(BuildContext context, dynamic work) {
    final colors = context.qsColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header: Avatar & Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.jobTitle} • الرياض',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: profile.avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(
                              'assets/images/default_avatar.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Work Image
          if (work.imageUrl.isNotEmpty)
            Image.network(
              work.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),

          // Actions Space
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.bookmark, color: colors.primary),
                Row(
                  children: [
                    Icon(Icons.send, color: colors.textSub),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble, color: colors.textSub),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite, color: colors.primary),
                  ],
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  work.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  work.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSub,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          // Tags
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTag('#الرياض', colors),
                const SizedBox(width: 8),
                _buildTag('#صيانة', colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: colors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
