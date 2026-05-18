import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/l10n/app_localizations.dart';

/// 📂 اسم الملف: qs_alerts.dart
/// 📝 الوصف: أداة مركزية لإظهار التنبيهات والرسائل المخصصة في التطبيق.
/// تدعم التنبيهات (النجاح، الخطأ، التحذير، التأكيد) بتصميم فخم (Glassmorphism).

class QSAlerts {
  /// 🟢 إظهار تنبيه نجاح (Success)
  static Future<void> showSuccess(BuildContext context, String message) async {
    await _showCustomDialog(
      context,
      message: message,
      type: AlertType.success,
      icon: Icons.check_circle_rounded,
    );
  }

  /// 🔴 إظهار تنبيه خطأ (Error)
  static Future<void> showError(BuildContext context, String message) async {
    await _showCustomDialog(
      context,
      message: message,
      type: AlertType.error,
      icon: Icons.error_rounded,
    );
  }

  /// 🟡 إظهار تنبيه تحذير (Warning)
  static Future<void> showWarning(BuildContext context, String message) async {
    await _showCustomDialog(
      context,
      message: message,
      type: AlertType.warning,
      icon: Icons.warning_rounded,
    );
  }

  /// 🔵 إظهار تنبيه معلومة (Info)
  static Future<void> showInfo(BuildContext context, String message) async {
    await _showCustomDialog(
      context,
      message: message,
      type: AlertType.info,
      icon: Icons.info_rounded,
    );
  }

  /// 🤝 إظهار تنبيه تأكيد (Confirmation) مع زرين
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await _showCustomDialog<bool>(
      context,
      title: title,
      message: message,
      type: AlertType.confirm,
      icon: Icons.help_rounded,
    );
    return result ?? false;
  }

  /// 🛠️ الدالة الداخلية لبناء الديالوج المخصص
  static Future<T?> _showCustomDialog<T>(
    BuildContext context, {
    String? title,
    required String message,
    required AlertType type,
    required IconData icon,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final colors = context.qsColors;
    final tr = AppLocalizations.of(context)!;

    Color accentColor;
    String defaultTitle;

    switch (type) {
      case AlertType.success:
        accentColor = colors.success;
        defaultTitle = tr.requestSentSuccess; // أو مفتاح مناسب للنجاح
        break;
      case AlertType.error:
        accentColor = colors.error;
        defaultTitle = tr.alert;
        break;
      case AlertType.warning:
        accentColor = colors.warning;
        defaultTitle = tr.alert;
        break;
      case AlertType.confirm:
        accentColor = colors.primary;
        defaultTitle = title ?? tr.alert;
        break;
      case AlertType.info:
      default:
        accentColor = colors.info;
        defaultTitle = tr.alert;
        break;
    }

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: type != AlertType.confirm,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: accentColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🎨 الأيقونة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentColor, size: 40),
                      ),
                      const SizedBox(height: 20),
                      // 📝 العنوان
                      Text(
                        title ?? defaultTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 📄 الرسالة
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.textSub,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 🔘 الأزرار
                      Row(
                        children: [
                          if (type == AlertType.confirm) ...[
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                  if (onCancel != null) onCancel();
                                },
                                child: Text(
                                  tr.cancel_order,
                                  style: TextStyle(color: colors.textSub),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                                if (onConfirm != null) onConfirm();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                tr.ok,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  /// ⏳ إظهار ديالوج التحميل (Loading) بتصميم زجاجي فاخر
  static void showLoading(BuildContext context, {String? message}) {
    final colors = context.qsColors;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final defaultMessage = isAr ? 'جاري إرسال الطلب...' : 'Submitting request...';

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            content: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colors.background.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colors.primary),
                      const SizedBox(height: 24),
                      Text(
                        message ?? defaultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📥 إغلاق ديالوج التحميل
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// 🤝 إظهار تنبيه تأكيد إرسال طلب الانضمام كمزود خدمة
  static Future<bool> showConfirmJoinProvider(BuildContext context) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final title = isAr ? 'تأكيد إرسال الطلب' : 'Confirm Request Submission';
    final message = isAr
        ? 'هل أنت متأكد من رغبتك في إرسال طلب الانضمام كمزود خدمة؟ سيتم مراجعة طلبك من قبل الإدارة.'
        : 'Are you sure you want to submit your request to join as a service provider? Your details will be reviewed by the admin team.';

    return await showConfirm(context, title: title, message: message);
  }
}

enum AlertType { success, error, warning, info, confirm }
