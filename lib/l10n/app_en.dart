import 'package:intl/intl.dart';
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'Kąpino Rubbish Collection';

  @override
  String get nextCollection => 'Next Collection';

  @override
  String get collectionDate => 'Collection Date';

  @override
  String get wasteCategories => 'Waste Categories';

  @override
  String get noUpcomingCollections => 'No upcoming collections';

  @override
  String get pleaseUpdateApp =>
      'Please update the app to get the new collection schedule.';

  @override
  String get settings => 'Settings';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get daysInAdvance => 'Days in Advance';

  @override
  String get daysInAdvanceDescription =>
      'How many days before collection to notify (0 = on collection day)';

  @override
  String get notificationPermissions => 'Notification Permissions';

  @override
  String get permissionsEnabled => 'Notifications are enabled';

  @override
  String get permissionsDisabled => 'Notifications are disabled';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationTitle => 'Test Notification';

  @override
  String get testNotificationBody =>
      'This is a test notification. Your notifications are working correctly!';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get collectionReminder => 'Rubbish Collection Reminder';

  @override
  String collectionTomorrow(String categories) =>
      'Tomorrow: $categories';

  @override
  String collectionToday(String categories) =>
      'Today: $categories';

  @override
  String collectionInDays(int days, String categories) =>
      'In $days days: $categories';

  @override
  String get updateAppTitle => 'Update Required';

  @override
  String get updateAppBody =>
      'Please update the app to get the new rubbish collection schedule.';

  @override
  String getCategoryName(String categoryKey) {
    const categoryNames = {
      'MIXED': 'Mixed waste',
      'BIO': 'Bio (kitchen)',
      'PLASTIC': 'Plastic/Metal/Multimaterial',
      'PAPER': 'Paper',
      'GLASS': 'Glass',
      'ASH': 'Ash',
      'GREEN': 'Green waste',
      'BULKY': 'Bulky waste (by appointment)',
      'CHRISTMAS_TREES': 'Christmas trees',
    };
    return categoryNames[categoryKey] ?? categoryKey;
  }

  @override
  String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy', 'en_US').format(date);
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String daysUntil(int days) => 'In $days days';

  @override
  String get retry => 'Retry';

  @override
  String errorMessage(String error) => 'Error: $error';

  @override
  String get day => 'day';

  @override
  String get days => 'days';
}


