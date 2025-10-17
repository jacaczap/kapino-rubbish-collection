import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_pl.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('pl', 'PL'),
  ];

  // App title
  String get appTitle;
  
  // Home screen
  String get nextCollection;
  String get collectionDate;
  String get wasteCategories;
  String get noUpcomingCollections;
  String get pleaseUpdateApp;
  
  // Settings screen
  String get settings;
  String get notificationTime;
  String get daysInAdvance;
  String get daysInAdvanceDescription;
  String get notificationPermissions;
  String get permissionsEnabled;
  String get permissionsDisabled;
  String get openAppSettings;
  String get testNotification;
  String get testNotificationTitle;
  String get testNotificationBody;
  String get saveSettings;
  
  // Notification messages
  String get collectionReminder;
  String collectionTomorrow(String categories);
  String collectionToday(String categories);
  String collectionInDays(int days, String categories);
  String get updateAppTitle;
  String get updateAppBody;
  
  // Waste categories
  String getCategoryName(String categoryKey);
  
  // Date formatting
  String formatDate(DateTime date);
  
  // Time expressions
  String get today;
  String get tomorrow;
  String daysUntil(int days);
  
  // Error handling
  String get retry;
  String errorMessage(String error);
  
  // Days label
  String get day;
  String get days;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'pl') {
      return AppLocalizationsPl();
    }
    return AppLocalizationsEn();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


