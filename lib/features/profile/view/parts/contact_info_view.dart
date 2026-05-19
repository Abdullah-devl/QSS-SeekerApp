import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker/core/localization/app_localizations.dart';
import 'package:seeker/l10n/app_localizations.dart';
import 'package:seeker/core/utils/qs_alerts.dart'; // ✅ تمت الإضافة
import 'dart:developer' as developer;
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/profile_model.dart';

class ContactInfoView extends StatelessWidget {
  final ProfileModel profile;
  const ContactInfoView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            AppLocalizations.of(context)!.contactInfo,
            Icons.contact_phone_rounded,
            colors,
          ),
          const SizedBox(height: 16),

          if (profile.phones.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(context.tr('noContactPhonesRegistered')),
              ),
            )
          else
            ...profile.phones.map(
              (phone) => _buildPhoneCard(context, phone, colors),
            ),

          const Divider(height: 40),

          _buildSectionHeader(
            AppLocalizations.of(context)!.bankAccounts,
            Icons.account_balance_rounded,
            colors,
          ),
          const SizedBox(height: 16),

          if (profile.banks.isEmpty)
            Center(child: Text(AppLocalizations.of(context)!.noBankAccounts))
          else
            ...profile.banks.map(
              (bank) => _buildBankCard(context, bank, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard(BuildContext context, dynamic phone, dynamic colors) {
    // 🌍 تجهيز الرقم الكامل (كود الدولة + الرقم) لضمان نجاح الاتصال والواتساب
    final String countryCode = phone.countryCode ?? '';
    final String localPhone = phone.phone ?? '';
    // الرقم الكامل المختصر (بدون مسافات) للروابط والنسخ
    final String completePhone = '$countryCode$localPhone'.replaceAll(' ', '');
    // الرقم للتنسيق الجمالي في العرض
    final String displayPhone = '$countryCode $localPhone';

    // تحديد الأيقونة واللون بناءً على النوع
    final bool isWhatsApp = phone.type == 'whatsapp' || phone.type == 'both';
    final bool isCall =
        phone.type == 'phone' || phone.type == 'both' || phone.type == 'mobile';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.text.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isWhatsApp
                  ? colors.success.withValues(alpha: 0.1)
                  : colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWhatsApp
                  ? Icons.message_rounded
                  : Icons.phone_forwarded_rounded,
              color: isWhatsApp ? colors.success : colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayPhone,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // تم تكبير الخط قليلاً للوضوح
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: colors.textSub,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          _copyToClipboard(context, completePhone, colors),
                    ),
                  ],
                ),
                Text(
                  phone.type == 'whatsapp'
                      ? context.tr('whatsappOnly')
                      : (phone.type == 'phone'
                            ? context.tr('callOnly')
                            : context.tr('callAndWhatsapp')),
                  style: TextStyle(color: colors.textSub, fontSize: 12),
                ),
              ],
            ),
          ),
          // أزرار سريعة للاتصال
          Row(
            children: [
              if (isWhatsApp)
                _buildCompactActionButton(
                  icon: Icons.message_rounded,
                  color: colors.success,
                  onTap: () => _launchURL('https://wa.me/$completePhone'),
                ),
              if (isCall)
                _buildCompactActionButton(
                  icon: Icons.call_rounded,
                  color: colors.primary,
                  onTap: () => _launchURL('tel:$completePhone'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 22),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, dynamic colors) {
    Clipboard.setData(ClipboardData(text: text));
    QSAlerts.showSuccess(context, context.tr('numberCopiedSuccess'));
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        developer.log(
          '🔗 [ContactInfoView] Could not launch: $url',
          name: 'ContactInfoView',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [ContactInfoView] Error launching URL: $e',
        name: 'ContactInfoView',
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, dynamic colors) {
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(BuildContext context, dynamic bank, dynamic colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.text.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.text.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.bankName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bank.accountName.isNotEmpty
                      ? bank.accountName
                      : context.tr('accountOwnerNotRegistered'),
                  style: TextStyle(color: colors.textSub, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.text.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          bank.iban,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: bank.iban));
                          QSAlerts.showSuccess(
                            context,
                            context.tr('ibanCopiedSuccess'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
