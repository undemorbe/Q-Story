// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QStory';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get cameraPermissionRequired => 'Camera permission is required to scan QR codes.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get navMap => 'Map';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboarding1Title => 'Discover';

  @override
  String get onboarding1Desc =>
      'Historical places, retro photos and heritage sites around you — from open history communities.';

  @override
  String get onboarding2Title => 'Search';

  @override
  String get onboarding2Desc => 'Pick a place and walk to it. QStory tracks your route and steps until you arrive.';

  @override
  String get onboarding3Title => 'Remember';

  @override
  String get onboarding3Desc =>
      'Scan QR plaques, collect discoveries and watch your statistics grow — all stored only on your phone.';

  @override
  String get continueButton => 'Continue';

  @override
  String get beginButton => 'Begin';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get profileTitle => 'Profile';

  @override
  String get favorites => 'Favorites';

  @override
  String get dailyHistory => 'Daily History';

  @override
  String get dailyHistorySubtitle => 'Discover today\'s history';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Configure daily notifications';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get sendSupportMessage => 'Send us a message and we\'ll get back to you';

  @override
  String get enterMessage => 'Enter your message...';

  @override
  String get messageSent => 'Message sent successfully';

  @override
  String get send => 'Send';

  @override
  String get retry => 'Retry';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'A daily reminder to go for a walk';

  @override
  String get checkNotification => 'Test Notification';

  @override
  String get checkNotificationSubtitle => 'Send test notification now';

  @override
  String get preferences => 'Preferences';

  @override
  String get about => 'About';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get dailyNotificationsTitle => 'Daily Notifications';

  @override
  String get dailyNotificationsDesc => 'Once a day: a curious fact from Wikipedia or a place near you';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationDesc => 'Check how notifications work';

  @override
  String get aboutNotificationsTitle => 'About Notifications';

  @override
  String get aboutNotificationsText =>
      'Once a day at the chosen time QStory sends one curious fact: a “Did you know” teaser or an anniversary selected by Wikipedia editors, or a story about an unvisited place in the area you last explored. Tap it to read the article. Facts never repeat; the only requests leaving your device go to Wikipedia.';

  @override
  String get notificationsEnabledMsg => 'Notifications enabled';

  @override
  String get notificationsDisabledMsg => 'Notifications disabled';

  @override
  String get testNotificationSent => 'Test notification sent';

  @override
  String dailyNotificationsActivated(String time) {
    return 'Daily notifications activated at $time';
  }

  @override
  String get titleField => 'Title';

  @override
  String get typeField => 'Type';

  @override
  String get imageUrlField => 'Image URL';

  @override
  String get coordinatesLabel => 'Coordinates';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get selectDate => 'Select date';

  @override
  String get pickPointTitle => 'Pick a point';

  @override
  String get tapMapHint => 'Tap on the map to choose coordinates';

  @override
  String get done => 'Done';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get onThisDayTitle => 'On this day';

  @override
  String get onThisDaySubtitle => 'events of the day in Russian history';

  @override
  String get anotherFact => 'Another fact';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get loadingLabel => 'Loading…';

  @override
  String get openInWikipedia => 'Open in Wikipedia';

  @override
  String get noFactsForToday => 'No facts from Russian or Soviet history for this day.';

  @override
  String get wikipediaSource => 'Source: Wikipedia';

  @override
  String wikipediaSourceWithCount(int count) {
    return 'Source: Wikipedia · $count facts';
  }

  @override
  String get locationDisabled => 'Location is disabled in device settings';

  @override
  String get locationDenied => 'Location access not granted';

  @override
  String get locationDeniedForever => 'Location is permanently denied. Enable it in app settings';

  @override
  String locationError(String error) {
    return 'Could not determine coordinates: $error';
  }

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filterAll => 'All';

  @override
  String get report => 'Report';

  @override
  String get reportTitle => 'Report an issue';

  @override
  String get reportCategory => 'Category';

  @override
  String get reportText => 'Describe the issue...';

  @override
  String get reportSent => 'Report sent successfully';

  @override
  String get reportConfirmTitle => 'Confirm Report';

  @override
  String reportConfirmMessage(String category) {
    return 'Send report for category: $category?';
  }

  @override
  String get reportCategoryVandalism => 'Vandalism';

  @override
  String get reportCategoryMisinformation => 'Misinformation';

  @override
  String get reportCategoryOffensive => 'Offensive content';

  @override
  String get reportCategorySpam => 'Spam';

  @override
  String get reportCategoryCopyright => 'Copyright violation';

  @override
  String get reportCategoryAdult => 'Adult content';

  @override
  String get reportCategoryHate => 'Hate speech';

  @override
  String get reportCategoryFraud => 'Fraud';

  @override
  String get reportCategoryMalware => 'Malware/Security threat';

  @override
  String get reportCategoryPrivacy => 'Privacy violation';

  @override
  String get reportCategoryInvalid => 'Invalid information';

  @override
  String get reportCategoryOther => 'Other';

  @override
  String get navStats => 'Stats';

  @override
  String get trackingOn => 'Tracking on';

  @override
  String get trackingOff => 'Tracking off';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get stopTracking => 'Stop tracking';

  @override
  String get followMe => 'Follow me';

  @override
  String stepsToday(Object count) {
    return '$count steps today';
  }

  @override
  String placesCount(Object count) {
    return '$count places';
  }

  @override
  String get loadingPlaces => 'Looking for history around…';

  @override
  String sourcesUnavailable(Object sources) {
    return 'Unavailable: $sources';
  }

  @override
  String get offlineCache => 'Offline — showing saved places';

  @override
  String get searchPlaces => 'Search places';

  @override
  String get searchHere => 'Search this area';

  @override
  String get filterVisited => 'Visited';

  @override
  String get filterNotVisited => 'Not visited';

  @override
  String get visitFilterLabel => 'Status';

  @override
  String get sourcesLabel => 'Sources';

  @override
  String get categoryLabel => 'Category';

  @override
  String get resetFilters => 'Reset';

  @override
  String get addMyPlace => 'Add my place';

  @override
  String nearPlace(Object title) {
    return 'You are next to «$title»';
  }

  @override
  String get markVisited => 'I\'m here';

  @override
  String get markedVisited => 'Added to your discoveries';

  @override
  String get visitedBadge => 'Visited';

  @override
  String huntSearching(Object title) {
    return 'Searching: $title';
  }

  @override
  String huntLeft(Object distance) {
    return '$distance left';
  }

  @override
  String get huntGiveUp => 'Give up';

  @override
  String get huntFoundTitle => 'Found!';

  @override
  String huntFoundBody(Object title, Object steps, Object distance, Object time) {
    return '«$title»: $steps steps, $distance, $time';
  }

  @override
  String get startHunt => 'Find this place';

  @override
  String get huntInProgress => 'Search in progress';

  @override
  String get huntNeedsLocation => 'Turn on location to start a search';

  @override
  String openSource(Object source) {
    return 'Open on $source';
  }

  @override
  String get linksLabel => 'Links';

  @override
  String get authorLabel => 'Author';

  @override
  String distanceFromYou(Object distance) {
    return '$distance from you';
  }

  @override
  String get placeQrTitle => 'QR code for this place';

  @override
  String get placeQrHint => 'Print it and put it on site — other explorers can scan it.';

  @override
  String attribution(Object source, Object license) {
    return 'Data: $source · $license';
  }

  @override
  String get deletePlace => 'Delete place';

  @override
  String get detailsLoadError => 'Couldn\'t load the full description';

  @override
  String get noDescription => 'No description yet.';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get sourceUser => 'My places';

  @override
  String get catMonument => 'Monuments';

  @override
  String get catMemorial => 'Memorials';

  @override
  String get catBuilding => 'Buildings';

  @override
  String get catReligious => 'Churches';

  @override
  String get catMuseum => 'Museums';

  @override
  String get catArchaeology => 'Archaeology';

  @override
  String get catFortification => 'Fortifications';

  @override
  String get catPhoto => 'Retro photos';

  @override
  String get catArticle => 'Articles';

  @override
  String get catOther => 'Other';

  @override
  String get manualInput => 'Enter code';

  @override
  String get enterQrHint => 'Paste a link to Wikipedia, PastVu, OSM…';

  @override
  String get submit => 'Open';

  @override
  String get scanHistory => 'Recent scans';

  @override
  String get noScansYet => 'Nothing scanned yet';

  @override
  String get qrUnknown => 'This code doesn\'t point to a place';

  @override
  String get qrExternal => 'This code contains a link';

  @override
  String get openLink => 'Open link';

  @override
  String get resolvingPlace => 'Looking up the place…';

  @override
  String get placeNotFound => 'Place not found';

  @override
  String get scannerHint => 'Point at a QR code on a plaque or a link to Wikipedia / PastVu / OSM';

  @override
  String get addPlaceTitle => 'New place';

  @override
  String get descriptionField => 'Description';

  @override
  String get yearField => 'Year';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get placeSaved => 'Place saved on this device';

  @override
  String get invalidYear => 'Enter a valid year';

  @override
  String get invalidUrl => 'Enter a valid http(s) link';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsLocalOnly => 'Everything is stored on this device only';

  @override
  String get statsEstimated => 'No step sensor — steps are estimated from distance';

  @override
  String get statsToday => 'Today';

  @override
  String statsGoal(Object percent, Object goal) {
    return '$percent% of daily goal ($goal)';
  }

  @override
  String get statsMovement => 'Movement';

  @override
  String get statsSteps => 'Steps';

  @override
  String get statsDistance => 'Distance';

  @override
  String get statsActiveTime => 'Active time';

  @override
  String get statsCalories => 'Calories';

  @override
  String get statsAvgDaily => 'Avg per day';

  @override
  String get statsBestDay => 'Best day';

  @override
  String get statsGoalDays => 'Goal reached';

  @override
  String get statsMaxSpeed => 'Top speed';

  @override
  String get statsLongestDay => 'Longest walk';

  @override
  String get statsStreak => 'Current streak';

  @override
  String get statsLongestStreak => 'Longest streak';

  @override
  String get statsActiveDays => 'Active days';

  @override
  String statsDays(Object count) {
    return '$count d';
  }

  @override
  String get stats30Days => 'Steps, last 30 days';

  @override
  String get statsByHour => 'When you walk (by hour)';

  @override
  String get statsByWeekday => 'By weekday';

  @override
  String statsMostActive(Object day, Object hour) {
    return 'Most active: $day, around $hour:00';
  }

  @override
  String get statsDiscoveries => 'Discoveries';

  @override
  String get statsVisitsTotal => 'Places discovered';

  @override
  String get statsVisitsWeek => 'This week';

  @override
  String get statsBySource => 'By source';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsByMethod => 'How confirmed';

  @override
  String get methodQr => 'QR scan';

  @override
  String get methodGeofence => 'Arrived (GPS)';

  @override
  String get methodManual => 'Marked manually';

  @override
  String get statsFirstDiscovery => 'First discovery';

  @override
  String get statsLastDiscovery => 'Latest discovery';

  @override
  String get statsOldestYear => 'Oldest era touched';

  @override
  String get statsHunts => 'Searches';

  @override
  String get statsHuntsTotal => 'Started';

  @override
  String get statsHuntsFound => 'Found';

  @override
  String get statsHuntsAbandoned => 'Gave up';

  @override
  String get statsSuccessRate => 'Success rate';

  @override
  String get statsAvgStepsHunt => 'Steps per search';

  @override
  String get statsAvgDistanceHunt => 'Distance per search';

  @override
  String get statsAvgTimeHunt => 'Time per search';

  @override
  String get statsTotalHuntSteps => 'Steps while searching';

  @override
  String get statsDetour => 'Detour ratio';

  @override
  String get statsDetourHint => 'Walked ÷ straight-line distance. 1.0 = perfect path';

  @override
  String get statsFewestSteps => 'Fewest steps';

  @override
  String get statsMostSteps => 'Most steps';

  @override
  String get statsFastest => 'Fastest find';

  @override
  String get statsRecentHunts => 'Recent searches';

  @override
  String get huntStatusFound => 'found';

  @override
  String get huntStatusAbandoned => 'gave up';

  @override
  String get huntStatusActive => 'in progress';

  @override
  String get statsEngagement => 'Curiosity';

  @override
  String get statsScans => 'QR scans';

  @override
  String get statsUniqueScans => 'Unique codes';

  @override
  String get statsViews => 'Places opened';

  @override
  String get statsUniqueViews => 'Unique places read';

  @override
  String get statsFavorites => 'In favorites';

  @override
  String get statsUserPlaces => 'Places added';

  @override
  String get statsPlacesLoaded => 'Places fetched from sources';

  @override
  String get statsExploration => 'Exploration';

  @override
  String get statsExploredArea => 'Area explored';

  @override
  String get statsExploredCells => 'Map cells visited';

  @override
  String get statsStepsPerDiscovery => 'Steps per discovery';

  @override
  String get statsMetersPerDiscovery => 'Distance per discovery';

  @override
  String statsAchievements(Object unlocked, Object total) {
    return 'Achievements $unlocked/$total';
  }

  @override
  String get statsReset => 'Reset statistics';

  @override
  String get statsResetConfirm =>
      'All steps, routes, searches and discoveries will be deleted from this device. Favorites and your places stay.';

  @override
  String get statsResetDone => 'Statistics cleared';

  @override
  String get statsEmpty => 'Go for a walk — stats will appear here';

  @override
  String get noData => '—';

  @override
  String get unitM => 'm';

  @override
  String get unitKm => 'km';

  @override
  String get unitH => 'h';

  @override
  String get unitMin => 'min';

  @override
  String get unitS => 's';

  @override
  String get unitKmh => 'km/h';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitKm2 => 'km²';

  @override
  String get achFirstDiscovery => 'First find';

  @override
  String get achFirstDiscoveryDesc => 'Discover your first place';

  @override
  String get achTenDiscoveries => 'Local historian';

  @override
  String get achTenDiscoveriesDesc => 'Discover 10 places';

  @override
  String get achFiftyDiscoveries => 'Chronicler';

  @override
  String get achFiftyDiscoveriesDesc => 'Discover 50 places';

  @override
  String get achFirstHunt => 'Pathfinder';

  @override
  String get achFirstHuntDesc => 'Complete a search';

  @override
  String get achFiveHunts => 'Treasure hunter';

  @override
  String get achFiveHuntsDesc => 'Complete 5 searches';

  @override
  String get achStraightShooter => 'Straight to the point';

  @override
  String get achStraightShooterDesc => 'Find a place with detour ratio ≤ 1.3';

  @override
  String get achTenKDay => '10,000 steps';

  @override
  String get achTenKDayDesc => 'Walk 10,000 steps in one day';

  @override
  String get achHundredKTotal => 'Centurion';

  @override
  String get achHundredKTotalDesc => '100,000 steps in total';

  @override
  String get achMarathon => 'Marathon';

  @override
  String get achMarathonDesc => 'Walk 42.2 km in total';

  @override
  String get achExplorer => 'Explorer';

  @override
  String get achExplorerDesc => 'Explore 1 km² of the map';

  @override
  String get achScanner => 'Code breaker';

  @override
  String get achScannerDesc => 'Scan 10 QR codes';

  @override
  String get achAllSources => 'Polymath';

  @override
  String get achAllSourcesDesc => 'Discover a place from every source';

  @override
  String get achWeekStreak => 'Week of history';

  @override
  String get achWeekStreakDesc => 'Be active 7 days in a row';

  @override
  String get achTimeTraveler => 'Time traveler';

  @override
  String get achTimeTravelerDesc => 'Discover something from before 1917';

  @override
  String get achCurator => 'Curator';

  @override
  String get achCuratorDesc => 'Save 10 favorites';

  @override
  String get achCartographer => 'Cartographer';

  @override
  String get achCartographerDesc => 'Add 3 places of your own';

  @override
  String get sectionSources => 'Data sources';

  @override
  String get sectionTracking => 'Tracking';

  @override
  String get searchRadius => 'Search radius';

  @override
  String get backgroundTracking => 'Background tracking';

  @override
  String get backgroundTrackingSubtitle => 'Keep counting steps and route with the screen off (shows a notification)';

  @override
  String get autoTracking => 'Start tracking automatically';

  @override
  String get autoTrackingSubtitle => 'When the map opens';

  @override
  String get dailyGoal => 'Daily step goal';

  @override
  String get stepLength => 'Step length';

  @override
  String get unitCm => 'cm';

  @override
  String get geofenceRadius => 'Arrival radius';

  @override
  String get geofenceRadiusSubtitle => 'How close counts as \"found\"';

  @override
  String get sourcePastvuDesc => 'Retro photos from a community of local historians';

  @override
  String get sourceWikipediaDesc => 'Articles about places nearby';

  @override
  String get sourceWikidataDesc => 'Registered cultural heritage sites';

  @override
  String get sourceOsmDesc => 'Monuments, memorials, ruins from OpenStreetMap';

  @override
  String get aboutTitle => 'About QStory';

  @override
  String get aboutTagline => 'Discover history around you';

  @override
  String get aboutDescription =>
      'QStory finds historical places, retro photos and heritage sites around you using open data from history communities and encyclopedias. Pick a place, walk to it, and track how far you went to find it.';

  @override
  String get aboutDataTitle => 'Where the data comes from';

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacyText =>
      'No accounts, no servers of our own. Your routes, steps and statistics never leave the device. To find places nearby the app sends only the map area coordinates to the open-data APIs listed above; reminders and exports happen only when you turn them on.';

  @override
  String get aboutLicenseTitle => 'License';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutReportIssue => 'Report an issue';

  @override
  String get aboutTeam => 'Team';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get explorerTitle => 'Explorer';

  @override
  String get statsOpen => 'Open statistics';

  @override
  String openEmailFailed(Object email) {
    return 'No email app found. Write to $email';
  }

  @override
  String get emailOpened => 'Opening your email app…';

  @override
  String get locationNeeded => 'Location is needed for the map and tracking';

  @override
  String get visited => 'Visited';

  @override
  String get details => 'Details';

  @override
  String huntEta(Object time, Object steps) {
    return '≈ $time · ≈ $steps steps to go';
  }

  @override
  String nearbyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places nearby',
      one: '1 place nearby',
      zero: 'No places nearby',
    );
    return '$_temp0';
  }

  @override
  String get nearbyFromMapCenter => 'Distances from the map centre — turn on location for distances from you.';

  @override
  String get nearbyEmpty => 'Nothing found here yet. Move the map or widen the search radius in Settings.';

  @override
  String get nearbyAction => 'Places list';

  @override
  String get share => 'Share';

  @override
  String get directions => 'Walk there';

  @override
  String get directionsUnavailable => 'No map app could open the route';

  @override
  String get exportData => 'Export my data (JSON)';

  @override
  String get exportSubject => 'QStory — my data';

  @override
  String get exportFailed => 'Could not export the data';

  @override
  String get statsGoalReached => 'Daily goal reached!';

  @override
  String statsStepsToGoal(Object steps) {
    return '$steps steps to the goal';
  }

  @override
  String get statsWeekSteps => 'Steps, last 7 days';

  @override
  String get statsWeekDistance => 'Distance, last 7 days';

  @override
  String statsWeekHint(Object value) {
    return 'Previous 7 days: $value';
  }

  @override
  String milestoneGoal(Object goal) {
    return 'Daily goal reached: $goal steps!';
  }

  @override
  String milestoneAchievement(Object name) {
    return 'New achievement: $name';
  }

  @override
  String reminderFactTitle(String year) {
    return 'On this day in $year';
  }

  @override
  String get reminder1Title => 'Time for a walk?';

  @override
  String get reminder1Body => 'There are historical places near you that you haven\'t found yet.';

  @override
  String get reminder2Title => 'History around the corner';

  @override
  String get reminder2Body => 'Open the map and pick a place to hunt for today.';

  @override
  String get reminder3Title => 'Steps with a story';

  @override
  String get reminder3Body => 'A short walk to an old building counts towards your daily goal.';

  @override
  String get reminder4Title => 'Explore a new street';

  @override
  String get reminder4Body => 'Every 250 × 250 m square you visit adds to the explored area.';

  @override
  String get reminder5Title => 'A place is waiting';

  @override
  String get reminder5Body => 'Find one historical place today and keep your streak going.';

  @override
  String get reminderChannel => 'Daily reminder';

  @override
  String get reminderChannelDesc => 'Once-a-day reminder to go for a walk';

  @override
  String get notificationsPermissionDenied =>
      'Notifications are not allowed. Enable them for QStory in the system settings.';

  @override
  String get aboutPrivacyPolicy => 'Privacy policy';

  @override
  String get reminderDykTitle => 'Did you know?';

  @override
  String reminderNearbyTitle(String place) {
    return 'Near you: $place';
  }

  @override
  String get trackingNotificationText => 'Recording your walk and steps';

  @override
  String get trackingNotificationChannel => 'Walk tracking';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get aboutAuthorBoris => 'Boris Stankov';

  @override
  String get aboutAuthorAndrey => 'Andrey Kornev';

  @override
  String get aboutRoleMobile => 'Mobile · Flutter';

  @override
  String get aboutRoleHistory => 'History research';
}
