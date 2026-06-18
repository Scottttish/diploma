// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ASAR';

  @override
  String get appSubtitle => 'Field Operations Platform';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle =>
      'Enter your credentials to access the field operations dashboard.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signInButton => 'SIGN IN';

  @override
  String get validationEnterEmail => 'Enter your email';

  @override
  String get validationValidEmail => 'Enter a valid email';

  @override
  String get validationEnterPassword => 'Enter your password';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String activeTasks(int count) {
    return '$count Active';
  }

  @override
  String criticalTasks(int count) {
    return '$count Critical';
  }

  @override
  String get todaysRoute => 'Today\'s Route';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get callDispatch => 'Call Dispatch';

  @override
  String get noJobsToday => 'No jobs scheduled for today.';

  @override
  String get workOrderTitle => 'Work Order';

  @override
  String get tabDetails => 'DETAILS';

  @override
  String get tabChat => 'CHAT';

  @override
  String get tabActivity => 'ACTIVITY';

  @override
  String get sectionOverview => 'OVERVIEW';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldPriority => 'Priority';

  @override
  String get fieldServiceType => 'Service Type';

  @override
  String get fieldClient => 'Client';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get sectionSlaDeadline => 'SLA DEADLINE';

  @override
  String get fieldDeadline => 'Deadline';

  @override
  String get sectionDescription => 'PROBLEM DESCRIPTION';

  @override
  String get sectionLocation => 'LOCATION';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldCoordinates => 'Coordinates';

  @override
  String get sectionTimeline => 'TIMELINE';

  @override
  String get workEvidence => 'WORK EVIDENCE';

  @override
  String get acceptJob => 'ACCEPT JOB';

  @override
  String get navigate => 'Navigate';

  @override
  String get complete => 'COMPLETE';

  @override
  String get completedStatus => 'COMPLETED';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get saving => 'Saving…';

  @override
  String get photoRequired => 'At least one verification photo is required.';

  @override
  String maxPhotos(int count) {
    return 'Maximum $count photos allowed.';
  }

  @override
  String get retry => 'Retry';

  @override
  String get eventCreated => 'Work order created';

  @override
  String get eventAssigned => 'Task assigned to you';

  @override
  String get eventAccepted => 'Job accepted';

  @override
  String get eventStarted => 'Work started';

  @override
  String get eventCompleted => 'Job completed';

  @override
  String get settings => 'Settings';

  @override
  String get workerBadge => 'WORKER';

  @override
  String get defaultWorkerName => 'Field Worker';

  @override
  String get sectionAccount => 'Account';

  @override
  String get changePassword => 'Change Password';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get sectionAbout => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyText =>
      'ASAR Field Operations Platform collects location data and task completion records solely for operational purposes. Data is stored securely and is not shared with third parties. Workers\' personal information is accessible only to authorized managers.';

  @override
  String get sectionSupport => 'Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get sectionSession => 'Session';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmContent => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get validationCurrentPassword => 'Enter current password';

  @override
  String get validationNewPassword => 'Enter new password';

  @override
  String get validationMinChars => 'At least 8 characters';

  @override
  String get changePasswordError =>
      'Failed to change password. Check current password.';

  @override
  String get close => 'Close';

  @override
  String get myPerformance => 'My Performance';

  @override
  String get jobsThisMonth => 'Jobs This Month';

  @override
  String get completedToday => 'Completed Today';

  @override
  String get avgCompletion => 'Avg Completion';

  @override
  String get slaCompliance => 'SLA Compliance';

  @override
  String get weeklyProductivity => 'Weekly Productivity';

  @override
  String get weeklyProductivitySub => 'Jobs completed — last 7 days';

  @override
  String get performanceScore => 'Performance Score';

  @override
  String get performanceScoreSub => 'Based on SLA compliance and job volume';

  @override
  String get viewCompletedJobs => 'View Completed Jobs';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navRoute => 'Route';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get locating => 'Locating…';

  @override
  String get myLocation => 'My Location';

  @override
  String get loadingRoute => 'Loading route…';

  @override
  String get noTasksWithLocation => 'No tasks with location data for today.';

  @override
  String estTravelTime(String time) {
    return 'Est. travel time: $time';
  }

  @override
  String get openIn => 'OPEN IN';

  @override
  String get go => 'Go';

  @override
  String get openNavigationIn => 'Open navigation in…';

  @override
  String get supportChatTitle => 'Support';

  @override
  String get supportChatSubtitle => 'Dispatcher';

  @override
  String get supportChatHint => 'Message dispatcher…';

  @override
  String get supportChatEmpty =>
      'No messages yet.\nSend a message and the dispatcher will reply shortly.';
}
