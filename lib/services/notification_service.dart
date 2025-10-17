import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'schedule_service.dart';
import 'settings_service.dart';
import '../models/schedule_model.dart';

/// Service for managing local notifications.
///
/// Handles initialization, scheduling, and sending of collection reminder
/// notifications. Uses a singleton pattern to ensure consistent state.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final ScheduleService _scheduleService = ScheduleService();
  final SettingsService _settingsService = SettingsService();

  bool _initialized = false;

  /// Initializes the notification system.
  ///
  /// Sets up timezone data, notification channels, and tap handlers.
  /// Safe to call multiple times - initialization only happens once.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      'collection_reminders',
      'Collection Reminders',
      description: 'Notifications about upcoming rubbish collection',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    developer.log(
      'Notification tapped',
      name: 'kapino.notifications',
      level: 500, // INFO
    );
  }

  /// Schedules all collection reminder notifications.
  ///
  /// Cancels any existing notifications and schedules new ones based
  /// on the provided [schedule] and current user settings.
  /// Notifications are localized using [languageCode].
  Future<void> scheduleAllNotifications(
      String languageCode, Schedule schedule) async {
    await initialize();

    // Cancel all existing notifications
    await _notifications.cancelAll();

    final settings = await _settingsService.loadSettings();
    final futureEvents = await _scheduleService.getFutureCollections();

    // Schedule collection reminders
    for (int i = 0; i < futureEvents.length; i++) {
      final event = futureEvents[i];
      await _scheduleCollectionNotification(
        event,
        schedule,
        settings,
        languageCode,
        i,
      );
    }

    // Schedule end-of-year update reminder
    await _scheduleUpdateReminder(languageCode);
  }

  Future<void> _scheduleCollectionNotification(
    ScheduleEvent event,
    Schedule schedule,
    UserSettings settings,
    String languageCode,
    int notificationId,
  ) async {
    // Calculate notification date
    final notificationDate = event.date.subtract(
      Duration(days: settings.daysInAdvance),
    );

    // Create notification time with user's preferred time
    final scheduledDate = tz.TZDateTime(
      tz.local,
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      settings.notificationTime.hour,
      settings.notificationTime.minute,
    );

    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    // Format categories
    final categoryNames = event.categories
        .map((cat) =>
            _scheduleService.getCategoryNameForLocale(schedule, cat, languageCode))
        .join(', ');

    // Create notification body based on days in advance
    String body;
    if (settings.daysInAdvance == 0) {
      body = languageCode == 'pl'
          ? 'Dziś: $categoryNames'
          : 'Today: $categoryNames';
    } else if (settings.daysInAdvance == 1) {
      body = languageCode == 'pl'
          ? 'Jutro: $categoryNames'
          : 'Tomorrow: $categoryNames';
    } else {
      body = languageCode == 'pl'
          ? 'Za ${settings.daysInAdvance} dni: $categoryNames'
          : 'In ${settings.daysInAdvance} days: $categoryNames';
    }

    final title = languageCode == 'pl'
        ? 'Przypomnienie o Wywozie Śmieci'
        : 'Rubbish Collection Reminder';

    const androidDetails = AndroidNotificationDetails(
      'collection_reminders',
      'Collection Reminders',
      channelDescription: 'Notifications about upcoming rubbish collection',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleUpdateReminder(String languageCode) async {
    final lastEvent = await _scheduleService.getLastCollection();
    if (lastEvent == null) return;

    // Schedule for one day after the last collection
    final updateDate = lastEvent.date.add(const Duration(days: 1));
    
    final scheduledDate = tz.TZDateTime(
      tz.local,
      updateDate.year,
      updateDate.month,
      updateDate.day,
      8, // 8:00 AM
      0,
    );

    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final title = languageCode == 'pl'
        ? 'Wymagana Aktualizacja'
        : 'Update Required';

    final body = languageCode == 'pl'
        ? 'Proszę zaktualizować aplikację, aby pobrać nowy harmonogram wywozu śmieci.'
        : 'Please update the app to get the new rubbish collection schedule.';

    const androidDetails = AndroidNotificationDetails(
      'collection_reminders',
      'Collection Reminders',
      channelDescription: 'Notifications about upcoming rubbish collection',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      999999, // Special ID for update reminder
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Sends an immediate test notification.
  ///
  /// Used to verify that notifications are working correctly.
  /// Notification content is localized using [languageCode].
  Future<void> sendTestNotification(String languageCode) async {
    await initialize();

    final title = languageCode == 'pl'
        ? 'Testowe Powiadomienie'
        : 'Test Notification';

    final body = languageCode == 'pl'
        ? 'To jest testowe powiadomienie. Twoje powiadomienia działają poprawnie!'
        : 'This is a test notification. Your notifications are working correctly!';

    const androidDetails = AndroidNotificationDetails(
      'collection_reminders',
      'Collection Reminders',
      channelDescription: 'Notifications about upcoming rubbish collection',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}


