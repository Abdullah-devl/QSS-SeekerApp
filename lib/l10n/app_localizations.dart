import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Seeker App'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Seeker'**
  String get welcomeTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @beProvider.
  ///
  /// In en, this message translates to:
  /// **'Be a Provider'**
  String get beProvider;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Location on Map'**
  String get pickLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your daily services, faster and easier.\nWe connect you with trusted professionals in moments.'**
  String get welcomeDescription;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to the Terms of Service and Privacy Policy'**
  String get termsAndConditions;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue in QuickServe'**
  String get loginToContinue;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @loginAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Login as Guest'**
  String get loginAsGuest;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register now in QuickServe and start using our premium services'**
  String get registerSubtitle;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to '**
  String get agreeTo;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions & Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @orRegisterWith.
  ///
  /// In en, this message translates to:
  /// **'Or register with'**
  String get orRegisterWith;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'... Search for plumber, electrician, cleaning'**
  String get searchHint;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @cleaningDiscount.
  ///
  /// In en, this message translates to:
  /// **'30% OFF on Cleaning'**
  String get cleaningDiscount;

  /// No description provided for @getShinier.
  ///
  /// In en, this message translates to:
  /// **'Get your home shiny at irresistible prices'**
  String get getShinier;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @recommendedServices.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedServices;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'/ Hour'**
  String get perHour;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, '**
  String get welcome;

  /// No description provided for @lookingForService.
  ///
  /// In en, this message translates to:
  /// **'What service are you looking for today?'**
  String get lookingForService;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, '**
  String get hello;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @beProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Want to offer your services and earn with us? Join us and be a provider.'**
  String get beProviderDesc;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @trustedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Trusted Customer'**
  String get trustedCustomer;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome Guest'**
  String get welcomeGuest;

  /// No description provided for @guestLoginDesc.
  ///
  /// In en, this message translates to:
  /// **'Log in to enjoy all the features'**
  String get guestLoginDesc;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Seize the opportunity and be one of the application users. Do not hesitate, order your service now. You will not find such accuracy, perfection, safety and security.'**
  String get settingsFooter;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'User Personal Data'**
  String get profileSubtitle;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @joinOurTeam.
  ///
  /// In en, this message translates to:
  /// **'Join Our Team'**
  String get joinOurTeam;

  /// No description provided for @joinTeamDesc.
  ///
  /// In en, this message translates to:
  /// **'Join as a service provider in QuickServe application and start offering your services to thousands of customers.'**
  String get joinTeamDesc;

  /// No description provided for @sendProviderRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Provider Request'**
  String get sendProviderRequest;

  /// No description provided for @beProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Join as Service Provider'**
  String get beProviderTitle;

  /// No description provided for @idCardOrPassport.
  ///
  /// In en, this message translates to:
  /// **'ID Card or Passport Image'**
  String get idCardOrPassport;

  /// No description provided for @uploadIdCard.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Card'**
  String get uploadIdCard;

  /// No description provided for @imageSizeHint.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 5 MB'**
  String get imageSizeHint;

  /// No description provided for @requestDescription.
  ///
  /// In en, this message translates to:
  /// **'Request Description'**
  String get requestDescription;

  /// No description provided for @requestDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a brief about your experience and services you will provide...'**
  String get requestDescriptionHint;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service Location'**
  String get serviceLocation;

  /// No description provided for @pickLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick Location on Map'**
  String get pickLocationOnMap;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get requestSentSuccess;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @determiningAddress.
  ///
  /// In en, this message translates to:
  /// **'Determining address...'**
  String get determiningAddress;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @unableToDetermineAddress.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine address'**
  String get unableToDetermineAddress;

  /// No description provided for @determiningLocation.
  ///
  /// In en, this message translates to:
  /// **'Determining location...'**
  String get determiningLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Information'**
  String get serviceDetails;

  /// No description provided for @providerProfile.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get providerProfile;

  /// No description provided for @aboutProvider.
  ///
  /// In en, this message translates to:
  /// **'About Provider'**
  String get aboutProvider;

  /// No description provided for @previousWorks.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get previousWorks;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @serviceFeatures.
  ///
  /// In en, this message translates to:
  /// **'Service Features'**
  String get serviceFeatures;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Service Hours'**
  String get workingHours;

  /// No description provided for @bankAccounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bankAccounts;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @estimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get estimated;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get availableNow;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newService;

  /// No description provided for @perService.
  ///
  /// In en, this message translates to:
  /// **'Per Service'**
  String get perService;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'{count} years experience'**
  String yearsExperience(Object count);

  /// No description provided for @chatNow.
  ///
  /// In en, this message translates to:
  /// **'Chat Now'**
  String get chatNow;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Account number copied successfully! ✅'**
  String get copySuccess;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @visitProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get visitProfile;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callNow;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyNumber;

  /// No description provided for @noWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'No working hours have been set for this service yet.'**
  String get noWorkingHours;

  /// No description provided for @noBankAccounts.
  ///
  /// In en, this message translates to:
  /// **'No bank accounts are currently added for this provider.'**
  String get noBankAccounts;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact numbers are currently available to request service.'**
  String get noContactInfo;

  /// No description provided for @noPreviousWorks.
  ///
  /// In en, this message translates to:
  /// **'No previous works have been added yet.'**
  String get noPreviousWorks;

  /// No description provided for @incoming_orders.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get incoming_orders;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @order_sent.
  ///
  /// In en, this message translates to:
  /// **'Order Sent'**
  String get order_sent;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @new_order.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_order;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get in_progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @rejected_orders.
  ///
  /// In en, this message translates to:
  /// **'Rejected/Canceled'**
  String get rejected_orders;

  /// No description provided for @error_loading_orders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get error_loading_orders;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @no_orders_yet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get no_orders_yet;

  /// No description provided for @total_price_label.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get total_price_label;

  /// No description provided for @currency_sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currency_sar;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @cancel_order.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancel_order;

  /// No description provided for @accepted_initial.
  ///
  /// In en, this message translates to:
  /// **'Accepted (Initial)'**
  String get accepted_initial;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @order_bonds.
  ///
  /// In en, this message translates to:
  /// **'Order Bonds'**
  String get order_bonds;

  /// No description provided for @paid_amount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paid_amount;

  /// No description provided for @remaining_amount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remaining_amount;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @send_amount.
  ///
  /// In en, this message translates to:
  /// **'Send Amount'**
  String get send_amount;

  /// No description provided for @accept_first.
  ///
  /// In en, this message translates to:
  /// **'Accept Order First'**
  String get accept_first;

  /// No description provided for @description_label.
  ///
  /// In en, this message translates to:
  /// **'Request Description'**
  String get description_label;

  /// No description provided for @service_details_title.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get service_details_title;

  /// No description provided for @location_label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location_label;

  /// No description provided for @distance_away.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distance_away(Object distance);

  /// No description provided for @total_order_price.
  ///
  /// In en, this message translates to:
  /// **'Total Order Price'**
  String get total_order_price;

  /// No description provided for @order_accepted_success.
  ///
  /// In en, this message translates to:
  /// **'Order accepted successfully'**
  String get order_accepted_success;

  /// No description provided for @accept_order.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get accept_order;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get canceled;

  /// No description provided for @currently_paid_percent.
  ///
  /// In en, this message translates to:
  /// **'Paid %'**
  String get currently_paid_percent;

  /// No description provided for @required_partial_percentage_label.
  ///
  /// In en, this message translates to:
  /// **'Required to start: {percentage}%'**
  String required_partial_percentage_label(Object percentage);

  /// No description provided for @order_cancelled_msg.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get order_cancelled_msg;

  /// No description provided for @order_rejected_msg.
  ///
  /// In en, this message translates to:
  /// **'Order Rejected'**
  String get order_rejected_msg;

  /// No description provided for @payment_redirect_msg.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be redirected to payment gateway soon'**
  String get payment_redirect_msg;

  /// No description provided for @pay_service_costs.
  ///
  /// In en, this message translates to:
  /// **'Pay Service Costs'**
  String get pay_service_costs;

  /// No description provided for @enter_correct_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a correct amount'**
  String get enter_correct_amount;

  /// No description provided for @amount_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Amount updated successfully'**
  String get amount_updated_success;

  /// No description provided for @provider_bank_accounts_label.
  ///
  /// In en, this message translates to:
  /// **'Provider Bank Accounts:'**
  String get provider_bank_accounts_label;

  /// No description provided for @iban_copied_success.
  ///
  /// In en, this message translates to:
  /// **'IBAN copied successfully'**
  String get iban_copied_success;

  /// No description provided for @order_cancelled_success.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get order_cancelled_success;

  /// No description provided for @platform_commission.
  ///
  /// In en, this message translates to:
  /// **'Platform Commission Due'**
  String get platform_commission;

  /// No description provided for @total_order_value_label.
  ///
  /// In en, this message translates to:
  /// **'Total order value: {price} SAR'**
  String total_order_value_label(Object price);

  /// No description provided for @commission_percentage_label.
  ///
  /// In en, this message translates to:
  /// **'Commission: {percentage}%'**
  String commission_percentage_label(Object percentage);

  /// No description provided for @complete_order.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get complete_order;

  /// No description provided for @confirm_completion_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Completion'**
  String get confirm_completion_title;

  /// No description provided for @confirm_completion_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete the order? The status will be changed to completed.'**
  String get confirm_completion_message;

  /// No description provided for @rate_service_title.
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rate_service_title;

  /// No description provided for @rate_service_message.
  ///
  /// In en, this message translates to:
  /// **'Please rate your experience with the provider and write your comment.'**
  String get rate_service_message;

  /// No description provided for @rating_label.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating_label;

  /// No description provided for @comment_label.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment_label;

  /// No description provided for @comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your comment here...'**
  String get comment_hint;

  /// No description provided for @submit_review.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submit_review;

  /// No description provided for @review_submitted_success.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully, thank you!'**
  String get review_submitted_success;

  /// No description provided for @review_submitted_error.
  ///
  /// In en, this message translates to:
  /// **'Error submitting review, please try again.'**
  String get review_submitted_error;

  /// No description provided for @order_completed_success.
  ///
  /// In en, this message translates to:
  /// **'Order completed successfully ✅'**
  String get order_completed_success;

  /// No description provided for @send_complaint.
  ///
  /// In en, this message translates to:
  /// **'Send Complaint'**
  String get send_complaint;

  /// No description provided for @complaint_title.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaint_title;

  /// No description provided for @complaint_type.
  ///
  /// In en, this message translates to:
  /// **'Complaint Type'**
  String get complaint_type;

  /// No description provided for @complaint_content.
  ///
  /// In en, this message translates to:
  /// **'Complaint Content'**
  String get complaint_content;

  /// No description provided for @complaint_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get complaint_submit;

  /// No description provided for @complaint_success.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted successfully. Our team will review it.'**
  String get complaint_success;

  /// No description provided for @complaint_error.
  ///
  /// In en, this message translates to:
  /// **'Error submitting complaint. Please try again later.'**
  String get complaint_error;

  /// No description provided for @type_delay.
  ///
  /// In en, this message translates to:
  /// **'Delay in Appointment'**
  String get type_delay;

  /// No description provided for @type_quality.
  ///
  /// In en, this message translates to:
  /// **'Low Service Quality'**
  String get type_quality;

  /// No description provided for @type_behavior.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Provider Behavior'**
  String get type_behavior;

  /// No description provided for @type_price.
  ///
  /// In en, this message translates to:
  /// **'Price Discrepancy'**
  String get type_price;

  /// No description provided for @type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get type_other;

  /// No description provided for @payment_page_title.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get payment_page_title;

  /// No description provided for @service_price.
  ///
  /// In en, this message translates to:
  /// **'Service Price'**
  String get service_price;

  /// No description provided for @available_points.
  ///
  /// In en, this message translates to:
  /// **'Available Points Balance'**
  String get available_points;

  /// No description provided for @pay_by_points.
  ///
  /// In en, this message translates to:
  /// **'Pay via Points (Wallet)'**
  String get pay_by_points;

  /// No description provided for @pay_by_bond.
  ///
  /// In en, this message translates to:
  /// **'Pay via Bank Transfer (Bond)'**
  String get pay_by_bond;

  /// No description provided for @confirm_points_payment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Points Payment'**
  String get confirm_points_payment;

  /// No description provided for @confirm_points_payment_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pay for the service using your points?'**
  String get confirm_points_payment_msg;

  /// No description provided for @transferred_points_label.
  ///
  /// In en, this message translates to:
  /// **'Points to Use'**
  String get transferred_points_label;

  /// No description provided for @upload_receipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt Image'**
  String get upload_receipt;

  /// No description provided for @amount_to_pay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amount_to_pay;

  /// No description provided for @points_payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment via points successful ✅'**
  String get points_payment_success;

  /// No description provided for @bond_payment_success.
  ///
  /// In en, this message translates to:
  /// **'Bond uploaded successfully and pending review ✅'**
  String get bond_payment_success;

  /// No description provided for @points_payment_error.
  ///
  /// In en, this message translates to:
  /// **'Error paying via points'**
  String get points_payment_error;

  /// No description provided for @bond_payment_error.
  ///
  /// In en, this message translates to:
  /// **'Error uploading bond'**
  String get bond_payment_error;

  /// No description provided for @no_points_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient points balance'**
  String get no_points_balance;

  /// No description provided for @change_image.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get change_image;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @payment_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get payment_confirm;

  /// No description provided for @must_complete_payment.
  ///
  /// In en, this message translates to:
  /// **'You must complete the payment first'**
  String get must_complete_payment;

  /// No description provided for @search_title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Search'**
  String get search_title;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @price_range.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get price_range;

  /// No description provided for @min_price.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get min_price;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get max_price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @reset_filters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset_filters;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'Sorry, no results match your search'**
  String get no_results;

  /// No description provided for @no_results_desc.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or change the filters'**
  String get no_results_desc;

  /// No description provided for @available_now.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get available_now;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Currently Unavailable'**
  String get unavailable;

  /// No description provided for @systemComplaints.
  ///
  /// In en, this message translates to:
  /// **'System Complaints'**
  String get systemComplaints;

  /// No description provided for @addSystemComplaint.
  ///
  /// In en, this message translates to:
  /// **'Add Complaint'**
  String get addSystemComplaint;

  /// No description provided for @sendSystemComplaint.
  ///
  /// In en, this message translates to:
  /// **'Send Complaint'**
  String get sendSystemComplaint;

  /// No description provided for @complaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint Title'**
  String get complaintTitle;

  /// No description provided for @complaintTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Login Problem'**
  String get complaintTitleHint;

  /// No description provided for @complaintType.
  ///
  /// In en, this message translates to:
  /// **'Complaint Type'**
  String get complaintType;

  /// No description provided for @selectComplaintType.
  ///
  /// In en, this message translates to:
  /// **'Select Complaint Type'**
  String get selectComplaintType;

  /// No description provided for @complaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Complaint Details'**
  String get complaintDetails;

  /// No description provided for @complaintDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the problem in detail here...'**
  String get complaintDetailsHint;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @confirmSend.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send'**
  String get confirmSend;

  /// No description provided for @confirmSendMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to send this complaint?'**
  String get confirmSendMsg;

  /// No description provided for @complaintSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Complaint sent successfully'**
  String get complaintSentSuccess;

  /// No description provided for @complaintSentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send complaint'**
  String get complaintSentError;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter complaint title'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter complaint details'**
  String get pleaseEnterDetails;

  /// No description provided for @pleaseSelectType.
  ///
  /// In en, this message translates to:
  /// **'Please select complaint type'**
  String get pleaseSelectType;

  /// No description provided for @noComplaints.
  ///
  /// In en, this message translates to:
  /// **'No complaints currently'**
  String get noComplaints;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get typePerformance;

  /// No description provided for @typePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get typePayment;

  /// No description provided for @typeAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get typeAccount;

  /// No description provided for @typeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get typeSuggestion;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @searchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Searching for your location...'**
  String get searchingLocation;

  /// No description provided for @determiningLocationAccurate.
  ///
  /// In en, this message translates to:
  /// **'Determining accurate location...'**
  String get determiningLocationAccurate;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled, please enable GPS'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionForeverDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it from phone settings.'**
  String get locationPermissionForeverDenied;

  /// No description provided for @locationUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Location update failed'**
  String get locationUpdateFailed;

  /// No description provided for @defaultCountry.
  ///
  /// In en, this message translates to:
  /// **'Yemen'**
  String get defaultCountry;

  /// No description provided for @seeker_role.
  ///
  /// In en, this message translates to:
  /// **'Service Seeker'**
  String get seeker_role;

  /// No description provided for @provider_role.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get provider_role;

  /// No description provided for @no_phones_added.
  ///
  /// In en, this message translates to:
  /// **'No phone numbers added'**
  String get no_phones_added;

  /// No description provided for @fetching_address.
  ///
  /// In en, this message translates to:
  /// **'Fetching address...'**
  String get fetching_address;

  /// No description provided for @location_not_set.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get location_not_set;

  /// No description provided for @edit_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_title;

  /// No description provided for @bio_label.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio_label;

  /// No description provided for @geo_location.
  ///
  /// In en, this message translates to:
  /// **'Geographic Location'**
  String get geo_location;

  /// No description provided for @update_label.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_label;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone_number;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updated_success;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @no_max_limit.
  ///
  /// In en, this message translates to:
  /// **'No max limit'**
  String get no_max_limit;

  /// No description provided for @share_service_message.
  ///
  /// In en, this message translates to:
  /// **'Hello! Discover this amazing service: \"{title}\" by {provider}, for only {price} SAR! \nDownload our app to book now.'**
  String share_service_message(Object price, Object provider, Object title);

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @example_address_city.
  ///
  /// In en, this message translates to:
  /// **'Riyadh, Al-Malqa'**
  String get example_address_city;

  /// No description provided for @example_address_street.
  ///
  /// In en, this message translates to:
  /// **'Prince Muhammad bin Saad St, Building 45'**
  String get example_address_street;

  /// No description provided for @example_reviewer_name.
  ///
  /// In en, this message translates to:
  /// **'Sarah Al-Ali'**
  String get example_reviewer_name;

  /// No description provided for @example_review_time.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get example_review_time;

  /// No description provided for @example_review_content.
  ///
  /// In en, this message translates to:
  /// **'Excellent service and the team arrived on time. They cleaned every corner of the house thoroughly. Highly recommend!'**
  String get example_review_content;

  /// No description provided for @confirm_customize_order.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Customize Order'**
  String get confirm_customize_order;

  /// No description provided for @new_service_label.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_service_label;

  /// No description provided for @request_details_title.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get request_details_title;

  /// No description provided for @receiver_name.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get receiver_name;

  /// No description provided for @service_location_title.
  ///
  /// In en, this message translates to:
  /// **'Service Location'**
  String get service_location_title;

  /// No description provided for @click_to_pick_location.
  ///
  /// In en, this message translates to:
  /// **'Click to pick your location on map'**
  String get click_to_pick_location;

  /// No description provided for @additional_services.
  ///
  /// In en, this message translates to:
  /// **'Additional Services'**
  String get additional_services;

  /// No description provided for @additional_notes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additional_notes;

  /// No description provided for @notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Write any details you want the provider to know...'**
  String get notes_hint;

  /// No description provided for @final_total.
  ///
  /// In en, this message translates to:
  /// **'Final Total'**
  String get final_total;

  /// No description provided for @order_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Your order has been sent successfully! 🚀'**
  String get order_sent_success;

  /// No description provided for @order_sent_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to send order'**
  String get order_sent_error;

  /// No description provided for @confirm_and_book.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Book Service'**
  String get confirm_and_book;

  /// No description provided for @loading_policy.
  ///
  /// In en, this message translates to:
  /// **'Loading policy...'**
  String get loading_policy;

  /// No description provided for @no_policy_available.
  ///
  /// In en, this message translates to:
  /// **'No content available currently'**
  String get no_policy_available;

  /// No description provided for @last_update.
  ///
  /// In en, this message translates to:
  /// **'Last Update: '**
  String get last_update;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @read_terms_desc.
  ///
  /// In en, this message translates to:
  /// **'Please read the app policy and terms and conditions carefully before proceeding.'**
  String get read_terms_desc;

  /// No description provided for @terms_intro_title.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction'**
  String get terms_intro_title;

  /// No description provided for @terms_intro_text.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Seeker. These terms are a binding agreement between you as a user and the app management. By using the app, you agree to comply with all mentioned terms.'**
  String get terms_intro_text;

  /// No description provided for @terms_quality_title.
  ///
  /// In en, this message translates to:
  /// **'2. Quality Standards'**
  String get terms_quality_title;

  /// No description provided for @terms_quality_text.
  ///
  /// In en, this message translates to:
  /// **'The user is committed to maintaining the highest standards of quality and professionalism when dealing with the other party. You must arrive on time and perform the agreed service accurately.'**
  String get terms_quality_text;

  /// No description provided for @terms_pricing_title.
  ///
  /// In en, this message translates to:
  /// **'3. Pricing and Payment'**
  String get terms_pricing_title;

  /// No description provided for @terms_pricing_text.
  ///
  /// In en, this message translates to:
  /// **'Prices are determined based on the type of service. It is forbidden to request additional amounts outside the application.'**
  String get terms_pricing_text;

  /// No description provided for @terms_cancellation_title.
  ///
  /// In en, this message translates to:
  /// **'4. Cancellation and Refund'**
  String get terms_cancellation_title;

  /// No description provided for @terms_cancellation_text.
  ///
  /// In en, this message translates to:
  /// **'The cancellation policy is subject to the terms shown in the app. Fees may be imposed for late cancellations.'**
  String get terms_cancellation_text;

  /// No description provided for @agree_to_terms_prefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get agree_to_terms_prefix;

  /// No description provided for @and_label.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and_label;

  /// No description provided for @agree_and_continue.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get agree_and_continue;

  /// No description provided for @activation_code_sent.
  ///
  /// In en, this message translates to:
  /// **'The activation code has been sent to the email\n{email}'**
  String activation_code_sent(Object email);

  /// No description provided for @error_email_missing.
  ///
  /// In en, this message translates to:
  /// **'Error: Email is missing'**
  String get error_email_missing;

  /// No description provided for @did_not_receive_code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get did_not_receive_code;

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resend_code;

  /// No description provided for @resend_code_timer.
  ///
  /// In en, this message translates to:
  /// **'Resend Code ({timer}s)'**
  String resend_code_timer(Object timer);

  /// No description provided for @customLocation.
  ///
  /// In en, this message translates to:
  /// **'Custom Location'**
  String get customLocation;

  /// No description provided for @activateAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate Account'**
  String get activateAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
