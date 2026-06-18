// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'АСАР';

  @override
  String get appSubtitle => 'Платформа полевых операций';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle =>
      'Введите учётные данные для доступа к панели полевых работ.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String get signInButton => 'ВОЙТИ';

  @override
  String get validationEnterEmail => 'Введите email';

  @override
  String get validationValidEmail => 'Введите корректный email';

  @override
  String get validationEnterPassword => 'Введите пароль';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String activeTasks(int count) {
    return '$count активных';
  }

  @override
  String criticalTasks(int count) {
    return '$count критических';
  }

  @override
  String get todaysRoute => 'Маршрут на сегодня';

  @override
  String get uploadPhoto => 'Загрузить фото';

  @override
  String get callDispatch => 'Позвонить диспетчеру';

  @override
  String get noJobsToday => 'На сегодня задач нет.';

  @override
  String get workOrderTitle => 'Наряд';

  @override
  String get tabDetails => 'ДЕТАЛИ';

  @override
  String get tabChat => 'ЧАТ';

  @override
  String get tabActivity => 'АКТИВНОСТЬ';

  @override
  String get sectionOverview => 'ОБЗОР';

  @override
  String get fieldStatus => 'Статус';

  @override
  String get fieldPriority => 'Приоритет';

  @override
  String get fieldServiceType => 'Тип услуги';

  @override
  String get fieldClient => 'Клиент';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get sectionSlaDeadline => 'СРОК SLA';

  @override
  String get fieldDeadline => 'Срок';

  @override
  String get sectionDescription => 'ОПИСАНИЕ ПРОБЛЕМЫ';

  @override
  String get sectionLocation => 'МЕСТОПОЛОЖЕНИЕ';

  @override
  String get fieldAddress => 'Адрес';

  @override
  String get fieldCoordinates => 'Координаты';

  @override
  String get sectionTimeline => 'ХРОНОЛОГИЯ';

  @override
  String get workEvidence => 'ДОКАЗАТЕЛЬСТВА РАБОТЫ';

  @override
  String get acceptJob => 'ПРИНЯТЬ ЗАДАЧУ';

  @override
  String get navigate => 'Навигация';

  @override
  String get complete => 'ЗАВЕРШИТЬ';

  @override
  String get completedStatus => 'ВЫПОЛНЕНО';

  @override
  String get pleaseWait => 'Подождите…';

  @override
  String get saving => 'Сохранение…';

  @override
  String get photoRequired => 'Необходимо прикрепить хотя бы одно фото.';

  @override
  String maxPhotos(int count) {
    return 'Максимум $count фото.';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get eventCreated => 'Наряд создан';

  @override
  String get eventAssigned => 'Задача назначена вам';

  @override
  String get eventAccepted => 'Работа принята';

  @override
  String get eventStarted => 'Работа начата';

  @override
  String get eventCompleted => 'Работа завершена';

  @override
  String get settings => 'Настройки';

  @override
  String get workerBadge => 'РАБОТНИК';

  @override
  String get defaultWorkerName => 'Полевой работник';

  @override
  String get sectionAccount => 'Аккаунт';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get sectionAppearance => 'Внешний вид';

  @override
  String get language => 'Язык';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get sectionAbout => 'О приложении';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicyText =>
      'Платформа АСАР для полевых работ собирает данные о местоположении и записи о выполнении задач исключительно в операционных целях. Данные хранятся в безопасности и не передаются третьим лицам. Личная информация работников доступна только авторизованным менеджерам.';

  @override
  String get sectionSupport => 'Поддержка';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get sectionSession => 'Сессия';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirmTitle => 'Выйти';

  @override
  String get signOutConfirmContent => 'Вы уверены, что хотите выйти?';

  @override
  String get cancel => 'Отмена';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get updatePassword => 'Обновить пароль';

  @override
  String get validationCurrentPassword => 'Введите текущий пароль';

  @override
  String get validationNewPassword => 'Введите новый пароль';

  @override
  String get validationMinChars => 'Минимум 8 символов';

  @override
  String get changePasswordError =>
      'Не удалось изменить пароль. Проверьте текущий пароль.';

  @override
  String get close => 'Закрыть';

  @override
  String get myPerformance => 'Моя эффективность';

  @override
  String get jobsThisMonth => 'Заданий за месяц';

  @override
  String get completedToday => 'Выполнено сегодня';

  @override
  String get avgCompletion => 'Среднее время';

  @override
  String get slaCompliance => 'Соблюдение SLA';

  @override
  String get weeklyProductivity => 'Еженедельная продуктивность';

  @override
  String get weeklyProductivitySub => 'Выполненные задания — последние 7 дней';

  @override
  String get performanceScore => 'Оценка эффективности';

  @override
  String get performanceScoreSub => 'На основе соблюдения SLA и объёма работ';

  @override
  String get viewCompletedJobs => 'Просмотр выполненных заданий';

  @override
  String get navSchedule => 'Расписание';

  @override
  String get navRoute => 'Маршрут';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get locating => 'Определение…';

  @override
  String get myLocation => 'Моё место';

  @override
  String get loadingRoute => 'Маршрут…';

  @override
  String get noTasksWithLocation =>
      'Нет задач с данными о местоположении на сегодня.';

  @override
  String estTravelTime(String time) {
    return 'Расчётное время: $time';
  }

  @override
  String get openIn => 'ОТКРЫТЬ В';

  @override
  String get go => 'Ехать';

  @override
  String get openNavigationIn => 'Открыть навигацию в…';

  @override
  String get supportChatTitle => 'Поддержка';

  @override
  String get supportChatSubtitle => 'Диспетчер';

  @override
  String get supportChatHint => 'Написать диспетчеру…';

  @override
  String get supportChatEmpty =>
      'Сообщений нет.\nОтправьте сообщение — диспетчер скоро ответит.';
}
