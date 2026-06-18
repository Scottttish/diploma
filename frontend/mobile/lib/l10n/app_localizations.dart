import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ASAR'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Field Operations Platform'**
  String get appSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access the field operations dashboard.'**
  String get loginSubtitle;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signInButton;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get validationEnterEmail;

  /// No description provided for @validationValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationValidEmail;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validationEnterPassword;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeTasks(int count);

  /// No description provided for @criticalTasks.
  ///
  /// In en, this message translates to:
  /// **'{count} Critical'**
  String criticalTasks(int count);

  /// No description provided for @todaysRoute.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Route'**
  String get todaysRoute;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @callDispatch.
  ///
  /// In en, this message translates to:
  /// **'Call Dispatch'**
  String get callDispatch;

  /// No description provided for @noJobsToday.
  ///
  /// In en, this message translates to:
  /// **'No jobs scheduled for today.'**
  String get noJobsToday;

  /// No description provided for @workOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Order'**
  String get workOrderTitle;

  /// No description provided for @tabDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get tabDetails;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'CHAT'**
  String get tabChat;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get tabActivity;

  /// No description provided for @sectionOverview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get sectionOverview;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @fieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get fieldPriority;

  /// No description provided for @fieldServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get fieldServiceType;

  /// No description provided for @fieldClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get fieldClient;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @sectionSlaDeadline.
  ///
  /// In en, this message translates to:
  /// **'SLA DEADLINE'**
  String get sectionSlaDeadline;

  /// No description provided for @fieldDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get fieldDeadline;

  /// No description provided for @sectionDescription.
  ///
  /// In en, this message translates to:
  /// **'PROBLEM DESCRIPTION'**
  String get sectionDescription;

  /// No description provided for @sectionLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get sectionLocation;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get fieldCoordinates;

  /// No description provided for @sectionTimeline.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE'**
  String get sectionTimeline;

  /// No description provided for @workEvidence.
  ///
  /// In en, this message translates to:
  /// **'WORK EVIDENCE'**
  String get workEvidence;

  /// No description provided for @acceptJob.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT JOB'**
  String get acceptJob;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get complete;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedStatus;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @photoRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one verification photo is required.'**
  String get photoRequired;

  /// No description provided for @maxPhotos.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} photos allowed.'**
  String maxPhotos(int count);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Work order created'**
  String get eventCreated;

  /// No description provided for @eventAssigned.
  ///
  /// In en, this message translates to:
  /// **'Task assigned to you'**
  String get eventAssigned;

  /// No description provided for @eventAccepted.
  ///
  /// In en, this message translates to:
  /// **'Job accepted'**
  String get eventAccepted;

  /// No description provided for @eventStarted.
  ///
  /// In en, this message translates to:
  /// **'Work started'**
  String get eventStarted;

  /// No description provided for @eventCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job completed'**
  String get eventCompleted;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @workerBadge.
  ///
  /// In en, this message translates to:
  /// **'WORKER'**
  String get workerBadge;

  /// No description provided for @defaultWorkerName.
  ///
  /// In en, this message translates to:
  /// **'Field Worker'**
  String get defaultWorkerName;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'ASAR Field Operations Platform collects location data and task completion records solely for operational purposes. Data is stored securely and is not shared with third parties. Workers\' personal information is accessible only to authorized managers.'**
  String get privacyPolicyText;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @sectionSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sectionSession;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @validationCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get validationCurrentPassword;

  /// No description provided for @validationNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get validationNewPassword;

  /// No description provided for @validationMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get validationMinChars;

  /// No description provided for @changePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password. Check current password.'**
  String get changePasswordError;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @myPerformance.
  ///
  /// In en, this message translates to:
  /// **'My Performance'**
  String get myPerformance;

  /// No description provided for @jobsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Jobs This Month'**
  String get jobsThisMonth;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get completedToday;

  /// No description provided for @avgCompletion.
  ///
  /// In en, this message translates to:
  /// **'Avg Completion'**
  String get avgCompletion;

  /// No description provided for @slaCompliance.
  ///
  /// In en, this message translates to:
  /// **'SLA Compliance'**
  String get slaCompliance;

  /// No description provided for @weeklyProductivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Productivity'**
  String get weeklyProductivity;

  /// No description provided for @weeklyProductivitySub.
  ///
  /// In en, this message translates to:
  /// **'Jobs completed — last 7 days'**
  String get weeklyProductivitySub;

  /// No description provided for @performanceScore.
  ///
  /// In en, this message translates to:
  /// **'Performance Score'**
  String get performanceScore;

  /// No description provided for @performanceScoreSub.
  ///
  /// In en, this message translates to:
  /// **'Based on SLA compliance and job volume'**
  String get performanceScoreSub;

  /// No description provided for @viewCompletedJobs.
  ///
  /// In en, this message translates to:
  /// **'View Completed Jobs'**
  String get viewCompletedJobs;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get navRoute;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locating;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @loadingRoute.
  ///
  /// In en, this message translates to:
  /// **'Loading route…'**
  String get loadingRoute;

  /// No description provided for @noTasksWithLocation.
  ///
  /// In en, this message translates to:
  /// **'No tasks with location data for today.'**
  String get noTasksWithLocation;

  /// No description provided for @estTravelTime.
  ///
  /// In en, this message translates to:
  /// **'Est. travel time: {time}'**
  String estTravelTime(String time);

  /// No description provided for @openIn.
  ///
  /// In en, this message translates to:
  /// **'OPEN IN'**
  String get openIn;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @openNavigationIn.
  ///
  /// In en, this message translates to:
  /// **'Open navigation in…'**
  String get openNavigationIn;

  /// No description provided for @supportChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportChatTitle;

  /// No description provided for @supportChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher'**
  String get supportChatSubtitle;

  /// No description provided for @supportChatHint.
  ///
  /// In en, this message translates to:
  /// **'Message dispatcher…'**
  String get supportChatHint;

  /// No description provided for @supportChatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.\nSend a message and the dispatcher will reply shortly.'**
  String get supportChatEmpty;
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
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
