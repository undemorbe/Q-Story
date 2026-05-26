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
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'QStory'**
  String get appTitle;

  /// No description provided for @generateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate QR'**
  String get generateQr;

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

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan Result'**
  String get scanResult;

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

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Login with Biometrics'**
  String get loginWithBiometrics;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey'**
  String get registerSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover History'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Explore historical events and figures from around the world.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Codes'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Scan QR codes at museums and historical sites to unlock content.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Save Favorites'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your favorite historical moments.'**
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

  /// No description provided for @chroniclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Chronicles'**
  String get chroniclesTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the chronicles...'**
  String get searchHint;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecordsFound;

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

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get scanned;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

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
  /// **'Receive daily historical facts'**
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

  /// No description provided for @dataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data Saver'**
  String get dataSaver;

  /// No description provided for @dataSaverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce image quality'**
  String get dataSaverSubtitle;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExported;

  /// No description provided for @dataImported.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImported;

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

  /// No description provided for @enterData.
  ///
  /// In en, this message translates to:
  /// **'Enter Data'**
  String get enterData;

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
  /// **'Receive interesting historical facts'**
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
  /// **'Each day at the selected time you will receive notifications with interesting historical facts and events.'**
  String get aboutNotificationsText;

  /// No description provided for @notificationsWorkInDnd.
  ///
  /// In en, this message translates to:
  /// **'Notifications work even in Do Not Disturb mode'**
  String get notificationsWorkInDnd;

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

  /// No description provided for @createMarkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Marker'**
  String get createMarkerTitle;

  /// No description provided for @markerSection.
  ///
  /// In en, this message translates to:
  /// **'Map Marker'**
  String get markerSection;

  /// No description provided for @buildingSection.
  ///
  /// In en, this message translates to:
  /// **'Object (QR)'**
  String get buildingSection;

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

  /// No description provided for @markerCompressedField.
  ///
  /// In en, this message translates to:
  /// **'Compressed description (marker)'**
  String get markerCompressedField;

  /// No description provided for @buildingNameField.
  ///
  /// In en, this message translates to:
  /// **'Object name'**
  String get buildingNameField;

  /// No description provided for @buildingCompressedField.
  ///
  /// In en, this message translates to:
  /// **'Compressed description'**
  String get buildingCompressedField;

  /// No description provided for @descTopField.
  ///
  /// In en, this message translates to:
  /// **'Upper description'**
  String get descTopField;

  /// No description provided for @descMainField.
  ///
  /// In en, this message translates to:
  /// **'Main description'**
  String get descMainField;

  /// No description provided for @descBottomField.
  ///
  /// In en, this message translates to:
  /// **'Lower description'**
  String get descBottomField;

  /// No description provided for @personField.
  ///
  /// In en, this message translates to:
  /// **'Related person'**
  String get personField;

  /// No description provided for @dateStartField.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get dateStartField;

  /// No description provided for @dateEndField.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get dateEndField;

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

  /// No description provided for @resourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'SOURCES'**
  String get resourcesLabel;

  /// No description provided for @resourceItem.
  ///
  /// In en, this message translates to:
  /// **'Source {n}'**
  String resourceItem(int n);

  /// No description provided for @addResource.
  ///
  /// In en, this message translates to:
  /// **'Add source'**
  String get addResource;

  /// No description provided for @atLeastOneResource.
  ///
  /// In en, this message translates to:
  /// **'Add at least one source'**
  String get atLeastOneResource;

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

  /// No description provided for @submittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get submittingLabel;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @markerPublished.
  ///
  /// In en, this message translates to:
  /// **'Marker published'**
  String get markerPublished;

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

  /// No description provided for @refreshingMap.
  ///
  /// In en, this message translates to:
  /// **'Refreshing the map…'**
  String get refreshingMap;

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

  /// No description provided for @statusFilter.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFilter;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get filterNotCompleted;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// No description provided for @markedAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Marked as completed!'**
  String get markedAsCompleted;
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
      <String>['en', 'ru'].contains(locale.languageCode);

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
      'that was used.');
}
