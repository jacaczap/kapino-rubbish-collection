import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapino_rubbish_collection/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SettingsService service;

    setUp(() {
      service = SettingsService();
      SharedPreferences.setMockInitialValues({});
    });

    test('loadSettings returns default values when no settings saved', () async {
      // Act
      final settings = await service.loadSettings();

      // Assert
      expect(settings.notificationTime.hour, SettingsService.defaultHour);
      expect(
        settings.notificationTime.minute,
        SettingsService.defaultMinute,
      );
      expect(settings.daysInAdvance, SettingsService.defaultDaysInAdvance);
    });

    test('saveSettings persists settings correctly', () async {
      // Arrange
      final settings = UserSettings(
        notificationTime: const TimeOfDay(hour: 10, minute: 30),
        daysInAdvance: 2,
      );

      // Act
      await service.saveSettings(settings);
      final loadedSettings = await service.loadSettings();

      // Assert
      expect(loadedSettings.notificationTime.hour, 10);
      expect(loadedSettings.notificationTime.minute, 30);
      expect(loadedSettings.daysInAdvance, 2);
    });

    test('loadSettings retrieves previously saved settings', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'notification_hour': 9,
        'notification_minute': 45,
        'days_in_advance': 3,
      });

      // Act
      final settings = await service.loadSettings();

      // Assert
      expect(settings.notificationTime.hour, 9);
      expect(settings.notificationTime.minute, 45);
      expect(settings.daysInAdvance, 3);
    });
  });

  group('UserSettings', () {
    test('copyWith creates new instance with updated values', () {
      // Arrange
      final original = UserSettings(
        notificationTime: const TimeOfDay(hour: 8, minute: 0),
        daysInAdvance: 1,
      );

      // Act
      final updated = original.copyWith(daysInAdvance: 3);

      // Assert
      expect(updated.notificationTime.hour, 8);
      expect(updated.notificationTime.minute, 0);
      expect(updated.daysInAdvance, 3);
    });

    test('copyWith creates new instance with updated time', () {
      // Arrange
      final original = UserSettings(
        notificationTime: const TimeOfDay(hour: 8, minute: 0),
        daysInAdvance: 1,
      );

      // Act
      final updated = original.copyWith(
        notificationTime: const TimeOfDay(hour: 10, minute: 30),
      );

      // Assert
      expect(updated.notificationTime.hour, 10);
      expect(updated.notificationTime.minute, 30);
      expect(updated.daysInAdvance, 1);
    });
  });
}

