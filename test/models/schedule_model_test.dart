import 'package:flutter_test/flutter_test.dart';
import 'package:kapino_rubbish_collection/models/schedule_model.dart';

void main() {
  group('ScheduleEvent', () {
    test('fromJson creates valid ScheduleEvent', () {
      // Arrange
      final json = {
        'date': '2025-01-15',
        'categories': ['MIXED', 'BIO'],
      };

      // Act
      final event = ScheduleEvent.fromJson(json);

      // Assert
      expect(event.date, DateTime(2025, 1, 15));
      expect(event.categories, ['MIXED', 'BIO']);
    });

    test('isAfter returns true when event is after given date', () {
      // Arrange
      final event = ScheduleEvent(
        date: DateTime(2025, 1, 15),
        categories: ['MIXED'],
      );
      final compareDate = DateTime(2025, 1, 10);

      // Act & Assert
      expect(event.isAfter(compareDate), isTrue);
    });

    test('isAfter returns false when event is before given date', () {
      // Arrange
      final event = ScheduleEvent(
        date: DateTime(2025, 1, 10),
        categories: ['MIXED'],
      );
      final compareDate = DateTime(2025, 1, 15);

      // Act & Assert
      expect(event.isAfter(compareDate), isFalse);
    });

    test('isSameDay returns true for same day', () {
      // Arrange
      final event = ScheduleEvent(
        date: DateTime(2025, 1, 15, 10, 30),
        categories: ['MIXED'],
      );
      final compareDate = DateTime(2025, 1, 15, 14, 45);

      // Act & Assert
      expect(event.isSameDay(compareDate), isTrue);
    });

    test('isSameDay returns false for different day', () {
      // Arrange
      final event = ScheduleEvent(
        date: DateTime(2025, 1, 15),
        categories: ['MIXED'],
      );
      final compareDate = DateTime(2025, 1, 16);

      // Act & Assert
      expect(event.isSameDay(compareDate), isFalse);
    });
  });

  group('CategoryInfo', () {
    test('fromJson creates valid CategoryInfo', () {
      // Arrange
      final json = {
        'name_pl': 'Odpady zmieszane',
        'name_en': 'Mixed waste',
      };

      // Act
      final categoryInfo = CategoryInfo.fromJson(json);

      // Assert
      expect(categoryInfo.namePl, 'Odpady zmieszane');
      expect(categoryInfo.nameEn, 'Mixed waste');
    });
  });

  group('ScheduleMeta', () {
    test('fromJson creates valid ScheduleMeta', () {
      // Arrange
      final json = {
        'area': 'Wejherowo Bolszewo-Kąpino',
        'route_day_hint_pl': 'Poniedziałek',
        'year': 2025,
        'timezone': 'Europe/Warsaw',
        'source_pdf_url': 'https://example.com/schedule.pdf',
      };

      // Act
      final meta = ScheduleMeta.fromJson(json);

      // Assert
      expect(meta.area, 'Wejherowo Bolszewo-Kąpino');
      expect(meta.routeDayHintPl, 'Poniedziałek');
      expect(meta.year, 2025);
      expect(meta.timezone, 'Europe/Warsaw');
      expect(meta.sourcePdfUrl, 'https://example.com/schedule.pdf');
    });
  });

  group('Schedule', () {
    test('fromJson creates valid Schedule', () {
      // Arrange
      final json = {
        'meta': {
          'area': 'Test Area',
          'route_day_hint_pl': 'Monday',
          'year': 2025,
          'timezone': 'Europe/Warsaw',
          'source_pdf_url': 'https://example.com/schedule.pdf',
        },
        'categories': {
          'MIXED': {
            'name_pl': 'Zmieszane',
            'name_en': 'Mixed',
          },
          'BIO': {
            'name_pl': 'Bio',
            'name_en': 'Bio',
          },
        },
        'events': [
          {
            'date': '2025-01-15',
            'categories': ['MIXED'],
          },
          {
            'date': '2025-01-20',
            'categories': ['BIO'],
          },
        ],
      };

      // Act
      final schedule = Schedule.fromJson(json);

      // Assert
      expect(schedule.meta.area, 'Test Area');
      expect(schedule.categories.length, 2);
      expect(schedule.categories['MIXED']?.namePl, 'Zmieszane');
      expect(schedule.events.length, 2);
      expect(schedule.events[0].date, DateTime(2025, 1, 15));
    });
  });
}

