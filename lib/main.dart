import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/schedule_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final scheduleService = ScheduleService();
  final settingsService = SettingsService();
  
  runApp(MyApp(
    notificationService: notificationService,
    scheduleService: scheduleService,
    settingsService: settingsService,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.notificationService,
    required this.scheduleService,
    required this.settingsService,
  });

  final NotificationService notificationService;
  final ScheduleService scheduleService;
  final SettingsService settingsService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Request notification permissions
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    // Schedule initial notifications
    try {
      final schedule = await widget.scheduleService.loadSchedule();
      
      // Use system locale for initial scheduling
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = locale.languageCode;
      
      await widget.notificationService.scheduleAllNotifications(
        languageCode,
        schedule,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to schedule initial notifications',
        name: 'kapino.app.init',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // SEVERE
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kąpino Rubbish Collection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          // Use Polish if device language is Polish
          if (locale.languageCode == 'pl') {
            return const Locale('pl', 'PL');
          }
        }
        // Default to English
        return const Locale('en', 'US');
      },
      home: HomeScreen(
        scheduleService: widget.scheduleService,
        notificationService: widget.notificationService,
        settingsService: widget.settingsService,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
