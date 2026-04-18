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
      case 'currently_paid_percent': return l.currently_paid_percent;
      case 'order_cancelled_msg': return l.order_cancelled_msg;
      case 'order_rejected_msg': return l.order_rejected_msg;
      case 'pay_service_costs': return l.pay_service_costs;
      case 'enter_correct_amount': return l.enter_correct_amount;
      case 'amount_updated_success': return l.amount_updated_success;
      case 'provider_bank_accounts_label': return l.provider_bank_accounts_label;
      case 'copySuccess': return l.copySuccess;
      case 'confirm_completion_title': return l.confirm_completion_title;
      case 'confirm_completion_message': return l.confirm_completion_message;
      case 'rate_service_title': return l.rate_service_title;
      case 'rate_service_message': return l.rate_service_message;
      case 'rating_label': return l.rating_label;
      case 'comment_label': return l.comment_label;
      case 'comment_hint': return l.comment_hint;
      case 'submit_review': return l.submit_review;
      case 'review_submitted_success': return l.review_submitted_success;
      case 'review_submitted_error': return l.review_submitted_error;
      case 'order_completed_success': return l.order_completed_success;
      case 'viewAll': return l.viewAll;
      case 'send_complaint': return l.send_complaint;
      case 'payment_page_title': return l.payment_page_title;
      case 'service_price': return l.service_price;
      case 'available_points': return l.available_points;
      case 'points': return l.points;
      case 'payment_confirm': return l.payment_confirm;
      case 'pay_by_points': return l.pay_by_points;
      case 'pay_by_bond': return l.pay_by_bond;
      case 'confirm_points_payment_msg': return l.confirm_points_payment_msg;
      case 'amount_to_pay': return l.amount_to_pay;
      case 'upload_receipt': return l.upload_receipt;
      case 'no_points_balance': return l.no_points_balance;
      case 'confirm_points_payment': return l.confirm_points_payment;
      case 'points_payment_success': return l.points_payment_success;
      case 'points_payment_error': return l.points_payment_error;
      case 'bond_payment_success': return l.bond_payment_success;
      case 'bond_payment_error': return l.bond_payment_error;
      case 'seeker_role': return l.seeker_role;
      case 'provider_role': return l.provider_role;
      case 'no_phones_added': return l.no_phones_added;
      case 'fetching_address': return l.fetching_address;
      case 'location_not_set': return l.location_not_set;
      case 'edit_profile_title': return l.edit_profile_title;
      case 'bio_label': return l.bio_label;
      case 'geo_location': return l.geo_location;
      case 'update_label': return l.update_label;
      case 'enter_phone_number': return l.enter_phone_number;
      case 'profile_updated_success': return l.profile_updated_success;
      case 'save_changes': return l.save_changes;
      case 'no_max_limit': return l.no_max_limit;
      case 'closed': return l.closed;
      case 'example_address_city': return l.example_address_city;
      case 'example_address_street': return l.example_address_street;
      case 'example_reviewer_name': return l.example_reviewer_name;
      case 'example_review_time': return l.example_review_time;
      case 'example_review_content': return l.example_review_content;
      case 'share_service_message':
        return l.share_service_message(
          args?['title'] ?? '',
          args?['provider'] ?? '',
          args?['price'] ?? '',
        );
      case 'confirm_customize_order': return l.confirm_customize_order;
      case 'new_service_label': return l.new_service_label;
      case 'request_details_title': return l.request_details_title;
      case 'receiver_name': return l.receiver_name;
      case 'service_location_title': return l.service_location_title;
      case 'click_to_pick_location': return l.click_to_pick_location;
      case 'additional_services': return l.additional_services;
      case 'additional_notes': return l.additional_notes;
      case 'notes_hint': return l.notes_hint;
      case 'final_total': return l.final_total;
      case 'order_sent_success': return l.order_sent_success;
      case 'order_sent_error': return l.order_sent_error;
      case 'confirm_and_book': return l.confirm_and_book;
      case 'loading_policy': return l.loading_policy;
      case 'no_policy_available': return l.no_policy_available;
      case 'last_update': return l.last_update;
      case 'guest': return l.guest;
      case 'terms_of_service': return l.terms_of_service;
      case 'read_terms_desc': return l.read_terms_desc;
      case 'terms_intro_title': return l.terms_intro_title;
      case 'terms_intro_text': return l.terms_intro_text;
      case 'terms_quality_title': return l.terms_quality_title;
      case 'terms_quality_text': return l.terms_quality_text;
      case 'terms_pricing_title': return l.terms_pricing_title;
      case 'terms_pricing_text': return l.terms_pricing_text;
      case 'terms_cancellation_title': return l.terms_cancellation_title;
      case 'terms_cancellation_text': return l.terms_cancellation_text;
      case 'agree_to_terms_prefix': return l.agree_to_terms_prefix;
      case 'and_label': return l.and_label;
      case 'agree_and_continue': return l.agree_and_continue;
      case 'activation_code_sent':
        return l.activation_code_sent(args?['email'] ?? '');
      case 'error_email_missing': return l.error_email_missing;
      case 'did_not_receive_code': return l.did_not_receive_code;
      case 'resend_code': return l.resend_code;
      case 'resend_code_timer':
        return l.resend_code_timer(args?['timer'] ?? '0');
      case 'required_partial_percentage_label':
        return l.required_partial_percentage_label(args?['percentage'] ?? '0');
      case 'distance_away': 
        return l.distance_away(args?['distance'] ?? '');
      default:
        // إذا كان المفتاح غير موجود، نحاول استرجاع القيمة من AppLocalizations بشكل انعكاسي غير متوفر هنا
        // لذا سنعيد المفتاح نفسه كقيمة افتراضية
        return key;
    }
  }
}
