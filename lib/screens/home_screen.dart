import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../models/schedule_model.dart';
import 'settings_screen.dart';

/// Main screen displaying the next collection date and waste categories.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.scheduleService,
    required this.notificationService,
    required this.settingsService,
  });

  final ScheduleService scheduleService;
  final NotificationService notificationService;
  final SettingsService settingsService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScheduleEvent? _nextCollection;
  Schedule? _schedule;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNextCollection();
  }

  Future<void> _loadNextCollection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schedule = await widget.scheduleService.loadSchedule();
      final nextCollection = await widget.scheduleService.getNextCollection();
      
      setState(() {
        _schedule = schedule;
        _nextCollection = nextCollection;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    settingsService: widget.settingsService,
                    notificationService: widget.notificationService,
                    scheduleService: widget.scheduleService,
                  ),
                ),
              );
              // Reload after returning from settings
              _loadNextCollection();
            },
          ),
        ],
      ),
      body: _buildBody(l10n, languageCode),
    );
  }

  Widget _buildBody(AppLocalizations l10n, String languageCode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: _loadNextCollection,
      );
    }

    if (_nextCollection == null) {
      return _EmptyStateView(l10n: l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadNextCollection,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NextCollectionCard(
              l10n: l10n,
              event: _nextCollection!,
              daysUntilText: _getDaysUntilText(context, _nextCollection!.date),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.wasteCategories,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...(_nextCollection!.categories.map((category) {
              final categoryName = _schedule != null
                  ? widget.scheduleService.getCategoryNameForLocale(
                      _schedule!, category, languageCode)
                  : category;
              return _CategoryListItem(
                categoryKey: category,
                categoryName: categoryName,
              );
            })),
          ],
        ),
      ),
    );
  }

  String _getDaysUntilText(BuildContext context, DateTime collectionDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final collection = DateTime(
        collectionDate.year, collectionDate.month, collectionDate.day);
    final daysUntil = collection.difference(today).inDays;

    final l10n = AppLocalizations.of(context);

    if (daysUntil == 0) {
      return l10n.today;
    } else if (daysUntil == 1) {
      return l10n.tomorrow;
    } else {
      return l10n.daysUntil(daysUntil);
    }
  }
}

/// Widget displaying the next collection date and countdown.
class _NextCollectionCard extends StatelessWidget {
  const _NextCollectionCard({
    required this.l10n,
    required this.event,
    required this.daysUntilText,
  });

  final AppLocalizations l10n;
  final ScheduleEvent event;
  final String daysUntilText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.nextCollection,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.formatDate(event.date),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              daysUntilText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying a single waste category item.
class _CategoryListItem extends StatelessWidget {
  const _CategoryListItem({
    required this.categoryKey,
    required this.categoryName,
  });

  final String categoryKey;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getCategoryIcon(categoryKey),
          color: _getCategoryColor(categoryKey),
          size: 32,
        ),
        title: Text(
          categoryName,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'MIXED':
        return Icons.delete;
      case 'BIO':
        return Icons.compost;
      case 'PLASTIC':
        return Icons.recycling;
      case 'PAPER':
        return Icons.article;
      case 'GLASS':
        return Icons.wine_bar;
      case 'ASH':
        return Icons.fireplace;
      case 'GREEN':
        return Icons.grass;
      case 'BULKY':
        return Icons.weekend;
      case 'CHRISTMAS_TREES':
        return Icons.park;
      default:
        return Icons.delete_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'MIXED':
        return Colors.grey;
      case 'BIO':
        return Colors.brown;
      case 'PLASTIC':
        return Colors.yellow[700]!;
      case 'PAPER':
        return Colors.blue;
      case 'GLASS':
        return Colors.green;
      case 'ASH':
        return Colors.deepOrange;
      case 'GREEN':
        return Colors.lightGreen;
      case 'BULKY':
        return Colors.purple;
      case 'CHRISTMAS_TREES':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

/// Widget displaying error state with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorMessage(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying empty state when no collections are scheduled.
class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUpcomingCollections,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pleaseUpdateApp,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

