import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/schedule_model.dart';

/// Service for loading and querying rubbish collection schedules.
///
/// Handles loading the schedule from assets and provides methods to query
/// for upcoming collections and category information.
class ScheduleService {
  Schedule? _cachedSchedule;

  /// Loads the schedule from the bundled JSON asset.
  ///
  /// Results are cached for subsequent calls. Returns the parsed [Schedule].
  Future<Schedule> loadSchedule() async {
    if (_cachedSchedule != null) {
      return _cachedSchedule!;
    }

    final String jsonString = await rootBundle.loadString(
        'assets/wejherowo_bolszewo-kapino_2026_schedule.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    _cachedSchedule = Schedule.fromJson(jsonData);
    return _cachedSchedule!;
  }

  /// Returns the next upcoming collection event.
  ///
  /// Returns null if there are no more collections in the schedule.
  Future<ScheduleEvent?> getNextCollection() async {
    final schedule = await loadSchedule();
    final now = DateTime.now();

    // Find the next collection event after today
    for (final event in schedule.events) {
      if (event.date.isAfter(now) || event.isSameDay(now)) {
        return event;
      }
    }

    return null;
  }

  /// Returns all future collection events including today.
  ///
  /// Events are returned in chronological order.
  Future<List<ScheduleEvent>> getFutureCollections() async {
    final schedule = await loadSchedule();
    final now = DateTime.now();

    return schedule.events
        .where((event) => event.date.isAfter(now) || event.isSameDay(now))
        .toList();
  }

  /// Returns the last collection event in the schedule.
  ///
  /// Returns null if the schedule is empty.
  Future<ScheduleEvent?> getLastCollection() async {
    final schedule = await loadSchedule();
    if (schedule.events.isEmpty) return null;
    return schedule.events.last;
  }

  /// Gets the localized name for a category.
  ///
  /// Returns the category name in the specified [languageCode] language.
  /// Falls back to [categoryKey] if the category is not found.
  String getCategoryNameForLocale(
      Schedule schedule, String categoryKey, String languageCode) {
    final category = schedule.categories[categoryKey];
    if (category == null) return categoryKey;

    return languageCode == 'pl' ? category.namePl : category.nameEn;
  }

  /// Clears the cached schedule data.
  ///
  /// Forces the next call to [loadSchedule] to reload from assets.
  void clearCache() {
    _cachedSchedule = null;
  }
}


