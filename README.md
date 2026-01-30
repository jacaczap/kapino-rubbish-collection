# Kąpino Rubbish Collection App

A Flutter mobile application for Android that notifies users about upcoming rubbish collection based on a predefined schedule for the Kąpino/Bolszewo area in Wejherowo.

## Features

- 📅 **Next Collection Display**: Shows the next upcoming rubbish collection date and categories
- 🔔 **Customizable Notifications**: Set notification time and how many days in advance (0-7 days)
- 🌍 **Bilingual Support**: Automatic language selection (Polish for Polish devices, English for others)
- ⚙️ **Simple Settings**: Easy-to-use interface for managing notification preferences
- 🧪 **Test Notifications**: Verify your notifications are working correctly
- 🔒 **Permission Management**: Clear indication of notification permission status

## Requirements

- Flutter SDK 3.9.2 or higher
- Android device running Android 5.0 (API level 21) or higher
- For Android 13+: Notification permissions are required

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd kapino_rubbish_collection
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Building for Release

To build an app for release:

```bash
flutter build appbundle
```

The bundle will be available at: `build/app/outputs/bundle/release/app-release.aab`

## Dependencies

- `flutter_local_notifications` - Local notifications with Android 13+ support
- `shared_preferences` - User preferences storage
- `timezone` - Timezone support for scheduling notifications
- `intl` - Date formatting and localization
- `permission_handler` - Notification permission handling

## Schedule Update

The app includes a JSON schedule file for 2025. To update for future years:

1. Create a new schedule JSON file following the same format
2. Place it in the `assets/` directory
3. Update the file reference in `lib/services/schedule_service.dart`
4. Update the asset reference in `pubspec.yaml`
5. Build and release a new version

### Schedule JSON Format

```json
{
  "meta": {
    "area": "Area Name",
    "route_day_hint_pl": "Day name in Polish",
    "year": 2025,
    "timezone": "Europe/Warsaw",
    "source_pdf_url": "https://..."
  },
  "categories": {
    "CATEGORY_KEY": {
      "name_pl": "Polish name",
      "name_en": "English name"
    }
  },
  "events": [
    {
      "date": "2025-01-10",
      "categories": ["MIXED", "BIO"]
    }
  ]
}
```

## Settings

Users can customize:
- **Notification Time**: Choose what time notifications should appear (default: 8:00 AM)
- **Days in Advance**: Set how many days before collection to be notified (0-7 days, default: 1 day)
  - 0 days = notification on the collection day
  - 1 day = notification the day before
  - etc.

## App Structure

```
lib/
├── l10n/                      # Localization files
│   ├── app_localizations.dart # Base localization class
│   ├── app_en.dart           # English translations
│   └── app_pl.dart           # Polish translations
├── models/                    # Data models
│   └── schedule_model.dart   # Schedule, event, and category models
├── screens/                   # UI screens
│   ├── home_screen.dart      # Main screen showing next collection
│   └── settings_screen.dart  # Settings management screen
├── services/                  # Business logic services
│   ├── notification_service.dart  # Notification scheduling
│   ├── schedule_service.dart      # Schedule loading and parsing
│   └── settings_service.dart      # User preferences management
└── main.dart                 # App entry point
```

## Notification Behavior

- Notifications are scheduled automatically when the app starts
- When settings are changed, all notifications are rescheduled
- An end-of-year notification is sent one day after the last collection to remind users to update the app
- Notifications include the waste categories to be collected in the user's language

## Permissions

The app requires the following Android permissions:
- `POST_NOTIFICATIONS` - Show notifications to the user
- `SCHEDULE_EXACT_ALARM` - Schedule exact notifications
- `USE_EXACT_ALARM` - Use exact alarm timing
- `RECEIVE_BOOT_COMPLETED` - Restore notifications after device restart
- `VIBRATE` - Vibrate on notification
- `WAKE_LOCK` - Wake device for notifications

## License

[Add your license here]

## Support

For issues or questions, please contact [your contact information]
