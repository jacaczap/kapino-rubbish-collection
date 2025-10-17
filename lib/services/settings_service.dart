import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user settings persistence.
///
/// Handles loading and saving user preferences such as notification time
/// and days in advance for collection reminders.
class SettingsService {
  static const String _keyNotificationHour = 'notification_hour';
  static const String _keyNotificationMinute = 'notification_minute';
  static const String _keyDaysInAdvance = 'days_in_advance';

  // Default values
  static const int defaultHour = 8;
  static const int defaultMinute = 0;
  static const int defaultDaysInAdvance = 1;

  /// Loads user settings from persistent storage.
  ///
  /// Returns default values if no settings have been saved previously.
  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final hour = prefs.getInt(_keyNotificationHour) ?? defaultHour;
    final minute = prefs.getInt(_keyNotificationMinute) ?? defaultMinute;
    final daysInAdvance = prefs.getInt(_keyDaysInAdvance) ?? defaultDaysInAdvance;

    return UserSettings(
      notificationTime: TimeOfDay(hour: hour, minute: minute),
      daysInAdvance: daysInAdvance,
    );
  }

  /// Saves user settings to persistent storage.
  ///
  /// Stores notification time and days in advance preferences.
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_keyNotificationHour, settings.notificationTime.hour);
    await prefs.setInt(_keyNotificationMinute, settings.notificationTime.minute);
    await prefs.setInt(_keyDaysInAdvance, settings.daysInAdvance);
  }
}

/// User preferences for collection notifications.
///
/// Contains settings for when and how often to receive
/// rubbish collection reminders.
@immutable
class UserSettings {
  /// Time of day to send notifications.
  final TimeOfDay notificationTime;

  /// How many days before collection to send reminder (0-7).
  final int daysInAdvance;

  /// Creates a new [UserSettings] instance.
  UserSettings({
    required this.notificationTime,
    required this.daysInAdvance,
  });

  /// Creates a copy of these settings with optional field overrides.
  UserSettings copyWith({
    TimeOfDay? notificationTime,
    int? daysInAdvance,
  }) {
    return UserSettings(
      notificationTime: notificationTime ?? this.notificationTime,
      daysInAdvance: daysInAdvance ?? this.daysInAdvance,
    );
  }
}


