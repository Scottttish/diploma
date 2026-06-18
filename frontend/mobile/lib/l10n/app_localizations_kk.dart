// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'АСАР';

  @override
  String get appSubtitle => 'Далалық операциялар платформасы';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginSubtitle =>
      'Далалық жұмыс панеліне кіру үшін деректеріңізді енгізіңіз.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Құпия сөз';

  @override
  String get rememberMe => 'Мені есте сақта';

  @override
  String get signInButton => 'КІРУ';

  @override
  String get validationEnterEmail => 'Email енгізіңіз';

  @override
  String get validationValidEmail => 'Жарамды email енгізіңіз';

  @override
  String get validationEnterPassword => 'Құпия сөзді енгізіңіз';

  @override
  String get greetingMorning => 'Қайырлы таң';

  @override
  String get greetingAfternoon => 'Қайырлы күн';

  @override
  String get greetingEvening => 'Қайырлы кеш';

  @override
  String activeTasks(int count) {
    return '$count белсенді';
  }

  @override
  String criticalTasks(int count) {
    return '$count маңызды';
  }

  @override
  String get todaysRoute => 'Бүгінгі бағыт';

  @override
  String get uploadPhoto => 'Фото жүктеу';

  @override
  String get callDispatch => 'Диспетчерге қоңырау';

  @override
  String get noJobsToday => 'Бүгін тапсырма жоқ.';

  @override
  String get workOrderTitle => 'Тапсырыс';

  @override
  String get tabDetails => 'МӘЛІМЕТТЕР';

  @override
  String get tabChat => 'ЧАТ';

  @override
  String get tabActivity => 'БЕЛСЕНДІЛІК';

  @override
  String get sectionOverview => 'ШОЛУ';

  @override
  String get fieldStatus => 'Күй';

  @override
  String get fieldPriority => 'Басымдылық';

  @override
  String get fieldServiceType => 'Қызмет түрі';

  @override
  String get fieldClient => 'Клиент';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get sectionSlaDeadline => 'SLA МЕРЗІМІ';

  @override
  String get fieldDeadline => 'Мерзім';

  @override
  String get sectionDescription => 'МӘСЕЛЕ СИПАТТАМАСЫ';

  @override
  String get sectionLocation => 'ОРНАЛАСУЫ';

  @override
  String get fieldAddress => 'Мекенжай';

  @override
  String get fieldCoordinates => 'Координаттар';

  @override
  String get sectionTimeline => 'ХРОНОЛОГИЯ';

  @override
  String get workEvidence => 'ЖҰМЫС ДӘЛЕЛДЕРІ';

  @override
  String get acceptJob => 'ТАПСЫРМАНЫ ҚАБЫЛДАУ';

  @override
  String get navigate => 'Навигация';

  @override
  String get complete => 'АЯҚТАУ';

  @override
  String get completedStatus => 'ОРЫНДАЛДЫ';

  @override
  String get pleaseWait => 'Күте тұрыңыз…';

  @override
  String get saving => 'Сақталуда…';

  @override
  String get photoRequired => 'Кем дегенде бір растау фотосы қажет.';

  @override
  String maxPhotos(int count) {
    return 'Максимум $count фото.';
  }

  @override
  String get retry => 'Қайталау';

  @override
  String get eventCreated => 'Тапсырыс жасалды';

  @override
  String get eventAssigned => 'Тапсырма сізге тағайындалды';

  @override
  String get eventAccepted => 'Жұмыс қабылданды';

  @override
  String get eventStarted => 'Жұмыс басталды';

  @override
  String get eventCompleted => 'Жұмыс аяқталды';

  @override
  String get settings => 'Параметрлер';

  @override
  String get workerBadge => 'ЖҰМЫСШЫ';

  @override
  String get defaultWorkerName => 'Далалық жұмысшы';

  @override
  String get sectionAccount => 'Аккаунт';

  @override
  String get changePassword => 'Құпия сөзді өзгерту';

  @override
  String get sectionAppearance => 'Сыртқы көрініс';

  @override
  String get language => 'Тіл';

  @override
  String get darkMode => 'Қараңғы тақырып';

  @override
  String get sectionAbout => 'Бағдарлама туралы';

  @override
  String get appVersion => 'Бағдарлама нұсқасы';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get privacyPolicyText =>
      'АСАР далалық операциялар платформасы орналасу деректерін және тапсырмаларды орындау жазбаларын тек операциялық мақсаттарда жинайды. Деректер қауіпсіз сақталады және үшінші тараптармен бөлісілмейді. Жұмысшылардың жеке ақпаратына тек уәкілетті менеджерлер қол жеткізе алады.';

  @override
  String get sectionSupport => 'Қолдау';

  @override
  String get contactSupport => 'Қолдаумен байланысу';

  @override
  String get sectionSession => 'Сессия';

  @override
  String get signOut => 'Шығу';

  @override
  String get signOutConfirmTitle => 'Шығу';

  @override
  String get signOutConfirmContent => 'Сіз шыққыңыз келетініне сенімдісіз бе?';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get currentPassword => 'Ағымдағы құпия сөз';

  @override
  String get newPassword => 'Жаңа құпия сөз';

  @override
  String get updatePassword => 'Құпия сөзді жаңарту';

  @override
  String get validationCurrentPassword => 'Ағымдағы құпия сөзді енгізіңіз';

  @override
  String get validationNewPassword => 'Жаңа құпия сөзді енгізіңіз';

  @override
  String get validationMinChars => 'Кем дегенде 8 таңба';

  @override
  String get changePasswordError =>
      'Құпия сөзді өзгерту мүмкін болмады. Ағымдағы құпия сөзді тексеріңіз.';

  @override
  String get close => 'Жабу';

  @override
  String get myPerformance => 'Менің тиімділігім';

  @override
  String get jobsThisMonth => 'Ай бойы тапсырмалар';

  @override
  String get completedToday => 'Бүгін орындалды';

  @override
  String get avgCompletion => 'Орташа орындалу';

  @override
  String get slaCompliance => 'SLA сәйкестігі';

  @override
  String get weeklyProductivity => 'Апталық өнімділік';

  @override
  String get weeklyProductivitySub => 'Орындалған тапсырмалар — соңғы 7 күн';

  @override
  String get performanceScore => 'Тиімділік бағасы';

  @override
  String get performanceScoreSub =>
      'SLA сәйкестігі мен жұмыс көлеміне негізделген';

  @override
  String get viewCompletedJobs => 'Орындалған тапсырмаларды көру';

  @override
  String get navSchedule => 'Кесте';

  @override
  String get navRoute => 'Бағыт';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navSettings => 'Параметрлер';

  @override
  String get locating => 'Орын анықталуда…';

  @override
  String get myLocation => 'Менің орным';

  @override
  String get loadingRoute => 'Бағыт жүктелуде…';

  @override
  String get noTasksWithLocation =>
      'Бүгін орналасу деректері бар тапсырмалар жоқ.';

  @override
  String estTravelTime(String time) {
    return 'Болжамды уақыт: $time';
  }

  @override
  String get openIn => 'АШУ';

  @override
  String get go => 'Бару';

  @override
  String get openNavigationIn => 'Навигацияны ашу…';

  @override
  String get supportChatTitle => 'Қолдау';

  @override
  String get supportChatSubtitle => 'Диспетчер';

  @override
  String get supportChatHint => 'Диспетчерге хабар жазу…';

  @override
  String get supportChatEmpty =>
      'Хабарлар жоқ.\nХабар жіберіңіз — диспетчер жақында жауап береді.';
}
