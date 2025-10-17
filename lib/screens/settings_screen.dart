import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/schedule_service.dart';

/// Screen for managing user settings and notification preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.notificationService,
    required this.scheduleService,
  });

  final SettingsService settingsService;
  final NotificationService notificationService;
  final ScheduleService scheduleService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late UserSettings _settings;
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkNotificationPermissions();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _checkNotificationPermissions() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status.isGranted;
    });

    if (!status.isGranted) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.permissionsDisabled),
            action: SnackBarAction(
              label: l10n.openAppSettings,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    // Capture context-dependent values before async gap
    final languageCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.settingsService.saveSettings(_settings);

      // Reschedule all notifications with new settings
      final schedule = await widget.scheduleService.loadSchedule();
      await widget.notificationService.scheduleAllNotifications(
          languageCode, schedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveSettings),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _sendTestNotification() async {
    if (!_notificationsEnabled) {
      await _requestNotificationPermissions();
      return;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    await widget.notificationService.sendTestNotification(languageCode);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.testNotificationTitle),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notification Time
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.notificationTime),
              subtitle: Text(
                _settings.notificationTime.format(context),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _settings.notificationTime,
                );
                if (time != null) {
                  setState(() {
                    _settings = _settings.copyWith(notificationTime: time);
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Days in Advance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        l10n.daysInAdvance,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.daysInAdvanceDescription,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_settings.daysInAdvance} ${_settings.daysInAdvance == 1 ? l10n.day : l10n.days}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _settings.daysInAdvance > 0
                                ? () {
                                    setState(() {
                                      _settings = _settings.copyWith(
                                          daysInAdvance:
                                              _settings.daysInAdvance - 1);
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _settings.daysInAdvance < 7
                                ? () {
                                    setState(() {
                                      _settings = _settings.copyWith(
                                          daysInAdvance:
                                              _settings.daysInAdvance + 1);
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: _settings.daysInAdvance.toDouble(),
                    min: 0,
                    max: 7,
                    divisions: 7,
                    label: _settings.daysInAdvance.toString(),
                    onChanged: (value) {
                      setState(() {
                        _settings =
                            _settings.copyWith(daysInAdvance: value.toInt());
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notification Permissions
          Card(
            child: ListTile(
              leading: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? Colors.green : Colors.red,
              ),
              title: Text(l10n.notificationPermissions),
              subtitle: Text(
                _notificationsEnabled
                    ? l10n.permissionsEnabled
                    : l10n.permissionsDisabled,
                style: TextStyle(
                  color: _notificationsEnabled ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: !_notificationsEnabled
                  ? ElevatedButton(
                      onPressed: () => openAppSettings(),
                      child: Text(l10n.openAppSettings),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Test Notification Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.testNotification),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(l10n.saveSettings),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

