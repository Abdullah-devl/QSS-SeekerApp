import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// 📂 اسم الملف: app_localizations.dart (extension)
/// 📝 الوصف: يوفر وصولاً سريعاً للمفاتيح المترجمة باستخدام context.tr
extension LocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String tr(String key, {Map<String, dynamic>? args}) {
    final l = l10n;
    switch (key) {
      case 'myOrders': return l.myOrders;
      case 'incoming_orders': return l.incoming_orders;
      case 'order_details': return l.order_details;
      case 'order_sent': return l.order_sent;
      case 'all': return l.all;
      case 'new_order': return l.new_order;
      case 'in_progress': return l.in_progress;
      case 'completed': return l.completed;
      case 'rejected_orders': return l.rejected_orders;
      case 'error_loading_orders': return l.error_loading_orders;
      case 'retry': return l.retry;
      case 'no_orders_yet': return l.no_orders_yet;
      case 'total_price_label': return l.total_price_label;
      case 'currency_sar': return l.currency_sar;
      case 'details': return l.details;
      case 'cancel_order': return l.cancel_order;
      case 'accepted_initial': return l.accepted_initial;
      case 'status_pending': return l.status_pending;
      case 'order_bonds': return l.order_bonds;
      case 'paid_amount': return l.paid_amount;
      case 'remaining_amount': return l.remaining_amount;
      case 'loading': return l.loading;
      case 'send_amount': return l.send_amount;
      case 'accept_first': return l.accept_first;
      case 'description_label': return l.description_label;
      case 'service_details_title': return l.service_details_title;
      case 'location_label': return l.location_label;
      case 'total_order_price': return l.total_order_price;
      case 'order_accepted_success': return l.order_accepted_success;
      case 'accept_order': return l.accept_order;
      case 'distance_away': 
        return l.distance_away(args?['distance'] ?? '');
      default:
        // إذا كان المفتاح غير موجود، نحاول استرجاع القيمة من AppLocalizations بشكل انعكاسي غير متوفر هنا
        // لذا سنعيد المفتاح نفسه كقيمة افتراضية
        return key;
    }
  }
}
