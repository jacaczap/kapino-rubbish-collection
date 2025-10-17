import 'package:flutter/foundation.dart';

/// Represents a complete rubbish collection schedule.
///
/// Contains metadata about the schedule area and year, category definitions,
/// and a list of collection events.
@immutable
class Schedule {
  /// Metadata about the schedule (area, year, timezone).
  final ScheduleMeta meta;

  /// Map of category keys to their localized information.
  final Map<String, CategoryInfo> categories;

  /// List of all collection events in chronological order.
  final List<ScheduleEvent> events;

  /// Creates a new [Schedule] instance.
  Schedule({
    required this.meta,
    required this.categories,
    required this.events,
  });

  /// Creates a [Schedule] from a JSON map.
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final categoriesMap = <String, CategoryInfo>{};
    (json['categories'] as Map<String, dynamic>).forEach((key, value) {
      categoriesMap[key] = CategoryInfo.fromJson(value as Map<String, dynamic>);
    });

    final eventsList = (json['events'] as List)
        .map((e) => ScheduleEvent.fromJson(e as Map<String, dynamic>))
        .toList();

    return Schedule(
      meta: ScheduleMeta.fromJson(json['meta'] as Map<String, dynamic>),
      categories: categoriesMap,
      events: eventsList,
    );
  }
}

/// Metadata about a rubbish collection schedule.
///
/// Contains information about the geographical area, year, timezone,
/// and source document for the schedule.
@immutable
class ScheduleMeta {
  /// The geographical area covered by this schedule.
  final String area;

  /// Hint about collection day routes in Polish.
  final String routeDayHintPl;

  /// The year this schedule is valid for.
  final int year;

  /// The timezone for all dates in this schedule.
  final String timezone;

  /// URL to the source PDF document.
  final String sourcePdfUrl;

  /// Creates a new [ScheduleMeta] instance.
  ScheduleMeta({
    required this.area,
    required this.routeDayHintPl,
    required this.year,
    required this.timezone,
    required this.sourcePdfUrl,
  });

  /// Creates a [ScheduleMeta] from a JSON map.
  factory ScheduleMeta.fromJson(Map<String, dynamic> json) {
    return ScheduleMeta(
      area: json['area'] as String,
      routeDayHintPl: json['route_day_hint_pl'] as String,
      year: json['year'] as int,
      timezone: json['timezone'] as String,
      sourcePdfUrl: json['source_pdf_url'] as String,
    );
  }
}

/// Information about a waste category.
///
/// Contains localized names for a specific waste collection category.
@immutable
class CategoryInfo {
  /// Polish name for this waste category.
  final String namePl;

  /// English name for this waste category.
  final String nameEn;

  /// Creates a new [CategoryInfo] instance.
  CategoryInfo({
    required this.namePl,
    required this.nameEn,
  });

  /// Creates a [CategoryInfo] from a JSON map.
  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      namePl: json['name_pl'] as String,
      nameEn: json['name_en'] as String,
    );
  }
}

/// Represents a single rubbish collection event.
///
/// Contains the date and list of waste categories to be collected.
@immutable
class ScheduleEvent {
  /// The date when collection will occur.
  final DateTime date;

  /// List of category keys for waste types being collected on this date.
  final List<String> categories;

  /// Creates a new [ScheduleEvent] instance.
  ScheduleEvent({
    required this.date,
    required this.categories,
  });

  /// Creates a [ScheduleEvent] from a JSON map.
  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      date: DateTime.parse(json['date'] as String),
      categories: (json['categories'] as List).map((e) => e as String).toList(),
    );
  }

  /// Returns true if this event's date is after [other].
  bool isAfter(DateTime other) {
    return date.isAfter(other);
  }

  /// Returns true if this event occurs on the same day as [other].
  bool isSameDay(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}


