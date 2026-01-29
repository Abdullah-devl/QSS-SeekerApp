import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/settings/viewmodels/settings_view_model.dart';
import 'package:seeker/core/theme/qs_colors.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: profile_view.dart
/// 📝 الوصف: شاشة لعرض الملف الشخصي (Profile Page).
/// تعرض صورة المستخدم، اسمه، ومعلومات التواصل (البريد، الهاتف، العنوان).
/// كما تحتوي على بطاقة دعوة للانضمام كمزود خدمة.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 الوصول للألوان من خلال الامتداد qsColors
    final colors = context.qsColors;

    return Scaffold(
      backgroundColor: colors.background, // لون الخلفية
      // 🏷️ الشريط العلوي (AppBar)
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileTitle,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // خلفية شفافة
        elevation: 0, // بدون ظل
        leading: BackButton(color: colors.primary), // زر العودة
        actions: [
          // 🌗 أيقونة لتغيير الثيم (اختياري كما في التصميم قد يكون هناك أيقونات أخرى)
          Icon(Icons.nightlight_round, color: colors.primary),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===================================
            // 1️⃣ قسم الصورة والاسم
            // ===================================
            _buildProfileHeader(context, colors),

            const SizedBox(height: 24),

            // ===================================
            // 2️⃣ بطاقة معلومات الحساب
            // ===================================
            _buildInfoCard(context, colors),

            const SizedBox(height: 24),

            // ===================================
            // 3️⃣ بطاقة الانضمام للفريق
            // ===================================
            _buildJoinTeamCard(context, colors),
          ],
        ),
      ),
    );
  }

  /// 👤 بناء رأس الصفحة (الصورة + الاسم)
  Widget _buildProfileHeader(BuildContext context, QSColors colors) {
    // نستخدم Selector للاستماع لتغييرات الاسم فقط
    return Selector<SettingsViewModel, String>(
      selector: (_, vm) => vm.userName,
      builder: (context, userName, _) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // 🖼️ صورة المستخدم
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    // صورة افتراضية أو يمكن استبدالها بصورة من الشبكة
                    child: Image.asset(
                      'assets/images/user_avatar.png', // تأكد من وجود صورة افتراضية
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.person, size: 60, color: colors.textSub),
                    ),
                  ),
                ),
                // 📷 أيقونة الكاميرا (للتعديل)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF448AFF), // لون أزرق كما في التصميم
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ✏️ اسم المستخدم
            Text(
              userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 4),
            // 📄 نص توضيحي
            Text(
              AppLocalizations.of(context)!.profileSubtitle,
              style: TextStyle(
                color: colors.primary, // اللون الأزرق
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📝 بناء بطاقة المعلومات (الاسم، البريد، الجوال، العنوان)
  //                         Widget _buildInfoCard(BuildContext context, QSColors colors) {
  //   // نستخدم Consumer لنحصل على كل البيانات دفعة واحدة (أبسط للقراءة هنا)
  //   return Consumer<SettingsViewModel>(
  //     builder: (context, vm, _) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).cardColor,
  //           borderRadius: BorderRadius.circular(20),
  //           boxShadow: [
  //             BoxShadow(
  //               color: colors.text.withValues(alpha: 0.05),
  //               blurRadius: 15,
  //               offset: const Offset(0, 5),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           children: [
  //             // 🏷️ عنوان البطاقة وزر التعديل
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                   Text(
  //                     AppLocalizations.of(context)!.accountInfo,
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: colors.text,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               TextButton.icon(
  //                 onPressed: () {
  //                   // TODO: فتح صفحة تعديل البيانات
  //                 },
  //                 icon: const Icon(Icons.edit, size: 16),
  //                 label: Text(AppLocalizations.of(context)!.edit),
  //                 style: TextButton.styleFrom(
  //                   foregroundColor: const Color(0xFF448AFF),
  //                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               ],
  //             ),
  //             const Divider(height: 24),
  //             // 📋 الحقول
  //             _buildInfoField(
  //               AppLocalizations.of(context)!.fullName,
  //               vm.userName,
  //               Icons.person,
  //               colors,
  //             ),
  //             const SizedBox(height: 16),
  //             _buildInfoField(
  //               AppLocalizations.of(context)!.email,
  //               vm.userEmail,
  //               Icons.email,
  //               colors,
  //             ),
  //             const SizedBox(height: 16),
  //             _buildInfoField(
  //               AppLocalizations.of(context)!.phoneNumber,
  //               vm.userPhone.isEmpty ? AppLocalizations.of(context)!.notSpecified : vm.userPhone,
  //               Icons.phone,
  //               colors,
  //             ),
  //             const SizedBox(height: 16),
  //             _buildInfoField(
  //               AppLocalizations.of(context)!.address,
  //               vm.userAddress.isEmpty ? AppLocalizations.of(context)!.notSpecified : vm.userAddress,
  //               Icons.location_on,
  //               colors,
  //              ),
  //         ],
  //       ),
  //     );
  //   },
  // );
  Widget _buildInfoCard(BuildContext context, QSColors colors) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.text.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🏷️ عنوان البطاقة + زر التعديل
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.accountInfo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: فتح صفحة تعديل البيانات
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(AppLocalizations.of(context)!.edit),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF448AFF),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // 📋 الحقول
              _buildInfoField(
                AppLocalizations.of(context)!.fullName,
                vm.userName,
                Icons.person,
                colors,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                AppLocalizations.of(context)!.email,
                vm.userEmail,
                Icons.email,
                colors,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                AppLocalizations.of(context)!.phoneNumber,
                vm.userPhone.isEmpty
                    ? AppLocalizations.of(context)!.notSpecified
                    : vm.userPhone,
                Icons.phone,
                colors,
              ),
              const SizedBox(height: 16),
              _buildInfoField(
                AppLocalizations.of(context)!.address,
                vm.userAddress.isEmpty
                    ? AppLocalizations.of(context)!.notSpecified
                    : vm.userAddress,
                Icons.location_on,
                colors,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 🧩 ويدجت لبناء حقل واحد للمعلومات
Widget _buildInfoField(
  String label,
  String value,
  IconData icon,
  QSColors colors,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: colors.textSub,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.background, // لون خلفية الحقل
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: colors.textSub, size: 20),
          ],
        ),
      ),
    ],
  );
}

/// 🤝 بناء بطاقة "كن جزءاً من فريقنا"
Widget _buildJoinTeamCard(BuildContext context, QSColors colors) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    // إطار منقط
    decoration: BoxDecoration(
      color: const Color(0xFFE3F2FD), // خلفية زرقاء فاتحة جداً
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF90CAF9),
        style: BorderStyle
            .solid, // يمكن استخدام حزمة dotted_border للحصول على حدود منقطة
        width: 1.5,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.joinOurTeam,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.joinTeamDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // أيقونة مميزة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Color(0xFF1976D2),
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // زر الإرسال
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.beProvider);
            },
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.sendProviderRequest,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF448AFF), // لون الزر الأزرق
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );
}
