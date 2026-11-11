import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'QStory'**
  String get appTitle;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR codes.'**
  String get cameraPermissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

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

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get navScanner;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Historical places, retro photos and heritage sites around you — from open history communities.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Pick a place and walk to it. QStory tracks your route and steps until you arrive.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Scan QR plaques, collect discoveries and watch your statistics grow — all stored only on your phone.'**
  String get onboarding3Desc;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @beginButton.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get beginButton;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @dailyHistory.
  ///
  /// In en, this message translates to:
  /// **'Daily History'**
  String get dailyHistory;

  /// No description provided for @dailyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover today\'s history'**
  String get dailyHistorySubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure daily notifications'**
  String get notificationsSubtitle;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @sendSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we\'ll get back to you'**
  String get sendSupportMessage;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your message...'**
  String get enterMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get messageSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A daily reminder to go for a walk'**
  String get pushNotificationsSubtitle;

  /// No description provided for @checkNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get checkNotification;

  /// No description provided for @checkNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send test notification now'**
  String get checkNotificationSubtitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifSettingsTitle;

  /// No description provided for @dailyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Notifications'**
  String get dailyNotificationsTitle;

  /// No description provided for @dailyNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Once a day: a curious fact from Wikipedia or a place near you'**
  String get dailyNotificationsDesc;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Check how notifications work'**
  String get testNotificationDesc;

  /// No description provided for @aboutNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'About Notifications'**
  String get aboutNotificationsTitle;

  /// No description provided for @aboutNotificationsText.
  ///
  /// In en, this message translates to:
  /// **'Once a day at the chosen time QStory sends one curious fact: a “Did you know” teaser or an anniversary selected by Wikipedia editors, or a story about an unvisited place in the area you last explored. Tap it to read the article. Facts never repeat; the only requests leaving your device go to Wikipedia.'**
  String get aboutNotificationsText;

  /// No description provided for @notificationsEnabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabledMsg;

  /// No description provided for @notificationsDisabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabledMsg;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @dailyNotificationsActivated.
  ///
  /// In en, this message translates to:
  /// **'Daily notifications activated at {time}'**
  String dailyNotificationsActivated(String time);

  /// No description provided for @titleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleField;

  /// No description provided for @typeField.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeField;

  /// No description provided for @imageUrlField.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrlField;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get fieldRequired;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @pickPointTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a point'**
  String get pickPointTitle;

  /// No description provided for @tapMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to choose coordinates'**
  String get tapMapHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @onThisDayTitle.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get onThisDayTitle;

  /// No description provided for @onThisDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'events of the day in Russian history'**
  String get onThisDaySubtitle;

  /// No description provided for @anotherFact.
  ///
  /// In en, this message translates to:
  /// **'Another fact'**
  String get anotherFact;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// No description provided for @openInWikipedia.
  ///
  /// In en, this message translates to:
  /// **'Open in Wikipedia'**
  String get openInWikipedia;

  /// No description provided for @noFactsForToday.
  ///
  /// In en, this message translates to:
  /// **'No facts from Russian or Soviet history for this day.'**
  String get noFactsForToday;

  /// No description provided for @wikipediaSource.
  ///
  /// In en, this message translates to:
  /// **'Source: Wikipedia'**
  String get wikipediaSource;

  /// No description provided for @wikipediaSourceWithCount.
  ///
  /// In en, this message translates to:
  /// **'Source: Wikipedia · {count} facts'**
  String wikipediaSourceWithCount(int count);

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is disabled in device settings'**
  String get locationDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access not granted'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is permanently denied. Enable it in app settings'**
  String get locationDeniedForever;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine coordinates: {error}'**
  String locationError(String error);

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportTitle;

  /// No description provided for @reportCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reportCategory;

  /// No description provided for @reportText.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue...'**
  String get reportText;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent successfully'**
  String get reportSent;

  /// No description provided for @reportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Report'**
  String get reportConfirmTitle;

  /// No description provided for @reportConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Send report for category: {category}?'**
  String reportConfirmMessage(String category);

  /// No description provided for @reportCategoryVandalism.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get reportCategoryVandalism;

  /// No description provided for @reportCategoryMisinformation.
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get reportCategoryMisinformation;

  /// No description provided for @reportCategoryOffensive.
  ///
  /// In en, this message translates to:
  /// **'Offensive content'**
  String get reportCategoryOffensive;

  /// No description provided for @reportCategorySpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportCategorySpam;

  /// No description provided for @reportCategoryCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright violation'**
  String get reportCategoryCopyright;

  /// No description provided for @reportCategoryAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult content'**
  String get reportCategoryAdult;

  /// No description provided for @reportCategoryHate.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get reportCategoryHate;

  /// No description provided for @reportCategoryFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud'**
  String get reportCategoryFraud;

  /// No description provided for @reportCategoryMalware.
  ///
  /// In en, this message translates to:
  /// **'Malware/Security threat'**
  String get reportCategoryMalware;

  /// No description provided for @reportCategoryPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy violation'**
  String get reportCategoryPrivacy;

  /// No description provided for @reportCategoryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid information'**
  String get reportCategoryInvalid;

  /// No description provided for @reportCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportCategoryOther;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @trackingOn.
  ///
  /// In en, this message translates to:
  /// **'Tracking on'**
  String get trackingOn;

  /// No description provided for @trackingOff.
  ///
  /// In en, this message translates to:
  /// **'Tracking off'**
  String get trackingOff;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking'**
  String get stopTracking;

  /// No description provided for @followMe.
  ///
  /// In en, this message translates to:
  /// **'Follow me'**
  String get followMe;

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'{count} steps today'**
  String stepsToday(Object count);

  /// No description provided for @placesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} places'**
  String placesCount(Object count);

  /// No description provided for @loadingPlaces.
  ///
  /// In en, this message translates to:
  /// **'Looking for history around…'**
  String get loadingPlaces;

  /// No description provided for @sourcesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable: {sources}'**
  String sourcesUnavailable(Object sources);

  /// No description provided for @offlineCache.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved places'**
  String get offlineCache;

  /// No description provided for @searchPlaces.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get searchPlaces;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get searchHere;

  /// No description provided for @filterVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get filterVisited;

  /// No description provided for @filterNotVisited.
  ///
  /// In en, this message translates to:
  /// **'Not visited'**
  String get filterNotVisited;

  /// No description provided for @visitFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get visitFilterLabel;

  /// No description provided for @sourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @addMyPlace.
  ///
  /// In en, this message translates to:
  /// **'Add my place'**
  String get addMyPlace;

  /// No description provided for @nearPlace.
  ///
  /// In en, this message translates to:
  /// **'You are next to «{title}»'**
  String nearPlace(Object title);

  /// No description provided for @markVisited.
  ///
  /// In en, this message translates to:
  /// **'I\'m here'**
  String get markVisited;

  /// No description provided for @markedVisited.
  ///
  /// In en, this message translates to:
  /// **'Added to your discoveries'**
  String get markedVisited;

  /// No description provided for @visitedBadge.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visitedBadge;

  /// No description provided for @huntSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching: {title}'**
  String huntSearching(Object title);

  /// No description provided for @huntLeft.
  ///
  /// In en, this message translates to:
  /// **'{distance} left'**
  String huntLeft(Object distance);

  /// No description provided for @huntGiveUp.
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get huntGiveUp;

  /// No description provided for @huntFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Found!'**
  String get huntFoundTitle;

  /// No description provided for @huntFoundBody.
  ///
  /// In en, this message translates to:
  /// **'«{title}»: {steps} steps, {distance}, {time}'**
  String huntFoundBody(Object title, Object steps, Object distance, Object time);

  /// No description provided for @startHunt.
  ///
  /// In en, this message translates to:
  /// **'Find this place'**
  String get startHunt;

  /// No description provided for @huntInProgress.
  ///
  /// In en, this message translates to:
  /// **'Search in progress'**
  String get huntInProgress;

  /// No description provided for @huntNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to start a search'**
  String get huntNeedsLocation;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open on {source}'**
  String openSource(Object source);

  /// No description provided for @linksLabel.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @distanceFromYou.
  ///
  /// In en, this message translates to:
  /// **'{distance} from you'**
  String distanceFromYou(Object distance);

  /// No description provided for @placeQrTitle.
  ///
  /// In en, this message translates to:
  /// **'QR code for this place'**
  String get placeQrTitle;

  /// No description provided for @placeQrHint.
  ///
  /// In en, this message translates to:
  /// **'Print it and put it on site — other explorers can scan it.'**
  String get placeQrHint;

  /// No description provided for @attribution.
  ///
  /// In en, this message translates to:
  /// **'Data: {source} · {license}'**
  String attribution(Object source, Object license);

  /// No description provided for @deletePlace.
  ///
  /// In en, this message translates to:
  /// **'Delete place'**
  String get deletePlace;

  /// No description provided for @detailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the full description'**
  String get detailsLoadError;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet.'**
  String get noDescription;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @sourceUser.
  ///
  /// In en, this message translates to:
  /// **'My places'**
  String get sourceUser;

  /// No description provided for @catMonument.
  ///
  /// In en, this message translates to:
  /// **'Monuments'**
  String get catMonument;

  /// No description provided for @catMemorial.
  ///
  /// In en, this message translates to:
  /// **'Memorials'**
  String get catMemorial;

  /// No description provided for @catBuilding.
  ///
  /// In en, this message translates to:
  /// **'Buildings'**
  String get catBuilding;

  /// No description provided for @catReligious.
  ///
  /// In en, this message translates to:
  /// **'Churches'**
  String get catReligious;

  /// No description provided for @catMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museums'**
  String get catMuseum;

  /// No description provided for @catArchaeology.
  ///
  /// In en, this message translates to:
  /// **'Archaeology'**
  String get catArchaeology;

  /// No description provided for @catFortification.
  ///
  /// In en, this message translates to:
  /// **'Fortifications'**
  String get catFortification;

  /// No description provided for @catPhoto.
  ///
  /// In en, this message translates to:
  /// **'Retro photos'**
  String get catPhoto;

  /// No description provided for @catArticle.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get catArticle;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get manualInput;

  /// No description provided for @enterQrHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a link to Wikipedia, PastVu, OSM…'**
  String get enterQrHint;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get submit;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get scanHistory;

  /// No description provided for @noScansYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing scanned yet'**
  String get noScansYet;

  /// No description provided for @qrUnknown.
  ///
  /// In en, this message translates to:
  /// **'This code doesn\'t point to a place'**
  String get qrUnknown;

  /// No description provided for @qrExternal.
  ///
  /// In en, this message translates to:
  /// **'This code contains a link'**
  String get qrExternal;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @resolvingPlace.
  ///
  /// In en, this message translates to:
  /// **'Looking up the place…'**
  String get resolvingPlace;

  /// No description provided for @placeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Place not found'**
  String get placeNotFound;

  /// No description provided for @scannerHint.
  ///
  /// In en, this message translates to:
  /// **'Point at a QR code on a plaque or a link to Wikipedia / PastVu / OSM'**
  String get scannerHint;

  /// No description provided for @addPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'New place'**
  String get addPlaceTitle;

  /// No description provided for @descriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionField;

  /// No description provided for @yearField.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearField;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @placeSaved.
  ///
  /// In en, this message translates to:
  /// **'Place saved on this device'**
  String get placeSaved;

  /// No description provided for @invalidYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year'**
  String get invalidYear;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) link'**
  String get invalidUrl;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored on this device only'**
  String get statsLocalOnly;

  /// No description provided for @statsEstimated.
  ///
  /// In en, this message translates to:
  /// **'No step sensor — steps are estimated from distance'**
  String get statsEstimated;

  /// No description provided for @statsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsToday;

  /// No description provided for @statsGoal.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of daily goal ({goal})'**
  String statsGoal(Object percent, Object goal);

  /// No description provided for @statsMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get statsMovement;

  /// No description provided for @statsSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get statsSteps;

  /// No description provided for @statsDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get statsDistance;

  /// No description provided for @statsActiveTime.
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get statsActiveTime;

  /// No description provided for @statsCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get statsCalories;

  /// No description provided for @statsAvgDaily.
  ///
  /// In en, this message translates to:
  /// **'Avg per day'**
  String get statsAvgDaily;

  /// No description provided for @statsBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get statsBestDay;

  /// No description provided for @statsGoalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get statsGoalDays;

  /// No description provided for @statsMaxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get statsMaxSpeed;

  /// No description provided for @statsLongestDay.
  ///
  /// In en, this message translates to:
  /// **'Longest walk'**
  String get statsLongestDay;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statsStreak;

  /// No description provided for @statsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get statsLongestStreak;

  /// No description provided for @statsActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get statsActiveDays;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'{count} d'**
  String statsDays(Object count);

  /// No description provided for @stats30Days.
  ///
  /// In en, this message translates to:
  /// **'Steps, last 30 days'**
  String get stats30Days;

  /// No description provided for @statsByHour.
  ///
  /// In en, this message translates to:
  /// **'When you walk (by hour)'**
  String get statsByHour;

  /// No description provided for @statsByWeekday.
  ///
  /// In en, this message translates to:
  /// **'By weekday'**
  String get statsByWeekday;

  /// No description provided for @statsMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active: {day}, around {hour}:00'**
  String statsMostActive(Object day, Object hour);

  /// No description provided for @statsDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Discoveries'**
  String get statsDiscoveries;

  /// No description provided for @statsVisitsTotal.
  ///
  /// In en, this message translates to:
  /// **'Places discovered'**
  String get statsVisitsTotal;

  /// No description provided for @statsVisitsWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsVisitsWeek;

  /// No description provided for @statsBySource.
  ///
  /// In en, this message translates to:
  /// **'By source'**
  String get statsBySource;

  /// No description provided for @statsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get statsByCategory;

  /// No description provided for @statsByMethod.
  ///
  /// In en, this message translates to:
  /// **'How confirmed'**
  String get statsByMethod;

  /// No description provided for @methodQr.
  ///
  /// In en, this message translates to:
  /// **'QR scan'**
  String get methodQr;

  /// No description provided for @methodGeofence.
  ///
  /// In en, this message translates to:
  /// **'Arrived (GPS)'**
  String get methodGeofence;

  /// No description provided for @methodManual.
  ///
  /// In en, this message translates to:
  /// **'Marked manually'**
  String get methodManual;

  /// No description provided for @statsFirstDiscovery.
  ///
  /// In en, this message translates to:
  /// **'First discovery'**
  String get statsFirstDiscovery;

  /// No description provided for @statsLastDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Latest discovery'**
  String get statsLastDiscovery;

  /// No description provided for @statsOldestYear.
  ///
  /// In en, this message translates to:
  /// **'Oldest era touched'**
  String get statsOldestYear;

  /// No description provided for @statsHunts.
  ///
  /// In en, this message translates to:
  /// **'Searches'**
  String get statsHunts;

  /// No description provided for @statsHuntsTotal.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get statsHuntsTotal;

  /// No description provided for @statsHuntsFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get statsHuntsFound;

  /// No description provided for @statsHuntsAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Gave up'**
  String get statsHuntsAbandoned;

  /// No description provided for @statsSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get statsSuccessRate;

  /// No description provided for @statsAvgStepsHunt.
  ///
  /// In en, this message translates to:
  /// **'Steps per search'**
  String get statsAvgStepsHunt;

  /// No description provided for @statsAvgDistanceHunt.
  ///
  /// In en, this message translates to:
  /// **'Distance per search'**
  String get statsAvgDistanceHunt;

  /// No description provided for @statsAvgTimeHunt.
  ///
  /// In en, this message translates to:
  /// **'Time per search'**
  String get statsAvgTimeHunt;

  /// No description provided for @statsTotalHuntSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps while searching'**
  String get statsTotalHuntSteps;

  /// No description provided for @statsDetour.
  ///
  /// In en, this message translates to:
  /// **'Detour ratio'**
  String get statsDetour;

  /// No description provided for @statsDetourHint.
  ///
  /// In en, this message translates to:
  /// **'Walked ÷ straight-line distance. 1.0 = perfect path'**
  String get statsDetourHint;

  /// No description provided for @statsFewestSteps.
  ///
  /// In en, this message translates to:
  /// **'Fewest steps'**
  String get statsFewestSteps;

  /// No description provided for @statsMostSteps.
  ///
  /// In en, this message translates to:
  /// **'Most steps'**
  String get statsMostSteps;

  /// No description provided for @statsFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest find'**
  String get statsFastest;

  /// No description provided for @statsRecentHunts.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get statsRecentHunts;

  /// No description provided for @huntStatusFound.
  ///
  /// In en, this message translates to:
  /// **'found'**
  String get huntStatusFound;

  /// No description provided for @huntStatusAbandoned.
  ///
  /// In en, this message translates to:
  /// **'gave up'**
  String get huntStatusAbandoned;

  /// No description provided for @huntStatusActive.
  ///
  /// In en, this message translates to:
  /// **'in progress'**
  String get huntStatusActive;

  /// No description provided for @statsEngagement.
  ///
  /// In en, this message translates to:
  /// **'Curiosity'**
  String get statsEngagement;

  /// No description provided for @statsScans.
  ///
  /// In en, this message translates to:
  /// **'QR scans'**
  String get statsScans;

  /// No description provided for @statsUniqueScans.
  ///
  /// In en, this message translates to:
  /// **'Unique codes'**
  String get statsUniqueScans;

  /// No description provided for @statsViews.
  ///
  /// In en, this message translates to:
  /// **'Places opened'**
  String get statsViews;

  /// No description provided for @statsUniqueViews.
  ///
  /// In en, this message translates to:
  /// **'Unique places read'**
  String get statsUniqueViews;

  /// No description provided for @statsFavorites.
  ///
  /// In en, this message translates to:
  /// **'In favorites'**
  String get statsFavorites;

  /// No description provided for @statsUserPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places added'**
  String get statsUserPlaces;

  /// No description provided for @statsPlacesLoaded.
  ///
  /// In en, this message translates to:
  /// **'Places fetched from sources'**
  String get statsPlacesLoaded;

  /// No description provided for @statsExploration.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get statsExploration;

  /// No description provided for @statsExploredArea.
  ///
  /// In en, this message translates to:
  /// **'Area explored'**
  String get statsExploredArea;

  /// No description provided for @statsExploredCells.
  ///
  /// In en, this message translates to:
  /// **'Map cells visited'**
  String get statsExploredCells;

  /// No description provided for @statsStepsPerDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Steps per discovery'**
  String get statsStepsPerDiscovery;

  /// No description provided for @statsMetersPerDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Distance per discovery'**
  String get statsMetersPerDiscovery;

  /// No description provided for @statsAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements {unlocked}/{total}'**
  String statsAchievements(Object unlocked, Object total);

  /// No description provided for @statsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics'**
  String get statsReset;

  /// No description provided for @statsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'All steps, routes, searches and discoveries will be deleted from this device. Favorites and your places stay.'**
  String get statsResetConfirm;

  /// No description provided for @statsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Statistics cleared'**
  String get statsResetDone;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Go for a walk — stats will appear here'**
  String get statsEmpty;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get noData;

  /// No description provided for @unitM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitM;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitH.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitH;

  /// No description provided for @unitMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// No description provided for @unitS.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get unitS;

  /// No description provided for @unitKmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get unitKmh;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitKm2.
  ///
  /// In en, this message translates to:
  /// **'km²'**
  String get unitKm2;

  /// No description provided for @achFirstDiscovery.
  ///
  /// In en, this message translates to:
  /// **'First find'**
  String get achFirstDiscovery;

  /// No description provided for @achFirstDiscoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover your first place'**
  String get achFirstDiscoveryDesc;

  /// No description provided for @achTenDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Local historian'**
  String get achTenDiscoveries;

  /// No description provided for @achTenDiscoveriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover 10 places'**
  String get achTenDiscoveriesDesc;

  /// No description provided for @achFiftyDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Chronicler'**
  String get achFiftyDiscoveries;

  /// No description provided for @achFiftyDiscoveriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover 50 places'**
  String get achFiftyDiscoveriesDesc;

  /// No description provided for @achFirstHunt.
  ///
  /// In en, this message translates to:
  /// **'Pathfinder'**
  String get achFirstHunt;

  /// No description provided for @achFirstHuntDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a search'**
  String get achFirstHuntDesc;

  /// No description provided for @achFiveHunts.
  ///
  /// In en, this message translates to:
  /// **'Treasure hunter'**
  String get achFiveHunts;

  /// No description provided for @achFiveHuntsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 searches'**
  String get achFiveHuntsDesc;

  /// No description provided for @achStraightShooter.
  ///
  /// In en, this message translates to:
  /// **'Straight to the point'**
  String get achStraightShooter;

  /// No description provided for @achStraightShooterDesc.
  ///
  /// In en, this message translates to:
  /// **'Find a place with detour ratio ≤ 1.3'**
  String get achStraightShooterDesc;

  /// No description provided for @achTenKDay.
  ///
  /// In en, this message translates to:
  /// **'10,000 steps'**
  String get achTenKDay;

  /// No description provided for @achTenKDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk 10,000 steps in one day'**
  String get achTenKDayDesc;

  /// No description provided for @achHundredKTotal.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achHundredKTotal;

  /// No description provided for @achHundredKTotalDesc.
  ///
  /// In en, this message translates to:
  /// **'100,000 steps in total'**
  String get achHundredKTotalDesc;

  /// No description provided for @achMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get achMarathon;

  /// No description provided for @achMarathonDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk 42.2 km in total'**
  String get achMarathonDesc;

  /// No description provided for @achExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get achExplorer;

  /// No description provided for @achExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore 1 km² of the map'**
  String get achExplorerDesc;

  /// No description provided for @achScanner.
  ///
  /// In en, this message translates to:
  /// **'Code breaker'**
  String get achScanner;

  /// No description provided for @achScannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan 10 QR codes'**
  String get achScannerDesc;

  /// No description provided for @achAllSources.
  ///
  /// In en, this message translates to:
  /// **'Polymath'**
  String get achAllSources;

  /// No description provided for @achAllSourcesDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover a place from every source'**
  String get achAllSourcesDesc;

  /// No description provided for @achWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week of history'**
  String get achWeekStreak;

  /// No description provided for @achWeekStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Be active 7 days in a row'**
  String get achWeekStreakDesc;

  /// No description provided for @achTimeTraveler.
  ///
  /// In en, this message translates to:
  /// **'Time traveler'**
  String get achTimeTraveler;

  /// No description provided for @achTimeTravelerDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover something from before 1917'**
  String get achTimeTravelerDesc;

  /// No description provided for @achCurator.
  ///
  /// In en, this message translates to:
  /// **'Curator'**
  String get achCurator;

  /// No description provided for @achCuratorDesc.
  ///
  /// In en, this message translates to:
  /// **'Save 10 favorites'**
  String get achCuratorDesc;

  /// No description provided for @achCartographer.
  ///
  /// In en, this message translates to:
  /// **'Cartographer'**
  String get achCartographer;

  /// No description provided for @achCartographerDesc.
  ///
  /// In en, this message translates to:
  /// **'Add 3 places of your own'**
  String get achCartographerDesc;

  /// No description provided for @sectionSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get sectionSources;

  /// No description provided for @sectionTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get sectionTracking;

  /// No description provided for @searchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get searchRadius;

  /// No description provided for @backgroundTracking.
  ///
  /// In en, this message translates to:
  /// **'Background tracking'**
  String get backgroundTracking;

  /// No description provided for @backgroundTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep counting steps and route with the screen off (shows a notification)'**
  String get backgroundTrackingSubtitle;

  /// No description provided for @autoTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking automatically'**
  String get autoTracking;

  /// No description provided for @autoTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When the map opens'**
  String get autoTrackingSubtitle;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily step goal'**
  String get dailyGoal;

  /// No description provided for @stepLength.
  ///
  /// In en, this message translates to:
  /// **'Step length'**
  String get stepLength;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @geofenceRadius.
  ///
  /// In en, this message translates to:
  /// **'Arrival radius'**
  String get geofenceRadius;

  /// No description provided for @geofenceRadiusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How close counts as \"found\"'**
  String get geofenceRadiusSubtitle;

  /// No description provided for @sourcePastvuDesc.
  ///
  /// In en, this message translates to:
  /// **'Retro photos from a community of local historians'**
  String get sourcePastvuDesc;

  /// No description provided for @sourceWikipediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Articles about places nearby'**
  String get sourceWikipediaDesc;

  /// No description provided for @sourceWikidataDesc.
  ///
  /// In en, this message translates to:
  /// **'Registered cultural heritage sites'**
  String get sourceWikidataDesc;

  /// No description provided for @sourceOsmDesc.
  ///
  /// In en, this message translates to:
  /// **'Monuments, memorials, ruins from OpenStreetMap'**
  String get sourceOsmDesc;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About QStory'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover history around you'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'QStory finds historical places, retro photos and heritage sites around you using open data from history communities and encyclopedias. Pick a place, walk to it, and track how far you went to find it.'**
  String get aboutDescription;

  /// No description provided for @aboutDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Where the data comes from'**
  String get aboutDataTitle;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyText.
  ///
  /// In en, this message translates to:
  /// **'No accounts, no servers of our own. Your routes, steps and statistics never leave the device. To find places nearby the app sends only the map area coordinates to the open-data APIs listed above; reminders and exports happen only when you turn them on.'**
  String get aboutPrivacyText;

  /// No description provided for @aboutLicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicenseTitle;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// No description provided for @aboutReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get aboutReportIssue;

  /// No description provided for @aboutTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get aboutTeam;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @explorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorerTitle;

  /// No description provided for @statsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open statistics'**
  String get statsOpen;

  /// No description provided for @openEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}'**
  String openEmailFailed(Object email);

  /// No description provided for @emailOpened.
  ///
  /// In en, this message translates to:
  /// **'Opening your email app…'**
  String get emailOpened;

  /// No description provided for @locationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location is needed for the map and tracking'**
  String get locationNeeded;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @huntEta.
  ///
  /// In en, this message translates to:
  /// **'≈ {time} · ≈ {steps} steps to go'**
  String huntEta(Object time, Object steps);

  /// No description provided for @nearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No places nearby} =1{1 place nearby} other{{count} places nearby}}'**
  String nearbyTitle(int count);

  /// No description provided for @nearbyFromMapCenter.
  ///
  /// In en, this message translates to:
  /// **'Distances from the map centre — turn on location for distances from you.'**
  String get nearbyFromMapCenter;

  /// No description provided for @nearbyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing found here yet. Move the map or widen the search radius in Settings.'**
  String get nearbyEmpty;

  /// No description provided for @nearbyAction.
  ///
  /// In en, this message translates to:
  /// **'Places list'**
  String get nearbyAction;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Walk there'**
  String get directions;

  /// No description provided for @directionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No map app could open the route'**
  String get directionsUnavailable;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data (JSON)'**
  String get exportData;

  /// No description provided for @exportSubject.
  ///
  /// In en, this message translates to:
  /// **'QStory — my data'**
  String get exportSubject;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the data'**
  String get exportFailed;

  /// No description provided for @statsGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached!'**
  String get statsGoalReached;

  /// No description provided for @statsStepsToGoal.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps to the goal'**
  String statsStepsToGoal(Object steps);

  /// No description provided for @statsWeekSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps, last 7 days'**
  String get statsWeekSteps;

  /// No description provided for @statsWeekDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance, last 7 days'**
  String get statsWeekDistance;

  /// No description provided for @statsWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Previous 7 days: {value}'**
  String statsWeekHint(Object value);

  /// No description provided for @milestoneGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached: {goal} steps!'**
  String milestoneGoal(Object goal);

  /// No description provided for @milestoneAchievement.
  ///
  /// In en, this message translates to:
  /// **'New achievement: {name}'**
  String milestoneAchievement(Object name);

  /// No description provided for @reminderFactTitle.
  ///
  /// In en, this message translates to:
  /// **'On this day in {year}'**
  String reminderFactTitle(String year);

  /// No description provided for @reminder1Title.
  ///
  /// In en, this message translates to:
  /// **'Time for a walk?'**
  String get reminder1Title;

  /// No description provided for @reminder1Body.
  ///
  /// In en, this message translates to:
  /// **'There are historical places near you that you haven\'t found yet.'**
  String get reminder1Body;

  /// No description provided for @reminder2Title.
  ///
  /// In en, this message translates to:
  /// **'History around the corner'**
  String get reminder2Title;

  /// No description provided for @reminder2Body.
  ///
  /// In en, this message translates to:
  /// **'Open the map and pick a place to hunt for today.'**
  String get reminder2Body;

  /// No description provided for @reminder3Title.
  ///
  /// In en, this message translates to:
  /// **'Steps with a story'**
  String get reminder3Title;

  /// No description provided for @reminder3Body.
  ///
  /// In en, this message translates to:
  /// **'A short walk to an old building counts towards your daily goal.'**
  String get reminder3Body;

  /// No description provided for @reminder4Title.
  ///
  /// In en, this message translates to:
  /// **'Explore a new street'**
  String get reminder4Title;

  /// No description provided for @reminder4Body.
  ///
  /// In en, this message translates to:
  /// **'Every 250 × 250 m square you visit adds to the explored area.'**
  String get reminder4Body;

  /// No description provided for @reminder5Title.
  ///
  /// In en, this message translates to:
  /// **'A place is waiting'**
  String get reminder5Title;

  /// No description provided for @reminder5Body.
  ///
  /// In en, this message translates to:
  /// **'Find one historical place today and keep your streak going.'**
  String get reminder5Body;

  /// No description provided for @reminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderChannel;

  /// No description provided for @reminderChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Once-a-day reminder to go for a walk'**
  String get reminderChannelDesc;

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed. Enable them for QStory in the system settings.'**
  String get notificationsPermissionDenied;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @reminderDykTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get reminderDykTitle;

  /// No description provided for @reminderNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Near you: {place}'**
  String reminderNearbyTitle(String place);

  /// No description provided for @trackingNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Recording your walk and steps'**
  String get trackingNotificationText;

  /// No description provided for @trackingNotificationChannel.
  ///
  /// In en, this message translates to:
  /// **'Walk tracking'**
  String get trackingNotificationChannel;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @aboutAuthorBoris.
  ///
  /// In en, this message translates to:
  /// **'Boris Stankov'**
  String get aboutAuthorBoris;

  /// No description provided for @aboutAuthorAndrey.
  ///
  /// In en, this message translates to:
  /// **'Andrey Kornev'**
  String get aboutAuthorAndrey;

  /// No description provided for @aboutRoleMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile · Flutter'**
  String get aboutRoleMobile;

  /// No description provided for @aboutRoleHistory.
  ///
  /// In en, this message translates to:
  /// **'History research'**
  String get aboutRoleHistory;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
