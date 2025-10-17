import 'package:intl/intl.dart';
import 'app_localizations.dart';

class AppLocalizationsPl extends AppLocalizations {
  @override
  String get appTitle => 'Kąpino Wywóz Śmieci';

  @override
  String get nextCollection => 'Następny Wywóz';

  @override
  String get collectionDate => 'Data Wywozu';

  @override
  String get wasteCategories => 'Kategorie Odpadów';

  @override
  String get noUpcomingCollections => 'Brak zaplanowanych wywozów';

  @override
  String get pleaseUpdateApp =>
      'Proszę zaktualizować aplikację, aby pobrać nowy harmonogram wywozu.';

  @override
  String get settings => 'Ustawienia';

  @override
  String get notificationTime => 'Czas Powiadomienia';

  @override
  String get daysInAdvance => 'Dni Wcześniej';

  @override
  String get daysInAdvanceDescription =>
      'Ile dni przed wywozem wysłać powiadomienie (0 = w dniu wywozu)';

  @override
  String get notificationPermissions => 'Uprawnienia Powiadomień';

  @override
  String get permissionsEnabled => 'Powiadomienia są włączone';

  @override
  String get permissionsDisabled => 'Powiadomienia są wyłączone';

  @override
  String get openAppSettings => 'Otwórz Ustawienia Aplikacji';

  @override
  String get testNotification => 'Testowe Powiadomienie';

  @override
  String get testNotificationTitle => 'Testowe Powiadomienie';

  @override
  String get testNotificationBody =>
      'To jest testowe powiadomienie. Twoje powiadomienia działają poprawnie!';

  @override
  String get saveSettings => 'Zapisz Ustawienia';

  @override
  String get collectionReminder => 'Przypomnienie o Wywozie Śmieci';

  @override
  String collectionTomorrow(String categories) =>
      'Jutro: $categories';

  @override
  String collectionToday(String categories) =>
      'Dziś: $categories';

  @override
  String collectionInDays(int days, String categories) =>
      'Za $days dni: $categories';

  @override
  String get updateAppTitle => 'Wymagana Aktualizacja';

  @override
  String get updateAppBody =>
      'Proszę zaktualizować aplikację, aby pobrać nowy harmonogram wywozu śmieci.';

  @override
  String getCategoryName(String categoryKey) {
    const categoryNames = {
      'MIXED': 'Odpady zmieszane',
      'BIO': 'Odpady bio (kuchenne)',
      'PLASTIC': 'Plastik/Metal/Opakowania wielomateriałowe',
      'PAPER': 'Makulatura',
      'GLASS': 'Szkło',
      'ASH': 'Popiół',
      'GREEN': 'Odpady zielone',
      'BULKY': 'Odpady wielkogabarytowe (należy umówić)',
      'CHRISTMAS_TREES': 'Choinki',
    };
    return categoryNames[categoryKey] ?? categoryKey;
  }

  @override
  String formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'pl_PL').format(date);
  }

  @override
  String get today => 'Dziś';

  @override
  String get tomorrow => 'Jutro';

  @override
  String daysUntil(int days) => 'Za $days dni';

  @override
  String get retry => 'Ponów';

  @override
  String errorMessage(String error) => 'Błąd: $error';

  @override
  String get day => 'dzień';

  @override
  String get days => 'dni';
}


