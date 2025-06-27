import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr')
  ];

  /// Button text to retry a failed action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message displayed when network connection fails
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get networkError;

  /// Generic error message for unexpected failures
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get generalError;

  /// Button text and action for user authentication
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Placeholder text for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Link text for password recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// Text prompting user to create account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Button text for account registration
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Call to action for account creation
  ///
  /// In en, this message translates to:
  /// **'Create your account now'**
  String get createAccount;

  /// Label for user profile image
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// Option to capture photo with camera
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Option to select photo from device gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Label for complete name input field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Placeholder text for full name input
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// Label for phone number input field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Placeholder text for phone number input
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Label for password confirmation field
  ///
  /// In en, this message translates to:
  /// **'Retype Password'**
  String get retypePassword;

  /// Text prompting existing users to log in
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// Message requiring user authentication
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get loginToContinue;

  /// Navigation button to return to previous screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Title for cancellation terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy'**
  String get cancellationPolicy;

  /// Specific cancellation rules for service buyers
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy for Customers'**
  String get cancellationPolicyForCustomers;

  /// Specific cancellation rules for service sellers
  ///
  /// In en, this message translates to:
  /// **'Cancellation Policy for Service Providers'**
  String get cancellationPolicyForServiceProviders;

  /// Section title for general terms and guidelines
  ///
  /// In en, this message translates to:
  /// **'General Rules'**
  String get generalRules;

  /// Label for language selection option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Button text to save changes or data
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Help and customer service section
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Welcome message for support section
  ///
  /// In en, this message translates to:
  /// **'How Can We Assist You?'**
  String get supportHeader;

  /// Support option via email communication
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// Description of email support service
  ///
  /// In en, this message translates to:
  /// **'Reach out to our team via email for assistance.'**
  String get emailSupportDescription;

  /// Real-time chat support option
  ///
  /// In en, this message translates to:
  /// **'Live Chat Support'**
  String get chatSupport;

  /// Description of live chat support service
  ///
  /// In en, this message translates to:
  /// **'Connect with a support agent in real-time.'**
  String get chatSupportDescription;

  /// Support option through WhatsApp messaging
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get whatsappSupport;

  /// Description of WhatsApp support service
  ///
  /// In en, this message translates to:
  /// **'Message us on WhatsApp for quick support.'**
  String get whatsappSupportDescription;

  /// Legal terms and service conditions
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Description of terms and conditions section
  ///
  /// In en, this message translates to:
  /// **'View the terms and conditions of using the Good One app.'**
  String get termsAndConditionsDescription;

  /// Description of cancellation policy section
  ///
  /// In en, this message translates to:
  /// **'Review our policy on cancellations and refunds.'**
  String get cancellationPolicyDescription;

  /// Option to permanently remove user account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Warning about permanent account deletion
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data.'**
  String get deleteAccountDescription;

  /// Confirmation message for irreversible account deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// Button to cancel an action or dismiss dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to confirm deletion action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Opening section of terms or documentation
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// Section explaining key terms and meanings
  ///
  /// In en, this message translates to:
  /// **'Definitions'**
  String get definitions;

  /// Requirements for using the service
  ///
  /// In en, this message translates to:
  /// **'User Eligibility'**
  String get userEligibility;

  /// Rules for creating and using accounts
  ///
  /// In en, this message translates to:
  /// **'Account Registration and Use'**
  String get accountRegistrationAndUse;

  /// Guidelines for user communication and privacy
  ///
  /// In en, this message translates to:
  /// **'Communication and Privacy'**
  String get communicationAndPrivacy;

  /// Rules governing financial transactions
  ///
  /// In en, this message translates to:
  /// **'Payments and Transactions'**
  String get paymentsAndTransactions;

  /// Obligations and rules for service providers
  ///
  /// In en, this message translates to:
  /// **'Service Provider Requirements'**
  String get serviceProviderRequirements;

  /// Rules and guidelines for advertisements
  ///
  /// In en, this message translates to:
  /// **'Advertising Policy'**
  String get advertisingPolicy;

  /// List of forbidden actions on the platform
  ///
  /// In en, this message translates to:
  /// **'Prohibited Activities'**
  String get prohibitedActivities;

  /// Process for handling conflicts between users
  ///
  /// In en, this message translates to:
  /// **'Dispute Resolution'**
  String get disputeResolution;

  /// Conditions for account termination or suspension
  ///
  /// In en, this message translates to:
  /// **'Termination and Suspension'**
  String get terminationAndSuspension;

  /// Legal disclaimers and liability limitations
  ///
  /// In en, this message translates to:
  /// **'Liability and Disclaimers'**
  String get liabilityAndDisclaimers;

  /// Policy on modifying terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get changesToTerms;

  /// How to reach customer support or company
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// First onboarding screen description highlighting home services
  ///
  /// In en, this message translates to:
  /// **'Discover quick and easy solutions for all your home needs, from plumbing and electrical to cleaning and renovation. Let us make your home more comfortable.'**
  String get onboardingDesc1;

  /// Second onboarding screen description emphasizing service quality
  ///
  /// In en, this message translates to:
  /// **'We offer a comprehensive range of high-quality, reliable home services, so you can enjoy your time at home without any worries.'**
  String get onboardingDesc2;

  /// First onboarding screen title about professional services
  ///
  /// In en, this message translates to:
  /// **'Home services with a professional touch!'**
  String get onboardingTitle1;

  /// Second onboarding screen title about convenience
  ///
  /// In en, this message translates to:
  /// **'We\'re here to make your life easier!'**
  String get onboardingTitle2;

  /// Button to bypass current step or section
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Button to proceed to next step or screen
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Title for language preference screen
  ///
  /// In en, this message translates to:
  /// **'Language selection'**
  String get languageSelectionTitle;

  /// Greeting message prefix for app welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeMessage;

  /// Instruction for selecting preferred language
  ///
  /// In en, this message translates to:
  /// **'Choose your language to start'**
  String get chooseLanguagePrompt;

  /// Service reservation or appointment
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// Status indicating ongoing service or process
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// Status indicating finished service or task
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Status indicating cancelled service or booking
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// Message when user has no service reservations
  ///
  /// In en, this message translates to:
  /// **'No bookings'**
  String get noBookings;

  /// Fallback message for undefined booking status
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get unknownStatus;

  /// Action to verify service completion
  ///
  /// In en, this message translates to:
  /// **'Confirm Service'**
  String get confirmService;

  /// Question to confirm service delivery
  ///
  /// In en, this message translates to:
  /// **'Has the service been completed?'**
  String get hasServiceBeenReceived;

  /// Response indicating service not completed
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// Button to verify or approve an action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Current state or condition label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Type of work or assistance provided
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// Place where service will be performed
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Scheduled time for service
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Cost of service or item
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Singular time unit for duration
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// Plural time unit for duration
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Sum or complete amount
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Action to cancel a service reservation
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// Explanation required for booking cancellation
  ///
  /// In en, this message translates to:
  /// **'Reason for Cancellation'**
  String get reasonForCancellation;

  /// Placeholder for cancellation reason input
  ///
  /// In en, this message translates to:
  /// **'Enter your reason here...'**
  String get enterReason;

  /// Button to close dialog or window
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Error message when cancellation reason is missing
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for cancellation.'**
  String get reasonRequired;

  /// Button to send or save form data
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Beginning date for service or booking
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// Beginning time for service or booking
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// Length of time for service
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Notice that extra payment is needed
  ///
  /// In en, this message translates to:
  /// **'Additional Payment Required'**
  String get additionalPaymentRequired;

  /// Display of extra time needed with placeholder
  ///
  /// In en, this message translates to:
  /// **'Additional hours: {hours}'**
  String additionalHours(String hours);

  /// Display of extra cost with placeholder
  ///
  /// In en, this message translates to:
  /// **'Additional cost: \${cost}'**
  String additionalCost(String cost);

  /// Overview of reservation details
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// Specific information about reservation
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// Calendar date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Message when no address is provided
  ///
  /// In en, this message translates to:
  /// **'No location specified'**
  String get noLocationSpecified;

  /// Section for discount codes and promotions
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get couponsAndOffers;

  /// Placeholder for coupon code input field
  ///
  /// In en, this message translates to:
  /// **'Type your coupon code here...'**
  String get typeCouponCodeHere;

  /// Button to use coupon or submit changes
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Confirmation message showing applied coupon and discount
  ///
  /// In en, this message translates to:
  /// **'Coupon: ({coupon}), discount ({discount}%)'**
  String couponApplied(String coupon, String discount);

  /// Breakdown of costs and charges
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// Cost per hour for service
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate'**
  String get hourlyRate;

  /// Total before taxes or fees
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Amount reduced from original price
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Final amount to be paid
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Time arrangement or booking calendar
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Error message for invalid time selection
  ///
  /// In en, this message translates to:
  /// **'Please select a valid future time slot'**
  String get selectValidTimeSlot;

  /// Placeholder for location search input
  ///
  /// In en, this message translates to:
  /// **'Search City Or Place'**
  String get searchCityOrPlace;

  /// Button to approve selected address
  ///
  /// In en, this message translates to:
  /// **'Confirm This Location'**
  String get confirmThisLocation;

  /// Label for chosen map location
  ///
  /// In en, this message translates to:
  /// **'Selected Location on Map'**
  String get selectedLocationOnMap;

  /// Greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Action to find or look for items
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Title for services offered section
  ///
  /// In en, this message translates to:
  /// **'Our services'**
  String get ourServices;

  /// Link to view complete list
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Section showcasing top-rated service providers
  ///
  /// In en, this message translates to:
  /// **'Best Contractors'**
  String get bestContractors;

  /// Main screen or residence-related services
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Work or assistance provided
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// User account information and settings
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Messaging or communication feature
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Action to reserve or schedule service
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Misspelled 'Confirmed' - verification status
  ///
  /// In en, this message translates to:
  /// **'Confird'**
  String get confird;

  /// Misspelled 'With License' - having official permits
  ///
  /// In en, this message translates to:
  /// **'With Lisence'**
  String get withLisence;

  /// Duration of professional work history
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// Score or evaluation from customers
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Number of customers served
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// Information section about service provider
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Collection of images showcasing work
  ///
  /// In en, this message translates to:
  /// **'Photo album'**
  String get photoAlbum;

  /// Feedback and comments from clients
  ///
  /// In en, this message translates to:
  /// **'Customer reviews'**
  String get customerReviews;

  /// Action to evaluate and score service quality
  ///
  /// In en, this message translates to:
  /// **'Rate Service'**
  String get rateService;

  /// Prompt to evaluate service satisfaction
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// Written feedback or review text
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Placeholder encouraging user to write review
  ///
  /// In en, this message translates to:
  /// **'Share your feedback...'**
  String get commentHint;

  /// Message when no services are offered
  ///
  /// In en, this message translates to:
  /// **'No Services Available'**
  String get noServicesAvailable;

  /// Personal information and account settings
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// Action to modify or refresh information
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Alerts and messages from the system
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Message when notification list is empty
  ///
  /// In en, this message translates to:
  /// **'No notifications available'**
  String get noNotifications;

  /// Instruction for refreshing content with swipe gesture
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// Current date reference
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Previous time period reference
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// Data protection and usage policies
  ///
  /// In en, this message translates to:
  /// **'Privacy and Policy'**
  String get privacyPolicy;

  /// Action to sign out of account
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Service requests or bookings made
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Action to modify or change information
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Action to modify service information
  ///
  /// In en, this message translates to:
  /// **'Edit Service Details'**
  String get editServiceDetails;

  /// Instruction to choose service type
  ///
  /// In en, this message translates to:
  /// **'Select Service Category'**
  String get selectServiceCategory;

  /// Instruction to choose specific service subtype
  ///
  /// In en, this message translates to:
  /// **'Select Subcategory'**
  String get selectSubcategory;

  /// Detailed explanation of service offered
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// Instruction to write comprehensive service details
  ///
  /// In en, this message translates to:
  /// **'Provide Detailed Description'**
  String get provideDetailedDescription;

  /// Hourly rate for service
  ///
  /// In en, this message translates to:
  /// **'Service Price Per Hour'**
  String get servicePricePerHour;

  /// Instruction to input cost amount
  ///
  /// In en, this message translates to:
  /// **'Enter Price'**
  String get enterPrice;

  /// Instruction to input years of professional experience
  ///
  /// In en, this message translates to:
  /// **'Enter Experience Years'**
  String get enterExperienceYears;

  /// Question about professional certification
  ///
  /// In en, this message translates to:
  /// **'Do You Have Certificate?'**
  String get doYouHaveCertificate;

  /// Action to add professional certification document
  ///
  /// In en, this message translates to:
  /// **'Upload Your Certificate'**
  String get uploadYourCertificate;

  /// Action to organize photos showcasing work
  ///
  /// In en, this message translates to:
  /// **'Manage Service Images'**
  String get manageServiceImages;

  /// Personal list of service requests
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// Error message for unexpected failures
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get somethingWentWrong;

  /// Message when order list is empty
  ///
  /// In en, this message translates to:
  /// **'No Orders Available'**
  String get noOrdersAvailable;

  /// Message when no orders exist for selected date
  ///
  /// In en, this message translates to:
  /// **'No Orders For This Date'**
  String get noOrdersForThisDate;

  /// Specific information about service request
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get ordersDetails;

  /// Overview of service request details
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// Timestamp when order was made
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// Complete duration of service
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// Hourly rate for service
  ///
  /// In en, this message translates to:
  /// **'Cost Per Hour'**
  String get costPerHour;

  /// Final amount for entire service
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// Action to message service requester
  ///
  /// In en, this message translates to:
  /// **'Chat With Customer'**
  String get chatWithCustomer;

  /// Additional comment or instruction
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Address where service will be performed
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// Action to finish or mark as done
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Action to cancel service request
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// Current state of money withdrawal request
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Status'**
  String get withdrawalStatus;

  /// Status indicating withdrawal has been processed
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// Status indicating withdrawal is pending
  ///
  /// In en, this message translates to:
  /// **'Waiting to Send'**
  String get statusWaitingToSend;

  /// Status indicating withdrawal request is acknowledged
  ///
  /// In en, this message translates to:
  /// **'Request Received'**
  String get statusRequestReceived;

  /// Status when information is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Urban area or municipality name
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Instruction to input city name
  ///
  /// In en, this message translates to:
  /// **'Enter Your City'**
  String get enterCity;

  /// Nation or state name
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Instruction to input country name
  ///
  /// In en, this message translates to:
  /// **'Enter Your Country'**
  String get enterCountry;

  /// Action to create new service offering
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// Instruction to describe professional skills
  ///
  /// In en, this message translates to:
  /// **'Define Your Service Expertise'**
  String get defineYourServiceExpertise;

  /// Instruction to select service type
  ///
  /// In en, this message translates to:
  /// **'Choose Service Category'**
  String get chooseServiceCategory;

  /// Instruction to select specific service subtype
  ///
  /// In en, this message translates to:
  /// **'Choose Subcategory'**
  String get chooseSubcategory;

  /// Error message when service description is missing
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// Error message when service price is missing
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// Error message when experience field is missing
  ///
  /// In en, this message translates to:
  /// **'Experience is required'**
  String get experienceRequired;

  /// Digital money storage and payment management
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Action to take money out of account
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawal;

  /// Overview of service details and information
  ///
  /// In en, this message translates to:
  /// **'Service Summary'**
  String get serviceSummary;

  /// Status indicating service provider is temporarily unavailable
  ///
  /// In en, this message translates to:
  /// **'On Vacation'**
  String get onVacation;

  /// Status indicating service provider is ready to work
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Action to change status from vacation to available
  ///
  /// In en, this message translates to:
  /// **'Return To Work'**
  String get returnToWork;

  /// Action to change status to temporarily unavailable
  ///
  /// In en, this message translates to:
  /// **'Go On Vacation'**
  String get goOnVacation;

  /// Background verification process for safety
  ///
  /// In en, this message translates to:
  /// **'Security Check'**
  String get securityCheck;

  /// Status indicating successful background verification
  ///
  /// In en, this message translates to:
  /// **'Security Check Completed'**
  String get securityCheckCompleted;

  /// Status indicating background verification in progress
  ///
  /// In en, this message translates to:
  /// **'Security Check Pending'**
  String get securityCheckPending;

  /// Action to finish background verification process
  ///
  /// In en, this message translates to:
  /// **'Complete Security Check'**
  String get completeSecurityCheck;

  /// Current state of submitted request
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// List of work types offered by provider
  ///
  /// In en, this message translates to:
  /// **'Services Provided'**
  String get servicesProvided;

  /// Status indicating content can be seen by users
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// Status indicating content is not active or available
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Financial institution account for payments
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// Error message when complete name is missing
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// Error message when email address is missing
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Error message when phone number is missing
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// Error message when password is missing
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Error message for incorrect or expired discount code
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get invalidCoupon;

  /// Error message for incorrectly formatted email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Error message for insufficient password length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// Error message when password confirmation is missing
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// Error message when password and confirmation differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Error message when location information is missing
  ///
  /// In en, this message translates to:
  /// **'Your city and country are required'**
  String get locationRequired;

  /// Success message title for completed booking
  ///
  /// In en, this message translates to:
  /// **'Order Created Successfully'**
  String get orderSuccessTitle;

  /// Success message details for completed booking
  ///
  /// In en, this message translates to:
  /// **'Your booking has been confirmed. You can view it in your bookings.'**
  String get orderSuccessDescription;

  /// Appreciation message for submitted review
  ///
  /// In en, this message translates to:
  /// **'Thank You for Your Feedback!'**
  String get feedbackSuccessTitle;

  /// Confirmation that review was saved
  ///
  /// In en, this message translates to:
  /// **'Your rating has been submitted successfully.'**
  String get feedbackSuccessDescription;

  /// Navigation link to return to bookings list
  ///
  /// In en, this message translates to:
  /// **'Back to Bookings'**
  String get backToBookings;

  /// Error message when review submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback'**
  String get submissionFailed;

  /// Status indicating waiting for action or approval
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Instruction to choose nation from list
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// Instruction to choose urban area from list
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// Subject line for customer service inquiry
  ///
  /// In en, this message translates to:
  /// **'Support Request from App'**
  String get supportRequestfromApp;

  /// Template message for contacting support
  ///
  /// In en, this message translates to:
  /// **'Hello, I need assistance with...'**
  String get iNeedAssistance;

  /// Confirmation that email address was copied
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;

  /// Error message when WhatsApp cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp'**
  String get unableOpenWhatsApp;

  /// Error message for WhatsApp launch failure
  ///
  /// In en, this message translates to:
  /// **'Error opening WhatsApp'**
  String get errorOpeningWhatsApp;

  /// Placeholder for chat message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Message when chat conversation is empty
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Chat conversation or communication list
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Label indicating unread message
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newMessage;

  /// Message when chat list is empty
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// Action to begin new chat
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation'**
  String get startNewConversation;

  /// Action to change existing reservation details
  ///
  /// In en, this message translates to:
  /// **'Modify Booking'**
  String get modifyBooking;

  /// Error message for past time selection
  ///
  /// In en, this message translates to:
  /// **'Start time must be in the future'**
  String get startTimeFuture;

  /// Error message for invalid end time selection
  ///
  /// In en, this message translates to:
  /// **'End time must be between 6:00 and 22:00'**
  String get endTimeBetween;

  /// Error message when service provider is not chosen
  ///
  /// In en, this message translates to:
  /// **'No contractor selected'**
  String get noContractorSelected;

  /// Local government charges applied to services
  ///
  /// In en, this message translates to:
  /// **'Region Taxes'**
  String get regionTaxes;

  /// Service charge for using the app
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// Time required to complete specific job
  ///
  /// In en, this message translates to:
  /// **'Task Duration'**
  String get taskDuration;

  /// Error message when user information cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'User data not available'**
  String get userDataNotAvailable;

  /// Error message for incorrectly formatted phone number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// Instruction to add photos for better customer appeal
  ///
  /// In en, this message translates to:
  /// **'Please upload unique images to attract customers'**
  String get uploadImages;

  /// Extra images showcasing work quality
  ///
  /// In en, this message translates to:
  /// **'Additional photos of the service'**
  String get additionalPhotos;

  /// Information about multiple image selection
  ///
  /// In en, this message translates to:
  /// **'You can choose more than one image for the service'**
  String get chooseMoreImage;

  /// Action to include photos in service listing
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get addimages;

  /// Single photo or picture
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Error message when map application fails to open
  ///
  /// In en, this message translates to:
  /// **'Could not launch Google Maps.'**
  String get notLaunchGoogleMaps;

  /// Service request or booking made by customer
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// Error message when map cannot be displayed
  ///
  /// In en, this message translates to:
  /// **'Unable to load map.'**
  String get unableLoadMap;

  /// Privacy policy section about information gathering
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get dataWeCollect;

  /// Privacy policy section about data usage
  ///
  /// In en, this message translates to:
  /// **'How We Use the Data'**
  String get howWeUseData;

  /// Privacy policy section about external data sharing
  ///
  /// In en, this message translates to:
  /// **'Sharing Data with Third Parties'**
  String get sharingData;

  /// Privacy policy section about user privileges
  ///
  /// In en, this message translates to:
  /// **'User Rights'**
  String get userRights;

  /// Privacy policy section about security measures
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get dataProtection;

  /// Privacy policy section about policy updates
  ///
  /// In en, this message translates to:
  /// **'Changes to the Privacy Policy'**
  String get changesToPolicy;

  /// Section for reaching customer support
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Explanation of privacy policy purpose
  ///
  /// In en, this message translates to:
  /// **'View our Privacy Policy to understand how we collect, use, and protect your personal data.'**
  String get privacyPolicyDescription;

  /// Message when no recent money withdrawals exist
  ///
  /// In en, this message translates to:
  /// **'no Recent Withdrawals'**
  String get noRecentWithdrawals;

  /// Instruction to return later for new information
  ///
  /// In en, this message translates to:
  /// **'check BackLater For Updates'**
  String get checkBackLaterUpdates;

  /// Sum of money or quantity
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Person providing service or labor
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// Message when time information is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get unknownTime;

  /// Complete count of services provided
  ///
  /// In en, this message translates to:
  /// **'Total Services'**
  String get totalServices;

  /// Transportation or movement status
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get transit;

  /// Financial organization or bank
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// User profile or financial account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Confirmation that money withdrawal request was sent
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request submitted'**
  String get withdrawalRequestSubmitted;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No Service Found'**
  String get noServiceFound;

  /// Placeholder for service search input field
  ///
  /// In en, this message translates to:
  /// **'Search for a service...'**
  String get searchServices;

  /// List of items found from search query
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Instructions for password reset process
  ///
  /// In en, this message translates to:
  /// **'Please enter your registered email address, and we will send you a verification code (OTP) to reset your password.'**
  String get resetPasswordEnterEmail;

  /// Process of confirming one-time password code
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// Instruction to input received verification code
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code (OTP)'**
  String get enterVerificationCode;

  /// Confirmation that verification code was sent
  ///
  /// In en, this message translates to:
  /// **'We have sent a 6-digit verification code to your registered contact.'**
  String get otpSent;

  /// Action to verify entered code
  ///
  /// In en, this message translates to:
  /// **'Check the code'**
  String get checkCode;

  /// Action to request new verification code
  ///
  /// In en, this message translates to:
  /// **'Resend the code'**
  String get resendCode;

  /// Message when no service providers are available
  ///
  /// In en, this message translates to:
  /// **'No contractors found'**
  String get noContractorsFound;

  /// Message when search filters return no results
  ///
  /// In en, this message translates to:
  /// **'No contractors match the current filters.'**
  String get noContractorsMatchFilters;

  /// Message when no providers exist in selected service type
  ///
  /// In en, this message translates to:
  /// **'No contractors are currently available in this category.'**
  String get noContractorsAvailableInThisCategory;

  /// Error message when messaging system cannot connect
  ///
  /// In en, this message translates to:
  /// **'Chat Connection Failed'**
  String get chatConnectionFailed;

  /// Status message while loading user data
  ///
  /// In en, this message translates to:
  /// **'Waiting For User Info'**
  String get waitingForUserInfo;

  /// Status indicating successful connection
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Action to establish connection again
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// Instruction when network connectivity issues occur
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get checkConnection;

  /// Financial account details for payments
  ///
  /// In en, this message translates to:
  /// **'Bank Account Information'**
  String get bankAccountInformation;

  /// Canadian electronic money transfer details
  ///
  /// In en, this message translates to:
  /// **'Interac e-Transfer Information'**
  String get interacTransferInformation;

  /// Explanation of Canadian electronic payment method
  ///
  /// In en, this message translates to:
  /// **'Funds will be sent to this email address via Interac e-Transfer.'**
  String get interacMessage;

  /// Option to store payment details for convenience
  ///
  /// In en, this message translates to:
  /// **'Save account information for future use'**
  String get saveAccount;

  /// Status message indicating operation in progress
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Error message when mandatory form fields are incomplete
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly.'**
  String get requiredFields;

  /// Instruction to choose time measurement method
  ///
  /// In en, this message translates to:
  /// **'Select Duration Type'**
  String get selectDurationType;

  /// Time unit for multi-day services
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Service pricing based on completion rather than time
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskBased;

  /// Instruction to input time duration in hours
  ///
  /// In en, this message translates to:
  /// **'Enter Number of Hours'**
  String get enterHours;

  /// Instruction to input time duration in days
  ///
  /// In en, this message translates to:
  /// **'Enter Number of Days'**
  String get enterDays;

  /// Instruction to input service time length
  ///
  /// In en, this message translates to:
  /// **'Enter Duration'**
  String get enterDuration;

  /// Sample format for entering hours with decimal
  ///
  /// In en, this message translates to:
  /// **'e.g. 2.5'**
  String get exampleHours;

  /// Sample format for entering days with decimal
  ///
  /// In en, this message translates to:
  /// **'e.g. 1.5'**
  String get exampleDays;

  /// Abbreviated label for hours time unit
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hoursUnit;

  /// Label for days time unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// Feature for fast duration selection
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// Complete number of days for service
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// Set cost for completing specific job
  ///
  /// In en, this message translates to:
  /// **'Fixed Task Price'**
  String get fixedTaskPrice;

  /// Standard single hour service description
  ///
  /// In en, this message translates to:
  /// **'One hour service at hourly rate'**
  String get oneHourService;

  /// Explanation of task-based pricing model
  ///
  /// In en, this message translates to:
  /// **'Fixed price task - charged at hourly rate for one hour of service'**
  String get taskBasedInfo;

  /// Instruction to input fixed job cost
  ///
  /// In en, this message translates to:
  /// **'Enter Task Price'**
  String get taskPrice;

  /// Sample format for entering task price
  ///
  /// In en, this message translates to:
  /// **'e.g. 150.00'**
  String get exampleTaskPrice;

  /// Different cost structure choices available
  ///
  /// In en, this message translates to:
  /// **'Pricing Options'**
  String get pricingOptions;

  /// Cost per unit of time for service
  ///
  /// In en, this message translates to:
  /// **'service Rate'**
  String get serviceRate;

  /// Button text and page title for password reset
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Main heading for password reset screen
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// Instructions for password reset process
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email and create a new password for your account.'**
  String get enterOtpAndNewPassword;

  /// Label for OTP input field
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// Label for new password input field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Hint text for new password field
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// Label for confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Hint text for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmNewPassword;

  /// Error message when OTP is missing
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get otpRequired;

  /// Success message after password reset
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please log in with your new password.'**
  String get passwordResetSuccess;

  /// Introduction text for Terms and Conditions
  ///
  /// In en, this message translates to:
  /// **'Last Updated: 15 April 2025\\n\\nWelcome to Good One. These Terms and Conditions govern your use of our mobile application and services. By using our app, you agree to comply with these terms. If you do not agree, please do not use the app.'**
  String get termsIntroduction;

  /// Definition of 'App' in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Refers to Good One app, the mobile application that connects customers with service providers.'**
  String get appDefinition;

  /// Definition of 'User' in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Refers to anyone who accesses and uses the App, including both customers and service providers.'**
  String get userDefinition;

  /// Definition of 'Customer' in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Refers to individuals seeking services through the App.'**
  String get customerDefinition;

  /// Definition of 'Service Provider' in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Refers to individuals offering their services through the App.'**
  String get serviceProviderDefinition;

  /// Definition of 'Platform' in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Refers to the App and its associated services.'**
  String get platformDefinition;

  /// Introduction to app usage requirements
  ///
  /// In en, this message translates to:
  /// **'To use the App, you must:'**
  String get toUseTheApp;

  /// Requirement for accurate information
  ///
  /// In en, this message translates to:
  /// **'Provide accurate and truthful information during registration.'**
  String get provideAccurateInfo;

  /// Legal compliance requirement
  ///
  /// In en, this message translates to:
  /// **'Comply with all applicable laws and regulations.'**
  String get complyWithLaws;

  /// Age requirement for service providers
  ///
  /// In en, this message translates to:
  /// **'Be at least 18 years old to register as a service provider. Minors under 18 are required to provide parents\' consent to confirm that the service will be under the parent\'s responsibility and supervision.'**
  String get ageRequirement;

  /// Provincial age requirements section title
  ///
  /// In en, this message translates to:
  /// **'Minimum Working Age by Province/Territory'**
  String get minimumWorkingAgeByProvince;

  /// Provincial minimum age information
  ///
  /// In en, this message translates to:
  /// **'Most provinces set 14 as the minimum age for general work with restrictions.'**
  String get mostProvincesSet14Minimum;

  /// Younger worker provisions
  ///
  /// In en, this message translates to:
  /// **'Some provinces allow 12-year-olds to work in specific, non-hazardous jobs with parental consent.'**
  String get someProvinces12YearOlds;

  /// Minor work restrictions section title
  ///
  /// In en, this message translates to:
  /// **'Restrictions on Work for Minors'**
  String get restrictionsWorkMinors;

  /// Hazardous work prohibition title
  ///
  /// In en, this message translates to:
  /// **'No hazardous work'**
  String get noHazardousWork;

  /// Dangerous work restriction
  ///
  /// In en, this message translates to:
  /// **'Minors cannot perform dangerous jobs (e.g., construction, heavy machinery, electrical work).'**
  String get minorsCannotDangerousJobs;

  /// Parental consent requirement title
  ///
  /// In en, this message translates to:
  /// **'Parental consent'**
  String get parentalConsent;

  /// Parental permission requirement
  ///
  /// In en, this message translates to:
  /// **'Many provinces require parental permission for those under 16.'**
  String get provincesRequireParentalPermission;

  /// Work hours limitation title
  ///
  /// In en, this message translates to:
  /// **'Limited work hours'**
  String get limitedWorkHours;

  /// Work hours restriction for minors
  ///
  /// In en, this message translates to:
  /// **'Kids under 18 usually can\'t work late hours or during school time.'**
  String get kidsNoLateHours;

  /// Business licensing issues title
  ///
  /// In en, this message translates to:
  /// **'Business licensing issues'**
  String get businessLicensingIssues;

  /// Business licensing restriction for minors
  ///
  /// In en, this message translates to:
  /// **'Some provinces may restrict minors from operating as independent contractors.'**
  String get provincesRestrictMinors;

  /// App-specific work context section title
  ///
  /// In en, this message translates to:
  /// **'Specific Cases for Gig Work (Your App\'s Context)'**
  String get specificCasesGigWork;

  /// Description of services provided
  ///
  /// In en, this message translates to:
  /// **'The App provides services often involve physical labor, handyman work, and home services.'**
  String get servicesInvolvePhysicalLabor;

  /// Explanation of age requirement
  ///
  /// In en, this message translates to:
  /// **'These types of jobs typically require workers to be 18+ because they involve safety risks, contracts, and potential liability issues.'**
  String get jobsRequire18Plus;

  /// Age requirement conclusion section title
  ///
  /// In en, this message translates to:
  /// **'Conclusion: Should Minors Be Allowed on the App?'**
  String get conclusionMinorsAllowed;

  /// Recommendation for age requirement
  ///
  /// In en, this message translates to:
  /// **'It\'s best to require service providers to be at least 18.'**
  String get bestRequire18;

  /// Future considerations for younger users
  ///
  /// In en, this message translates to:
  /// **'If younger users (e.g., babysitting, tutoring) are allowed in the future, parental consent and provincial legal approval may be required. (Contact customer support to send you the consent to be signed.)'**
  String get youngerUsersParentalConsent;

  /// Account registration requirement
  ///
  /// In en, this message translates to:
  /// **'Users must create an account to access the services.'**
  String get usersMustCreateAccount;

  /// User responsibility for account security
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your login credentials.'**
  String get responsibleForCredentials;

  /// Account sharing prohibition
  ///
  /// In en, this message translates to:
  /// **'You must not share your account information with others.'**
  String get notShareAccountInfo;

  /// Security breach reporting requirement
  ///
  /// In en, this message translates to:
  /// **'Any unauthorized access to your account must be reported immediately to customer support.'**
  String get unauthorizedAccess;

  /// Communication channel requirement
  ///
  /// In en, this message translates to:
  /// **'All communication between customers and service providers must occur through the App\'s built-in chat feature.'**
  String get communicationViaApp;

  /// Personal information sharing prohibition
  ///
  /// In en, this message translates to:
  /// **'Users are strictly prohibited from sharing personal contact information (e.g., phone numbers, emails) through the chat.'**
  String get noPersonalContactSharing;

  /// Consequence of rule violation
  ///
  /// In en, this message translates to:
  /// **'Violation of this rule may result in account suspension or termination.'**
  String get violationAccountSuspension;

  /// Payment processing requirement
  ///
  /// In en, this message translates to:
  /// **'All payments must be processed through the App.'**
  String get allPaymentsThroughApp;

  /// External payment prohibition
  ///
  /// In en, this message translates to:
  /// **'No payments outside the App are allowed. Any attempt to process payments outside the platform may result in permanent account suspension.'**
  String get noPaymentsOutside;

  /// Fee transparency policy
  ///
  /// In en, this message translates to:
  /// **'The App may charge service fees or transaction fees, which will be disclosed before payment.'**
  String get serviceFeeDisclosure;

  /// Certification upload policy
  ///
  /// In en, this message translates to:
  /// **'Service providers can upload certifications to enhance their profile credibility, but this is optional.'**
  String get certificationsOptional;

  /// Security verification option
  ///
  /// In en, this message translates to:
  /// **'Service providers may also complete a security check through the App, which will further increase trust.'**
  String get securityCheckAvailable;

  /// Disclaimer about work availability
  ///
  /// In en, this message translates to:
  /// **'The App does not guarantee job assignments or earnings for service providers.'**
  String get noJobGuarantee;

  /// Introduction to advertising terms
  ///
  /// In en, this message translates to:
  /// **'The App allows advertisements from companies and individuals, including service providers who wish to promote their services. By submitting an advertisement, you agree to the following terms:'**
  String get advertisingPolicyIntro;

  /// Advertising eligibility section title
  ///
  /// In en, this message translates to:
  /// **'Eligibility to Advertise'**
  String get eligibilityToAdvertise;

  /// Legal compliance requirement for advertisers
  ///
  /// In en, this message translates to:
  /// **'Advertisers must comply with all applicable laws and regulations.'**
  String get advertisersComplyLaws;

  /// Truthful advertising requirement
  ///
  /// In en, this message translates to:
  /// **'Service providers may advertise their services, but advertisements must not mislead users or contain false claims.'**
  String get serviceProviderAdsNotMislead;

  /// Advertising relevance requirement
  ///
  /// In en, this message translates to:
  /// **'Companies must ensure that their ads are relevant to the platform\'s audience.'**
  String get companiesEnsureRelevantAds;

  /// Advertisement content rules section title
  ///
  /// In en, this message translates to:
  /// **'Ad Content Guidelines'**
  String get adContentGuidelines;

  /// Advertisement accuracy requirement
  ///
  /// In en, this message translates to:
  /// **'Ads must be truthful, accurate, and not misleading.'**
  String get adsTruthfulAccurate;

  /// Advertisement content restrictions
  ///
  /// In en, this message translates to:
  /// **'Ads must not promote illegal activities, violence, discrimination, or explicit content.'**
  String get adsNotPromoteIllegal;

  /// Contact information restriction in ads
  ///
  /// In en, this message translates to:
  /// **'Ads must not include personal contact details (e.g., phone numbers, email addresses) to ensure transactions remain within the App.'**
  String get adsNoPersonalContact;

  /// Advertisement review policy
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to review and reject any advertisement that does not align with these guidelines.'**
  String get appReviewRejectAds;

  /// Advertisement pricing section title
  ///
  /// In en, this message translates to:
  /// **'Ad Placement and Fees'**
  String get adPlacementFees;

  /// Advertisement placement options
  ///
  /// In en, this message translates to:
  /// **'Advertisers may choose from different ad placement options within the App.'**
  String get advertisersChoosePlacement;

  /// Advertisement pricing structure
  ///
  /// In en, this message translates to:
  /// **'Advertising fees vary based on placement, duration, and visibility.'**
  String get advertisingFeesVary;

  /// Advertisement payment requirement
  ///
  /// In en, this message translates to:
  /// **'Payment for advertisements must be processed through the App.'**
  String get adPaymentThroughApp;

  /// Advertisement violation consequences section title
  ///
  /// In en, this message translates to:
  /// **'Ad Removal and Violations'**
  String get adRemovalViolations;

  /// Advertisement removal policy
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to remove ads that violate these policies without notice or refund.'**
  String get appRemoveViolatingAds;

  /// Consequence of repeated violations
  ///
  /// In en, this message translates to:
  /// **'Repeated violations may result in a ban from advertising on the platform.'**
  String get repeatedViolationsBan;

  /// Introduction to prohibited activities list
  ///
  /// In en, this message translates to:
  /// **'Users must not:'**
  String get usersMustNot;

  /// Prohibited activity - misrepresentation
  ///
  /// In en, this message translates to:
  /// **'Misrepresent themselves or their services.'**
  String get misrepresentServices;

  /// Prohibited activity - fraud
  ///
  /// In en, this message translates to:
  /// **'Engage in fraudulent activities.'**
  String get engageFraudulent;

  /// Prohibited activity - law violation
  ///
  /// In en, this message translates to:
  /// **'Violate any local, state, or national laws.'**
  String get violateLocalLaws;

  /// Prohibited activity - illegal use
  ///
  /// In en, this message translates to:
  /// **'Use the App for any illegal or unethical purposes.'**
  String get useAppIllegalPurposes;

  /// Dispute resolution process
  ///
  /// In en, this message translates to:
  /// **'Any disputes between users must be handled through the App\'s customer support team.'**
  String get disputesHandledBySupport;

  /// App responsibility limitation in disputes
  ///
  /// In en, this message translates to:
  /// **'The App is not responsible for any disagreements between customers and service providers but will assist in resolving disputes where possible.'**
  String get appNotResponsibleDisagreements;

  /// Service provider cancellation policies section title
  ///
  /// In en, this message translates to:
  /// **'Service Provider Cancellation'**
  String get serviceProviderCancellation;

  /// Advance cancellation notice requirement
  ///
  /// In en, this message translates to:
  /// **'Service providers must inform the customer and the platform at least 48 hours before the scheduled service if they need to cancel.'**
  String get inform48HoursBefore;

  /// Repeated cancellation consequences section title
  ///
  /// In en, this message translates to:
  /// **'Frequent Cancellations'**
  String get frequentCancellations;

  /// Consequence of frequent cancellations
  ///
  /// In en, this message translates to:
  /// **'Repeated last-minute cancellations or no-shows may result in penalties, lower visibility in search results, or account suspension.'**
  String get repeatedCancellationsPenalties;

  /// Customer compensation section title
  ///
  /// In en, this message translates to:
  /// **'Customer Compensation'**
  String get customerCompensation;

  /// Compensation requirement for provider cancellations
  ///
  /// In en, this message translates to:
  /// **'If a service provider cancels after a customer has already made preparations (e.g., purchasing materials, rearranging schedules), compensation may be required.'**
  String get providerCancelCompensation;

  /// Emergency cancellation section title
  ///
  /// In en, this message translates to:
  /// **'Unavoidable Cancellations'**
  String get unavoidableCancellations;

  /// Emergency cancellation policy
  ///
  /// In en, this message translates to:
  /// **'If a service provider must cancel due to unforeseen circumstances (e.g., health issues, family emergencies), they should notify support immediately to avoid penalties.'**
  String get unforeseeableCircumstances;

  /// Free cancellation period section title
  ///
  /// In en, this message translates to:
  /// **'Free Cancellation Window'**
  String get freeCancellationWindow;

  /// Free cancellation timeframe
  ///
  /// In en, this message translates to:
  /// **'Customers can cancel a booking for free if done at least 48 hours before the scheduled service.'**
  String get customersFreeCancel48Hours;

  /// Late cancellation penalties section title
  ///
  /// In en, this message translates to:
  /// **'Late Cancellations'**
  String get lateCancellations;

  /// Late cancellation fee policy
  ///
  /// In en, this message translates to:
  /// **'If a cancellation is made within 24 hours of the scheduled service, a cancellation fee of 20% of the paid amount may be charged.'**
  String get lateCancellationFee;

  /// No-show policy section title
  ///
  /// In en, this message translates to:
  /// **'No-Shows'**
  String get noShows;

  /// No-show penalty policy
  ///
  /// In en, this message translates to:
  /// **'If the customer fails to be present at the service location without prior cancellation, they may be charged the full service fee.'**
  String get noShowFullCharge;

  /// Refund policy section title
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get refundPolicy;

  /// Refund eligibility explanation
  ///
  /// In en, this message translates to:
  /// **'Refund eligibility depends on the specific service provider\'s policy. In some cases, partial refunds may be issued after deducting applicable fees.'**
  String get refundEligibilityDepends;

  /// Emergency cancellation reporting requirement
  ///
  /// In en, this message translates to:
  /// **'If a service is canceled by either party due to unforeseen circumstances, both the customer and the service provider should report the issue through the App to avoid penalties.'**
  String get reportUnforeseeableCircumstances;

  /// Policy modification notice
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to modify cancellation policies and will notify users of significant changes.'**
  String get appModifyCancellationPolicies;

  /// Account termination policy
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to suspend or terminate any account that violates these terms.'**
  String get appSuspendTerminateViolations;

  /// User account deactivation option
  ///
  /// In en, this message translates to:
  /// **'Users may deactivate their accounts at any time through the App settings.'**
  String get usersDeactivateAccounts;

  /// Platform role disclaimer
  ///
  /// In en, this message translates to:
  /// **'The App acts as a platform to connect customers with service providers but does not guarantee service quality or outcomes.'**
  String get appPlatformConnect;

  /// Liability limitation
  ///
  /// In en, this message translates to:
  /// **'The App is not liable for any damages, losses, or disputes arising from user interactions.'**
  String get appNotLiableUserInteractions;

  /// Terms update policy
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to update these Terms and Conditions at any time. Users will be notified of significant changes.'**
  String get appUpdateTermsAnytime;

  /// Acceptance of updated terms
  ///
  /// In en, this message translates to:
  /// **'Continued use of the App after changes are posted constitutes acceptance of the new terms.'**
  String get continuedUseAcceptance;

  /// Contact information for terms questions
  ///
  /// In en, this message translates to:
  /// **'For questions or concerns regarding these Terms and Conditions, please contact our support team within the App.'**
  String get contactSupportForQuestions;

  /// Final acceptance acknowledgment
  ///
  /// In en, this message translates to:
  /// **'By using Good One, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.'**
  String get acknowledgmentReadUnderstood;

  /// Emergency cancellation section title
  ///
  /// In en, this message translates to:
  /// **'Emergency Cancellations'**
  String get emergencyCancellations;

  /// Emergency cancellation policy description
  ///
  /// In en, this message translates to:
  /// **'If a cancellation is due to an emergency (e.g., medical issues, accidents), the customer must provide proof, and a full refund may be issued at the platform\'s discretion.'**
  String get emergencyCancellationPolicy;

  /// Advance notice requirement section title
  ///
  /// In en, this message translates to:
  /// **'Advance Notice'**
  String get advanceNotice;

  /// Status message while establishing chat connection
  ///
  /// In en, this message translates to:
  /// **'Connecting to chat...'**
  String get connectingToChat;

  /// Status message while retrieving chat messages
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// General status message for establishing connection
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Action prompt to begin chat with specific user
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with'**
  String get startConversationWith;

  /// Error message when chat system cannot start
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize chat'**
  String get failedToInitializeChat;

  /// Status message while setting up chat system
  ///
  /// In en, this message translates to:
  /// **'Initializing chat...'**
  String get initializingChat;

  /// Status message while retrieving chat list
  ///
  /// In en, this message translates to:
  /// **'Loading conversations...'**
  String get loadingConversations;

  /// Placeholder for unidentified user in chat
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Greeting message for new users
  ///
  /// In en, this message translates to:
  /// **'Welcome to our app'**
  String get welcomeToOurApp;

  /// Instruction for choosing user role during registration
  ///
  /// In en, this message translates to:
  /// **'Please select your account type'**
  String get accountTypeSelectionPrompt;

  /// Singular time unit for daily services
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// Pricing model with set cost regardless of time
  ///
  /// In en, this message translates to:
  /// **'Fixed Price'**
  String get fixedPrice;

  /// Greeting message for bookings section
  ///
  /// In en, this message translates to:
  /// **'Welcome to your bookings'**
  String get welcomeToYourBookings;

  /// Message when user has no current reservations
  ///
  /// In en, this message translates to:
  /// **'No active bookings'**
  String get noActiveBookings;

  /// Detailed message explaining empty active bookings list
  ///
  /// In en, this message translates to:
  /// **'You have no active bookings at the moment'**
  String get noActiveBookingsMessage;

  /// Message when user has no finished services
  ///
  /// In en, this message translates to:
  /// **'No completed bookings'**
  String get noCompletedBookings;

  /// Message when user has no cancelled reservations
  ///
  /// In en, this message translates to:
  /// **'You have no canceled bookings'**
  String get noCanceledBookingsMessage;

  /// Short message for empty cancelled bookings list
  ///
  /// In en, this message translates to:
  /// **'No canceled bookings'**
  String get noCanceledBookings;

  /// Call to action encouraging user to make first booking
  ///
  /// In en, this message translates to:
  /// **'Start booking your services now'**
  String get startBookingPrompt;

  /// Friendly error message for unexpected failures
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// Label for service cost structure selection
  ///
  /// In en, this message translates to:
  /// **'Pricing Type'**
  String get pricingType;

  /// Pricing model based on time per hour
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// Pricing model based on full day rate
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Pricing model with set total cost
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// Extra or supplementary charges
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get additional;

  /// Label for extra charges beyond base price
  ///
  /// In en, this message translates to:
  /// **'Additional Cost'**
  String get additionalCostLabel;

  /// Combined label for scheduling information
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// Approximate cost calculation for service
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get estimatedPrice;

  /// Cost structure based on hourly rates
  ///
  /// In en, this message translates to:
  /// **'Hourly Pricing'**
  String get hourlyPricing;

  /// Cost structure based on daily rates
  ///
  /// In en, this message translates to:
  /// **'Daily Pricing'**
  String get dailyPricing;

  /// Cost structure with predetermined total price
  ///
  /// In en, this message translates to:
  /// **'Fixed Pricing'**
  String get fixedPricing;

  /// General cost information or structure
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// Prefix indicating the rate or cost being applied
  ///
  /// In en, this message translates to:
  /// **'Charged at'**
  String get chargedAt;

  /// Instruction to choose duration in hours
  ///
  /// In en, this message translates to:
  /// **'Select hours needed'**
  String get selectHoursNeeded;

  /// Instruction to choose duration in days
  ///
  /// In en, this message translates to:
  /// **'Select days needed'**
  String get selectDaysNeeded;

  /// Prefix for displaying set cost amount
  ///
  /// In en, this message translates to:
  /// **'Fixed price of'**
  String get fixedPriceOf;

  /// Suffix explaining fixed price covers entire job
  ///
  /// In en, this message translates to:
  /// **'for complete service'**
  String get forCompleteService;

  /// Label for cost details section
  ///
  /// In en, this message translates to:
  /// **'Service pricing information'**
  String get servicePricingInformation;

  /// Label for total job cost in fixed pricing model
  ///
  /// In en, this message translates to:
  /// **'Complete service fixed price'**
  String get completeServiceFixedPrice;

  /// Status indicating verification or approval
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Action to remove all search filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Option to view complete list of customer feedback
  ///
  /// In en, this message translates to:
  /// **'All Reviews'**
  String get allReviews;

  /// Customer feedback and ratings section
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Standard sorting arrangement for lists
  ///
  /// In en, this message translates to:
  /// **'Default Order'**
  String get defaultOrder;

  /// Sorting option for best-rated items first
  ///
  /// In en, this message translates to:
  /// **'Highest Rating'**
  String get highestRating;

  /// Sorting option for cheapest items first
  ///
  /// In en, this message translates to:
  /// **'Lowest Price'**
  String get lowestPrice;

  /// Sorting option for most expensive items first
  ///
  /// In en, this message translates to:
  /// **'Highest Price'**
  String get highestPrice;

  /// Sorting option for most frequently chosen items
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// Sorting option prioritizing time-based pricing
  ///
  /// In en, this message translates to:
  /// **'Hourly Services First'**
  String get hourlyServicesFirst;

  /// Sorting option prioritizing day-based pricing
  ///
  /// In en, this message translates to:
  /// **'Daily Services First'**
  String get dailyServicesFirst;

  /// Sorting option prioritizing set-price services
  ///
  /// In en, this message translates to:
  /// **'Fixed Price First'**
  String get fixedPriceFirst;

  /// Label for arranging list items in specific order
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Category of services priced by hour
  ///
  /// In en, this message translates to:
  /// **'Hourly Services'**
  String get hourlyServices;

  /// Category of services priced by day
  ///
  /// In en, this message translates to:
  /// **'Daily Services'**
  String get dailyServices;

  /// Category of services with predetermined total cost
  ///
  /// In en, this message translates to:
  /// **'Fixed Price Services'**
  String get fixedPriceServices;

  /// Action to mark all notifications as viewed
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// Confirmation message that all notifications are now viewed
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// Error message when notification status update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as read'**
  String get failedToMarkAsRead;

  /// Status message while retrieving notification list
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get loadingNotifications;

  /// Error message when notifications cannot be retrieved
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// Generic error message for unidentified failures
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// Message when notification list is empty
  ///
  /// In en, this message translates to:
  /// **'No notifications available'**
  String get noNotificationsMessage;

  /// Action to reload or update current content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Label indicating recently added or unread item
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// Confirmation that notification was successfully viewed
  ///
  /// In en, this message translates to:
  /// **'Notification opened'**
  String get notificationOpened;

  /// Error message when notification cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Error opening notification'**
  String get errorOpeningNotification;

  /// Filter option for lowest acceptable rating score
  ///
  /// In en, this message translates to:
  /// **'Minimum Ratings'**
  String get minimumRatings;

  /// Customer evaluation scores for services
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// Options to refine and arrange search results
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterAndSort;

  /// Filter option for minimum and maximum cost
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// Action to modify service information
  ///
  /// In en, this message translates to:
  /// **'Edit/Update Service Details'**
  String get editUpdateServiceDetails;

  /// Setting controlling whether service is shown to customers
  ///
  /// In en, this message translates to:
  /// **'Service Visibility'**
  String get serviceVisibility;

  /// Status indicating service is available for booking
  ///
  /// In en, this message translates to:
  /// **'Service is active'**
  String get serviceIsActive;

  /// Status indicating service is not available for booking
  ///
  /// In en, this message translates to:
  /// **'Service is inactive'**
  String get serviceIsInactive;

  /// Explanation that service is publicly visible and bookable
  ///
  /// In en, this message translates to:
  /// **'Customers can see and book this service'**
  String get customersCanSeeAndBook;

  /// Explanation that service is not visible to potential clients
  ///
  /// In en, this message translates to:
  /// **'Service is hidden from customers'**
  String get serviceHiddenFromCustomers;

  /// Warning that modifications have not been saved
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Comprehensive information about specific service
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// Professional qualification or credential document
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// Action to add professional credential document
  ///
  /// In en, this message translates to:
  /// **'Upload Certificate'**
  String get uploadCertificate;

  /// Action to establish hourly rate for service
  ///
  /// In en, this message translates to:
  /// **'Set Price Per Hour'**
  String get setPricePerHour;

  /// Cost charged per full day of service
  ///
  /// In en, this message translates to:
  /// **'Daily Rate'**
  String get dailyRate;

  /// Action to establish daily rate for service
  ///
  /// In en, this message translates to:
  /// **'Set Price Per Day'**
  String get setPricePerDay;

  /// Fixed cost for single completion of specific task
  ///
  /// In en, this message translates to:
  /// **'One-time Service Price'**
  String get oneTimeServicePrice;

  /// Collection of photos showcasing work quality
  ///
  /// In en, this message translates to:
  /// **'Service Gallery'**
  String get serviceGallery;

  /// Message when photo gallery is empty
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get noImagesYet;

  /// Instruction to upload images demonstrating service quality
  ///
  /// In en, this message translates to:
  /// **'Add photos to showcase your work'**
  String get addPhotosToShowcase;

  /// Error message when content cannot be retrieved
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// Status message while saving changes
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// Error message when changes cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// Confirmation that service changes were saved
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get serviceUpdatedSuccessfully;

  /// Action to include professional credential
  ///
  /// In en, this message translates to:
  /// **'Add Certificate'**
  String get addCertificate;

  /// Action to include image in gallery
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Option to capture new photo with device camera
  ///
  /// In en, this message translates to:
  /// **'Use Your Camera'**
  String get useYourCamera;

  /// Option to choose existing photo from device storage
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// Action to retry failed operation
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Message when service provider has no customer requests
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// Explanation of where service requests will be displayed
  ///
  /// In en, this message translates to:
  /// **'Orders from customers will appear here'**
  String get ordersFromCustomersWillAppear;

  /// Short message for empty orders list
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get noOrders;

  /// Message when no services are planned for specific date
  ///
  /// In en, this message translates to:
  /// **'No orders scheduled for'**
  String get noOrdersScheduledFor;

  /// Daily rate charge for service
  ///
  /// In en, this message translates to:
  /// **'Cost per day'**
  String get costPerDay;

  /// Category or classification of work offered
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceType;

  /// Service category with predetermined total cost
  ///
  /// In en, this message translates to:
  /// **'Fixed Price Service'**
  String get fixedPriceService;

  /// Predetermined cost that doesn't change with time
  ///
  /// In en, this message translates to:
  /// **'Fixed Rate'**
  String get fixedRate;

  /// Status message while setting up new service or content
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// Setting indicating service can be seen and booked by clients
  ///
  /// In en, this message translates to:
  /// **'Service visible to customers'**
  String get serviceVisibleToCustomers;

  /// Information that settings can be modified later
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime after creating the service'**
  String get canChangeAnytimeAfterCreating;

  /// Encouragement for new service providers to add their first offering
  ///
  /// In en, this message translates to:
  /// **'Create your first service to get started'**
  String get createFirstServicePrompt;

  /// Status indicating service or account is currently operational
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Explanation of free cancellation policy
  ///
  /// In en, this message translates to:
  /// **'Customers can cancel a booking for free if done at least 48 hours before the scheduled service.'**
  String get freeCancellationDescription;

  /// Explanation of late cancellation fee
  ///
  /// In en, this message translates to:
  /// **'If a cancellation is made within 24 hours of the scheduled service, a cancellation fee of 20% of the paid amount may be charged.'**
  String get lateCancellationDescription;

  /// Explanation of no-show penalty
  ///
  /// In en, this message translates to:
  /// **'If the customer fails to be present at the service location without prior cancellation, they may be charged the full service fee.'**
  String get noShowDescription;

  /// Explanation of refund eligibility
  ///
  /// In en, this message translates to:
  /// **'Refund eligibility depends on the specific service provider\'s policy. In some cases, partial refunds may be issued after deducting applicable fees.'**
  String get refundPolicyDescription;

  /// Explanation of emergency cancellation policy
  ///
  /// In en, this message translates to:
  /// **'If a cancellation is due to an emergency (e.g., medical issues, accidents), the customer must provide proof, and a full refund may be issued at the platform\'s discretion.'**
  String get emergencyCancellationDescription;

  /// Explanation of advance notice requirement
  ///
  /// In en, this message translates to:
  /// **'Service providers must inform the customer and the platform at least 48 hours before the scheduled service if they need to cancel.'**
  String get advanceNoticeDescription;

  /// Explanation of frequent cancellation penalties
  ///
  /// In en, this message translates to:
  /// **'Repeated last-minute cancellations or no-shows may result in penalties, lower visibility in search results, or account suspension.'**
  String get frequentCancellationDescription;

  /// Explanation of customer compensation policy
  ///
  /// In en, this message translates to:
  /// **'If a service provider cancels after a customer has already made preparations (e.g., purchasing materials, rearranging schedules), compensation may be required.'**
  String get customerCompensationDescription;

  /// Explanation of unavoidable cancellation policy
  ///
  /// In en, this message translates to:
  /// **'If a service provider must cancel due to unforeseen circumstances (e.g., health issues, family emergencies), they should notify support immediately to avoid penalties.'**
  String get unavoidableCancellationDescription;

  /// First general rule about reporting cancellations
  ///
  /// In en, this message translates to:
  /// **'If a service is canceled by either party due to unforeseen circumstances, both the customer and the service provider should report the issue through the App to avoid penalties.'**
  String get generalRulesDescription1;

  /// Second general rule about policy modifications
  ///
  /// In en, this message translates to:
  /// **'The App reserves the right to modify cancellation policies and will notify users of significant changes.'**
  String get generalRulesDescription2;

  /// Title for personal data collection section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Explanation of personal information collected by the app
  ///
  /// In en, this message translates to:
  /// **'We collect information such as your name, email address, and phone number when you use our app.'**
  String get personalInformationDescription;

  /// Title for location data collection section
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// Explanation of location data collection and usage
  ///
  /// In en, this message translates to:
  /// **'If location services are enabled, we collect geographic data to enhance your user experience.'**
  String get locationInformationDescription;

  /// Title for device data collection section
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// Explanation of device information collected
  ///
  /// In en, this message translates to:
  /// **'We collect details like device type, operating system, and IP address.'**
  String get deviceInformationDescription;

  /// Title for usage analytics collection section
  ///
  /// In en, this message translates to:
  /// **'Usage Data'**
  String get usageData;

  /// Explanation of usage data collection and purpose
  ///
  /// In en, this message translates to:
  /// **'We gather data on how you interact with the app to improve our services.'**
  String get usageDataDescription;

  /// Title for data usage in service enhancement
  ///
  /// In en, this message translates to:
  /// **'Service Improvement'**
  String get serviceImprovement;

  /// Explanation of how data is used for service improvement
  ///
  /// In en, this message translates to:
  /// **'We use your data to enhance and personalize app services.'**
  String get serviceImprovementDescription;

  /// Title for notification data usage section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsUsage;

  /// Explanation of notification system data usage
  ///
  /// In en, this message translates to:
  /// **'We send notifications and service-related alerts to keep you informed.'**
  String get notificationsUsageDescription;

  /// Title for communication data usage section
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communicationUsage;

  /// Explanation of data usage for customer communication
  ///
  /// In en, this message translates to:
  /// **'We use your data to process requests and communicate with you.'**
  String get communicationUsageDescription;

  /// Title for legal compliance data usage section
  ///
  /// In en, this message translates to:
  /// **'Legal Compliance'**
  String get legalCompliance;

  /// Explanation of data usage for legal compliance purposes
  ///
  /// In en, this message translates to:
  /// **'We ensure compliance with legal and regulatory requirements.'**
  String get legalComplianceDescription;

  /// Title for third-party service provider data sharing section
  ///
  /// In en, this message translates to:
  /// **'Service Providers'**
  String get serviceProviders;

  /// Explanation of data sharing with business partners
  ///
  /// In en, this message translates to:
  /// **'We may share your data with payment processors, analytics providers, and technical support companies.'**
  String get serviceProvidersDescription;

  /// Title for legal compliance data sharing section
  ///
  /// In en, this message translates to:
  /// **'Legal Compliance'**
  String get legalComplianceSharing;

  /// Explanation of data sharing for legal reasons
  ///
  /// In en, this message translates to:
  /// **'We may share data if required by law or to protect our rights.'**
  String get legalComplianceSharingDescription;

  /// Title for advertising partner data sharing section
  ///
  /// In en, this message translates to:
  /// **'Advertising Partners'**
  String get advertisingPartners;

  /// Explanation of optional data sharing for marketing
  ///
  /// In en, this message translates to:
  /// **'With your consent, we may share some data for marketing purposes.'**
  String get advertisingPartnersDescription;

  /// Title for user right to modify personal data
  ///
  /// In en, this message translates to:
  /// **'Modifying Data'**
  String get modifyingData;

  /// Explanation of user's right to modify their data
  ///
  /// In en, this message translates to:
  /// **'You may update or correct your personal data through the app.'**
  String get modifyingDataDescription;

  /// Title for user right to request data deletion
  ///
  /// In en, this message translates to:
  /// **'Requesting Deletion'**
  String get requestingDeletion;

  /// Explanation of user's right to delete their data with legal exceptions
  ///
  /// In en, this message translates to:
  /// **'You may request the deletion of your data, unless we are legally required to retain it.'**
  String get requestingDeletionDescription;

  /// Explanation of security measures and limitations for data protection
  ///
  /// In en, this message translates to:
  /// **'We implement security measures to protect your data from unauthorized access, alteration, or loss. However, absolute security over the internet cannot be guaranteed.'**
  String get dataProtectionDescription;

  /// Explanation of how privacy policy changes will be communicated
  ///
  /// In en, this message translates to:
  /// **'We may update this policy from time to time. You will be notified of significant changes through in-app notifications or via email.'**
  String get policyChangesDescription;

  /// Contact information and agreement acknowledgment for privacy policy
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, you can contact us via email or phone. By using the app, you agree to the terms of this Privacy Policy.'**
  String get contactUsDescription;

  /// Success message displayed when user profile information is updated successfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Label indicating the total amount of money the user has earned overall
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// Label indicating values related to the current month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Header title summarizing the user's account balance
  ///
  /// In en, this message translates to:
  /// **'Balance Summary'**
  String get balanceSummary;

  /// Label indicating the amount of money currently available for withdrawal or use
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Label indicating the total amount of money that has been withdrawn by the user
  ///
  /// In en, this message translates to:
  /// **'Total Withdrawn'**
  String get totalWithdrawn;

  /// Label for selecting the type of account
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// Label representing a user who is seeking services
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// Label representing a user who is offering services
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// Short description explaining the role of a client
  ///
  /// In en, this message translates to:
  /// **'Looking for services'**
  String get clientDescription;

  /// Short description explaining the role of a provider
  ///
  /// In en, this message translates to:
  /// **'Offering services'**
  String get providerDescription;

  /// Instructional message prompting the user to choose an account type
  ///
  /// In en, this message translates to:
  /// **'Please select an account type'**
  String get pleaseSelectAccountType;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
