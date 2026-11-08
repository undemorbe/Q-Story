// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'QStory';

  @override
  String get scanQr => 'Сканировать QR';

  @override
  String get cameraPermissionRequired => 'Для сканирования QR-кодов нужен доступ к камере.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get permissionDenied => 'Доступ запрещён';

  @override
  String get error => 'Ошибка';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get save => 'Сохранить';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get navMap => 'Карта';

  @override
  String get navScanner => 'Сканер';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navProfile => 'Профиль';

  @override
  String get onboarding1Title => 'Открывайте';

  @override
  String get onboarding1Desc =>
      'Исторические места, ретрофото и объекты наследия вокруг вас — из открытых сообществ историков.';

  @override
  String get onboarding2Title => 'Ищите';

  @override
  String get onboarding2Desc => 'Выберите место и дойдите до него. QStory запишет маршрут и шаги до самого прибытия.';

  @override
  String get onboarding3Title => 'Сохраняйте';

  @override
  String get onboarding3Desc =>
      'Сканируйте QR-таблички, собирайте открытия и следите за статистикой — всё хранится только на телефоне.';

  @override
  String get continueButton => 'Дальше';

  @override
  String get beginButton => 'Начать';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get noFavoritesYet => 'Пока нет избранного';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get favorites => 'Избранное';

  @override
  String get dailyHistory => 'История дня';

  @override
  String get dailyHistorySubtitle => 'Откройте историю сегодняшнего дня';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsSubtitle => 'Настройка ежедневных уведомлений';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get sendSupportMessage => 'Отправьте нам сообщение, и мы ответим вам';

  @override
  String get enterMessage => 'Введите сообщение...';

  @override
  String get messageSent => 'Сообщение успешно отправлено';

  @override
  String get send => 'Отправить';

  @override
  String get retry => 'Повторить';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get systemTheme => 'Системная';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Тёмная';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get pushNotificationsSubtitle => 'Ежедневное напоминание о прогулке';

  @override
  String get checkNotification => 'Проверка уведомлений';

  @override
  String get checkNotificationSubtitle => 'Отправить тестовое уведомление';

  @override
  String get preferences => 'Настройки';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия 1.0.0';

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'Английский';

  @override
  String get notifSettingsTitle => 'Уведомления';

  @override
  String get dailyNotificationsTitle => 'Ежедневные уведомления';

  @override
  String get dailyNotificationsDesc => 'Короткое напоминание: настоящий факт «в этот день» или повод прогуляться';

  @override
  String get notificationTime => 'Время уведомления';

  @override
  String get testNotification => 'Тестовое уведомление';

  @override
  String get testNotificationDesc => 'Проверить, как работают уведомления';

  @override
  String get aboutNotificationsTitle => 'Об уведомлениях';

  @override
  String get aboutNotificationsText =>
      'Раз в день в выбранное время QStory напомнит о прогулке. Если есть интернет, напоминания на ближайшие дни содержат настоящее событие «в этот день» из Википедии. Уведомления планируются на устройстве и никуда не отправляются.';

  @override
  String get notificationsEnabledMsg => 'Уведомления включены';

  @override
  String get notificationsDisabledMsg => 'Уведомления выключены';

  @override
  String get testNotificationSent => 'Тестовое уведомление отправлено';

  @override
  String dailyNotificationsActivated(String time) {
    return 'Ежедневные уведомления активированы в $time';
  }

  @override
  String get titleField => 'Название';

  @override
  String get typeField => 'Тип';

  @override
  String get imageUrlField => 'URL изображения';

  @override
  String get coordinatesLabel => 'Координаты';

  @override
  String get fieldRequired => 'Обязательное поле';

  @override
  String get selectDate => 'Выберите дату';

  @override
  String get pickPointTitle => 'Выберите точку';

  @override
  String get tapMapHint => 'Нажмите на карту, чтобы выбрать координаты';

  @override
  String get done => 'Готово';

  @override
  String get confirmAction => 'Подтвердить';

  @override
  String get onThisDayTitle => 'История дня';

  @override
  String get onThisDaySubtitle => 'события дня в истории России';

  @override
  String get anotherFact => 'Другой факт';

  @override
  String get refreshAction => 'Обновить';

  @override
  String get loadingLabel => 'Загрузка…';

  @override
  String get openInWikipedia => 'Открыть в Wikipedia';

  @override
  String get noFactsForToday => 'На этот день нет фактов из истории России или СССР.';

  @override
  String get wikipediaSource => 'Источник: Wikipedia';

  @override
  String wikipediaSourceWithCount(int count) {
    return 'Источник: Wikipedia · доступно фактов: $count';
  }

  @override
  String get locationDisabled => 'Геолокация выключена в настройках устройства';

  @override
  String get locationDenied => 'Доступ к геолокации не предоставлен';

  @override
  String get locationDeniedForever => 'Геолокация запрещена. Включите в настройках приложения';

  @override
  String locationError(String error) {
    return 'Не удалось определить координаты: $error';
  }

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get filterAll => 'Все';

  @override
  String get report => 'Пожаловаться';

  @override
  String get reportTitle => 'Сообщить о проблеме';

  @override
  String get reportCategory => 'Категория';

  @override
  String get reportText => 'Опишите проблему...';

  @override
  String get reportSent => 'Жалоба успешно отправлена';

  @override
  String get reportConfirmTitle => 'Подтвердить жалобу';

  @override
  String reportConfirmMessage(String category) {
    return 'Отправить жалобу по категории: $category?';
  }

  @override
  String get reportCategoryVandalism => 'Вандализм';

  @override
  String get reportCategoryMisinformation => 'Дезинформация';

  @override
  String get reportCategoryOffensive => 'Оскорбительный контент';

  @override
  String get reportCategorySpam => 'Спам';

  @override
  String get reportCategoryCopyright => 'Нарушение авторских прав';

  @override
  String get reportCategoryAdult => 'Взрослый контент';

  @override
  String get reportCategoryHate => 'Разжигание ненависти';

  @override
  String get reportCategoryFraud => 'Мошенничество';

  @override
  String get reportCategoryMalware => 'Вредоносное ПО/угроза';

  @override
  String get reportCategoryPrivacy => 'Нарушение приватности';

  @override
  String get reportCategoryInvalid => 'Неверная информация';

  @override
  String get reportCategoryOther => 'Другое';

  @override
  String get navStats => 'Статистика';

  @override
  String get trackingOn => 'Трекинг включён';

  @override
  String get trackingOff => 'Трекинг выключен';

  @override
  String get startTracking => 'Включить трекинг';

  @override
  String get stopTracking => 'Остановить трекинг';

  @override
  String get followMe => 'Следовать за мной';

  @override
  String stepsToday(Object count) {
    return '$count шагов сегодня';
  }

  @override
  String placesCount(Object count) {
    return 'Мест: $count';
  }

  @override
  String get loadingPlaces => 'Ищем историю вокруг…';

  @override
  String sourcesUnavailable(Object sources) {
    return 'Недоступно: $sources';
  }

  @override
  String get offlineCache => 'Нет сети — показаны сохранённые места';

  @override
  String get searchPlaces => 'Поиск мест';

  @override
  String get searchHere => 'Искать здесь';

  @override
  String get filterVisited => 'Посещённые';

  @override
  String get filterNotVisited => 'Не посещённые';

  @override
  String get visitFilterLabel => 'Статус';

  @override
  String get sourcesLabel => 'Источники';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get resetFilters => 'Сбросить';

  @override
  String get addMyPlace => 'Добавить своё место';

  @override
  String nearPlace(Object title) {
    return 'Вы рядом с «$title»';
  }

  @override
  String get markVisited => 'Я здесь';

  @override
  String get markedVisited => 'Добавлено в ваши открытия';

  @override
  String get visitedBadge => 'Посещено';

  @override
  String huntSearching(Object title) {
    return 'Ищем: $title';
  }

  @override
  String huntLeft(Object distance) {
    return 'Осталось $distance';
  }

  @override
  String get huntGiveUp => 'Сдаться';

  @override
  String get huntFoundTitle => 'Найдено!';

  @override
  String huntFoundBody(Object title, Object steps, Object distance, Object time) {
    return '«$title»: $steps шагов, $distance, $time';
  }

  @override
  String get startHunt => 'Найти это место';

  @override
  String get huntInProgress => 'Поиск идёт';

  @override
  String get huntNeedsLocation => 'Включите геолокацию, чтобы начать поиск';

  @override
  String openSource(Object source) {
    return 'Открыть на $source';
  }

  @override
  String get linksLabel => 'Ссылки';

  @override
  String get authorLabel => 'Автор';

  @override
  String distanceFromYou(Object distance) {
    return '$distance от вас';
  }

  @override
  String get placeQrTitle => 'QR-код этого места';

  @override
  String get placeQrHint => 'Распечатайте и разместите на месте — другие исследователи смогут его отсканировать.';

  @override
  String attribution(Object source, Object license) {
    return 'Данные: $source · $license';
  }

  @override
  String get deletePlace => 'Удалить место';

  @override
  String get detailsLoadError => 'Не удалось загрузить полное описание';

  @override
  String get noDescription => 'Описания пока нет.';

  @override
  String get showOnMap => 'Показать на карте';

  @override
  String get sourceUser => 'Мои места';

  @override
  String get catMonument => 'Памятники';

  @override
  String get catMemorial => 'Мемориалы';

  @override
  String get catBuilding => 'Здания';

  @override
  String get catReligious => 'Храмы';

  @override
  String get catMuseum => 'Музеи';

  @override
  String get catArchaeology => 'Археология';

  @override
  String get catFortification => 'Укрепления';

  @override
  String get catPhoto => 'Ретрофото';

  @override
  String get catArticle => 'Статьи';

  @override
  String get catOther => 'Другое';

  @override
  String get manualInput => 'Ввести код';

  @override
  String get enterQrHint => 'Вставьте ссылку на Википедию, PastVu, OSM…';

  @override
  String get submit => 'Открыть';

  @override
  String get scanHistory => 'Недавние сканы';

  @override
  String get noScansYet => 'Пока ничего не отсканировано';

  @override
  String get qrUnknown => 'Этот код не ведёт к месту';

  @override
  String get qrExternal => 'В коде ссылка';

  @override
  String get openLink => 'Открыть ссылку';

  @override
  String get resolvingPlace => 'Ищем место…';

  @override
  String get placeNotFound => 'Место не найдено';

  @override
  String get scannerHint => 'Наведите на QR-код на табличке или ссылку на Википедию / PastVu / OSM';

  @override
  String get addPlaceTitle => 'Новое место';

  @override
  String get descriptionField => 'Описание';

  @override
  String get yearField => 'Год';

  @override
  String get useMyLocation => 'Моё местоположение';

  @override
  String get placeSaved => 'Место сохранено на устройстве';

  @override
  String get invalidYear => 'Введите корректный год';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsLocalOnly => 'Все данные хранятся только на этом устройстве';

  @override
  String get statsEstimated => 'Нет датчика шагов — шаги оцениваются по расстоянию';

  @override
  String get statsToday => 'Сегодня';

  @override
  String statsGoal(Object percent, Object goal) {
    return '$percent% дневной цели ($goal)';
  }

  @override
  String get statsMovement => 'Движение';

  @override
  String get statsSteps => 'Шаги';

  @override
  String get statsDistance => 'Расстояние';

  @override
  String get statsActiveTime => 'Время в движении';

  @override
  String get statsCalories => 'Калории';

  @override
  String get statsAvgDaily => 'В среднем за день';

  @override
  String get statsBestDay => 'Рекордный день';

  @override
  String get statsGoalDays => 'Цель выполнена';

  @override
  String get statsMaxSpeed => 'Макс. скорость';

  @override
  String get statsLongestDay => 'Самая длинная прогулка';

  @override
  String get statsStreak => 'Текущая серия';

  @override
  String get statsLongestStreak => 'Лучшая серия';

  @override
  String get statsActiveDays => 'Активных дней';

  @override
  String statsDays(Object count) {
    return '$count дн.';
  }

  @override
  String get stats30Days => 'Шаги за 30 дней';

  @override
  String get statsByHour => 'Когда вы гуляете (по часам)';

  @override
  String get statsByWeekday => 'По дням недели';

  @override
  String statsMostActive(Object day, Object hour) {
    return 'Пик активности: $day, около $hour:00';
  }

  @override
  String get statsDiscoveries => 'Открытия';

  @override
  String get statsVisitsTotal => 'Открыто мест';

  @override
  String get statsVisitsWeek => 'За неделю';

  @override
  String get statsBySource => 'По источникам';

  @override
  String get statsByCategory => 'По категориям';

  @override
  String get statsByMethod => 'Как подтверждено';

  @override
  String get methodQr => 'QR-код';

  @override
  String get methodGeofence => 'Пришёл (GPS)';

  @override
  String get methodManual => 'Отмечено вручную';

  @override
  String get statsFirstDiscovery => 'Первое открытие';

  @override
  String get statsLastDiscovery => 'Последнее открытие';

  @override
  String get statsOldestYear => 'Самая древняя эпоха';

  @override
  String get statsHunts => 'Поиски мест';

  @override
  String get statsHuntsTotal => 'Начато';

  @override
  String get statsHuntsFound => 'Найдено';

  @override
  String get statsHuntsAbandoned => 'Брошено';

  @override
  String get statsSuccessRate => 'Успешность';

  @override
  String get statsAvgStepsHunt => 'Шагов на поиск';

  @override
  String get statsAvgDistanceHunt => 'Путь на поиск';

  @override
  String get statsAvgTimeHunt => 'Время на поиск';

  @override
  String get statsTotalHuntSteps => 'Шагов в поисках';

  @override
  String get statsDetour => 'Коэф. петляния';

  @override
  String get statsDetourHint => 'Пройдено ÷ расстояние по прямой. 1.0 — идеальный путь';

  @override
  String get statsFewestSteps => 'Меньше всего шагов';

  @override
  String get statsMostSteps => 'Больше всего шагов';

  @override
  String get statsFastest => 'Быстрее всего';

  @override
  String get statsRecentHunts => 'Последние поиски';

  @override
  String get huntStatusFound => 'найдено';

  @override
  String get huntStatusAbandoned => 'брошено';

  @override
  String get huntStatusActive => 'в процессе';

  @override
  String get statsEngagement => 'Любознательность';

  @override
  String get statsScans => 'Сканирований QR';

  @override
  String get statsUniqueScans => 'Уникальных кодов';

  @override
  String get statsViews => 'Открыто карточек';

  @override
  String get statsUniqueViews => 'Уникальных мест прочитано';

  @override
  String get statsFavorites => 'В избранном';

  @override
  String get statsUserPlaces => 'Добавлено мест';

  @override
  String get statsPlacesLoaded => 'Мест загружено из источников';

  @override
  String get statsExploration => 'Исследование';

  @override
  String get statsExploredArea => 'Исследовано территории';

  @override
  String get statsExploredCells => 'Посещено клеток карты';

  @override
  String get statsStepsPerDiscovery => 'Шагов на одно открытие';

  @override
  String get statsMetersPerDiscovery => 'Путь на одно открытие';

  @override
  String statsAchievements(Object unlocked, Object total) {
    return 'Достижения $unlocked/$total';
  }

  @override
  String get statsReset => 'Сбросить статистику';

  @override
  String get statsResetConfirm =>
      'Все шаги, маршруты, поиски и открытия будут удалены с устройства. Избранное и ваши места останутся.';

  @override
  String get statsResetDone => 'Статистика очищена';

  @override
  String get statsEmpty => 'Отправляйтесь на прогулку — здесь появится статистика';

  @override
  String get noData => '—';

  @override
  String get unitM => 'м';

  @override
  String get unitKm => 'км';

  @override
  String get unitH => 'ч';

  @override
  String get unitMin => 'мин';

  @override
  String get unitS => 'с';

  @override
  String get unitKmh => 'км/ч';

  @override
  String get unitKcal => 'ккал';

  @override
  String get unitKm2 => 'км²';

  @override
  String get achFirstDiscovery => 'Первая находка';

  @override
  String get achFirstDiscoveryDesc => 'Откройте первое место';

  @override
  String get achTenDiscoveries => 'Краевед';

  @override
  String get achTenDiscoveriesDesc => 'Откройте 10 мест';

  @override
  String get achFiftyDiscoveries => 'Летописец';

  @override
  String get achFiftyDiscoveriesDesc => 'Откройте 50 мест';

  @override
  String get achFirstHunt => 'Следопыт';

  @override
  String get achFirstHuntDesc => 'Завершите поиск места';

  @override
  String get achFiveHunts => 'Искатель сокровищ';

  @override
  String get achFiveHuntsDesc => 'Завершите 5 поисков';

  @override
  String get achStraightShooter => 'Прямо к цели';

  @override
  String get achStraightShooterDesc => 'Найдите место с коэффициентом петляния ≤ 1.3';

  @override
  String get achTenKDay => '10 000 шагов';

  @override
  String get achTenKDayDesc => 'Пройдите 10 000 шагов за день';

  @override
  String get achHundredKTotal => 'Сотник';

  @override
  String get achHundredKTotalDesc => '100 000 шагов всего';

  @override
  String get achMarathon => 'Марафонец';

  @override
  String get achMarathonDesc => 'Пройдите 42,2 км всего';

  @override
  String get achExplorer => 'Первооткрыватель';

  @override
  String get achExplorerDesc => 'Исследуйте 1 км² карты';

  @override
  String get achScanner => 'Дешифровщик';

  @override
  String get achScannerDesc => 'Отсканируйте 10 QR-кодов';

  @override
  String get achAllSources => 'Энциклопедист';

  @override
  String get achAllSourcesDesc => 'Откройте место из каждого источника';

  @override
  String get achWeekStreak => 'Неделя истории';

  @override
  String get achWeekStreakDesc => 'Будьте активны 7 дней подряд';

  @override
  String get achTimeTraveler => 'Путешественник во времени';

  @override
  String get achTimeTravelerDesc => 'Откройте что-то старше 1917 года';

  @override
  String get achCurator => 'Хранитель';

  @override
  String get achCuratorDesc => 'Сохраните 10 мест в избранное';

  @override
  String get achCartographer => 'Картограф';

  @override
  String get achCartographerDesc => 'Добавьте 3 своих места';

  @override
  String get sectionSources => 'Источники данных';

  @override
  String get sectionTracking => 'Трекинг';

  @override
  String get searchRadius => 'Радиус поиска';

  @override
  String get backgroundTracking => 'Фоновый трекинг';

  @override
  String get backgroundTrackingSubtitle => 'Считать шаги и маршрут при выключенном экране (будет уведомление)';

  @override
  String get autoTracking => 'Включать трекинг автоматически';

  @override
  String get autoTrackingSubtitle => 'При открытии карты';

  @override
  String get dailyGoal => 'Дневная цель шагов';

  @override
  String get stepLength => 'Длина шага';

  @override
  String get unitCm => 'см';

  @override
  String get geofenceRadius => 'Радиус прибытия';

  @override
  String get geofenceRadiusSubtitle => 'Насколько близко считается «нашёл»';

  @override
  String get sourcePastvuDesc => 'Ретрофото от сообщества краеведов';

  @override
  String get sourceWikipediaDesc => 'Статьи о местах рядом';

  @override
  String get sourceWikidataDesc => 'Объекты культурного наследия из реестра';

  @override
  String get sourceOsmDesc => 'Памятники, мемориалы, руины из OpenStreetMap';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutTagline => 'Открывайте историю вокруг себя';

  @override
  String get aboutDescription =>
      'QStory находит исторические места, ретрофотографии и объекты наследия вокруг вас по открытым данным сообществ историков и энциклопедий. Выберите место, дойдите до него — и узнайте, сколько шагов заняли поиски.';

  @override
  String get aboutDataTitle => 'Откуда данные';

  @override
  String get aboutPrivacyTitle => 'Приватность';

  @override
  String get aboutPrivacyText =>
      'Без аккаунтов и собственного сервера. Маршруты, шаги и статистика не покидают устройство. Чтобы найти места рядом, приложение отправляет в перечисленные открытые API только координаты области карты; напоминания и экспорт — только если вы их включите.';

  @override
  String get aboutLicenseTitle => 'Лицензия';

  @override
  String get aboutSourceCode => 'Исходный код';

  @override
  String get aboutReportIssue => 'Сообщить о проблеме';

  @override
  String get aboutTeam => 'Команда';

  @override
  String get openSourceLicenses => 'Лицензии open-source';

  @override
  String get explorerTitle => 'Исследователь';

  @override
  String get statsOpen => 'Открыть статистику';

  @override
  String openEmailFailed(Object email) {
    return 'Почтовое приложение не найдено. Напишите на $email';
  }

  @override
  String get emailOpened => 'Открываем почтовое приложение…';

  @override
  String get locationNeeded => 'Геолокация нужна для карты и трекинга';

  @override
  String get visited => 'Посещено';

  @override
  String get details => 'Подробнее';

  @override
  String huntEta(Object time, Object steps) {
    return '≈ $time · ещё ≈ $steps шагов';
  }

  @override
  String nearbyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count места рядом',
      many: '$count мест рядом',
      few: '$count места рядом',
      one: '$count место рядом',
      zero: 'Рядом ничего нет',
    );
    return '$_temp0';
  }

  @override
  String get nearbyFromMapCenter => 'Расстояния от центра карты — включите геолокацию, чтобы считать от вас.';

  @override
  String get nearbyEmpty => 'Здесь пока ничего не найдено. Сдвиньте карту или увеличьте радиус поиска в настройках.';

  @override
  String get nearbyAction => 'Список мест';

  @override
  String get share => 'Поделиться';

  @override
  String get directions => 'Проложить маршрут';

  @override
  String get directionsUnavailable => 'Не удалось открыть маршрут ни в одном приложении карт';

  @override
  String get exportData => 'Экспорт данных (JSON)';

  @override
  String get exportSubject => 'QStory — мои данные';

  @override
  String get exportFailed => 'Не удалось экспортировать данные';

  @override
  String get statsGoalReached => 'Цель на сегодня выполнена!';

  @override
  String statsStepsToGoal(Object steps) {
    return 'До цели: $steps шагов';
  }

  @override
  String get statsWeekSteps => 'Шаги за 7 дней';

  @override
  String get statsWeekDistance => 'Путь за 7 дней';

  @override
  String statsWeekHint(Object value) {
    return 'Предыдущие 7 дней: $value';
  }

  @override
  String milestoneGoal(Object goal) {
    return 'Цель дня выполнена: $goal шагов!';
  }

  @override
  String milestoneAchievement(Object name) {
    return 'Новое достижение: $name';
  }

  @override
  String reminderFactTitle(String year) {
    return 'В этот день в $year году';
  }

  @override
  String get reminder1Title => 'Прогуляемся?';

  @override
  String get reminder1Body => 'Рядом есть исторические места, которые вы ещё не нашли.';

  @override
  String get reminder2Title => 'История за углом';

  @override
  String get reminder2Body => 'Откройте карту и выберите место для сегодняшней охоты.';

  @override
  String get reminder3Title => 'Шаги с историей';

  @override
  String get reminder3Body => 'Короткая прогулка к старому зданию — уже вклад в дневную цель.';

  @override
  String get reminder4Title => 'Новая улица';

  @override
  String get reminder4Body => 'Каждый квадрат 250 × 250 м, где вы побывали, увеличивает разведанную площадь.';

  @override
  String get reminder5Title => 'Место ждёт';

  @override
  String get reminder5Body => 'Найдите сегодня одно историческое место и не прерывайте серию.';

  @override
  String get reminderChannel => 'Ежедневное напоминание';

  @override
  String get reminderChannelDesc => 'Напоминание о прогулке раз в день';

  @override
  String get notificationsPermissionDenied => 'Уведомления запрещены. Разрешите их для QStory в настройках системы.';

  @override
  String get aboutPrivacyPolicy => 'Политика конфиденциальности';
}
