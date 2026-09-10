import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerAnalyticsPage extends StatefulWidget {
  const TrainerAnalyticsPage({super.key});

  @override
  State<TrainerAnalyticsPage> createState() => _TrainerAnalyticsPageState();
}

class _TrainerAnalyticsPageState extends State<TrainerAnalyticsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _todayWorkouts = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/trainer/analytics/today-workouts');
      List<dynamic> list = [];
      if (res is Map && (res['workouts'] is List || res['data'] is List)) {
        list = (res['workouts'] ?? res['data']) as List;
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _todayWorkouts = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load today workout analytics.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchAnalytics,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          Text("Today's Workout Progression", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Live trainee completion status for today\'s scheduled exercises.'),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchAnalytics,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_todayWorkouts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No assigned workouts scheduled for trainees today.')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todayWorkouts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final w = _todayWorkouts[idx];
                        final memberName = asString(w['member_name'] ?? w['name'], 'Trainee');
                        final planName = asString(w['plan_name'] ?? w['workout_name'], 'Daily Routine');
                        final totalEx = asNum(w['total_exercises'] ?? w['total']);
                        final completedEx = asNum(w['completed_exercises'] ?? w['completed']);
                        final remainingEx = asNum(w['remaining_exercises'] ?? (totalEx - completedEx));
                        final status = asString(w['status'], 'NOT_STARTED');

                        final progressFraction = totalEx > 0 ? (completedEx / totalEx).clamp(0.0, 1.0) : 0.0;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                          child: Icon(Icons.person_pin, color: scheme.primary),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('Plan: $planName', style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    StatusBadge(
                                      label: status,
                                      positive: status == 'COMPLETED',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: progressFraction.toDouble(),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Exercises: $completedEx / $totalEx Completed', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('Remaining: $remainingEx', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
