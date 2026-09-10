import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerCheatDaysPage extends StatefulWidget {
  const TrainerCheatDaysPage({super.key});

  @override
  State<TrainerCheatDaysPage> createState() => _TrainerCheatDaysPageState();
}

class _TrainerCheatDaysPageState extends State<TrainerCheatDaysPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _currentMonth = [];
  List<Map<String, dynamic>> _previousMonth = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCheatMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCheatMonitoring() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/trainer/cheat-days/current-month').catchError((_) => <String, dynamic>{}),
        api.get('/api/trainer/cheat-days/previous-month').catchError((_) => <String, dynamic>{}),
      ]);

      final curRes = results[0] as Map<String, dynamic>;
      final prevRes = results[1] as Map<String, dynamic>;

      setState(() {
        _currentMonth = asMapList(curRes['cheat_days']);
        _previousMonth = asMapList(prevRes['cheat_days']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainee cheat logs.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchCheatMonitoring,
      isEmpty: false,
      emptyMessage: '',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trainee Cheat Day Monitoring', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Observe caloric spikes and assist trainees in remaining accountable.'),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetchCheatMonitoring,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Current Month Entries', icon: Icon(Icons.calendar_month)),
                    Tab(text: 'Previous Month Entries', icon: Icon(Icons.history)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCheatList(_currentMonth, 'No cheat meals logged by your trainees this month!'),
                      _buildCheatList(_previousMonth, 'No cheat records logged for the previous month.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheatList(List<Map<String, dynamic>> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = list[idx];
        final memberName = asString(item['member_name'], 'Trainee');
        final memberEmail = asString(item['member_email']);
        final food = asString(item['food_name'], 'Cheat Meal');
        final qty = asString(item['quantity']);
        final cal = asNum(item['calories']);
        final date = asString(item['cheat_date']).split('T').first;
        final notes = asString(item['notes']);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.error.withValues(alpha: 0.1),
                  child: Icon(Icons.fastfood, color: scheme.error, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$memberName — $food', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(date, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Trainee: $memberEmail • Portion: $qty • $cal kcal', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Trainee note: "$notes"', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
