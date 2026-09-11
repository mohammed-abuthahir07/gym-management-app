import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberDashboardPage extends StatefulWidget {
  const MemberDashboardPage({super.key});

  @override
  State<MemberDashboardPage> createState() => _MemberDashboardPageState();
}

class _MemberDashboardPageState extends State<MemberDashboardPage> {
  bool _loading = true;
  String? _error;

  num _checkinDays = 0;
  num _cheatCount = 0;
  num _workoutPlansCount = 0;
  num _unreadNotifications = 0;
  Map<String, dynamic>? _previousMonthProgress;
  List<Map<String, dynamic>> _todayWorkouts = [];
  List<Map<String, dynamic>> _todayDiet = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      final results = await Future.wait([
        api.get('/api/member/dashboard/checkin-days'),
        api.get('/api/member/dashboard/cheat-count'),
        api.get('/api/member/dashboard/workout-plans'),
        api.get('/api/member/dashboard/notifications'),
        api.get('/api/member/dashboard/previous-month-progress').catchError((_) => <String, dynamic>{}),
        api.get('/api/member/dashboard/today-workout').catchError((_) => <String, dynamic>{}),
        api.get('/api/member/dashboard/diet-plan').catchError((_) => <String, dynamic>{}),
      ]);

      final checkinRes = results[0] as Map<String, dynamic>;
      final cheatRes = results[1] as Map<String, dynamic>;
      final workoutRes = results[2] as Map<String, dynamic>;
      final notifRes = results[3] as Map<String, dynamic>;
      final prevRes = results[4] as Map<String, dynamic>;
      final todayWRes = results[5] as Map<String, dynamic>;
      final dietRes = results[6] as Map<String, dynamic>;

      setState(() {
        _checkinDays = asNum(checkinRes['total']);
        _cheatCount = asNum(cheatRes['total']);
        _workoutPlansCount = asNum(workoutRes['total']);
        _unreadNotifications = asNum(notifRes['total']);
        _previousMonthProgress = prevRes['progress'] is Map ? Map<String, dynamic>.from(prevRes['progress'] as Map) : null;
        _todayWorkouts = asMapList(todayWRes['workouts']);
        _todayDiet = asMapList(dietRes['diet_plans']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Unable to load member dashboard metrics.');
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
      onRetry: _fetchDashboard,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Your current training and nutrition overview.'),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchDashboard,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stat Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 2, tablet: 2, desktop: 4);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Fixed: Lowered aspect ratio on mobile to give cards more height and prevent text overflow
                        childAspectRatio: Responsive.isMobile(context) ? 1.2 : 1.6,
                        children: [
                          StatCard(
                            title: 'Check-In Days',
                            value: '$_checkinDays Days',
                            icon: Icons.calendar_month,
                          ),
                          StatCard(
                            title: 'Workout Plans',
                            value: '$_workoutPlansCount Assigned',
                            icon: Icons.fitness_center,
                          ),
                          StatCard(
                            title: 'Month Cheat Count',
                            value: '$_cheatCount Meals',
                            icon: Icons.fastfood,
                          ),
                          StatCard(
                            title: 'Unread Alerts',
                            value: '$_unreadNotifications',
                            icon: Icons.notifications,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Today's Workout Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.today, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text("Today's Workout Plan", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_todayWorkouts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No workout scheduled for today. Great time for active recovery or rest!'),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _todayWorkouts.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, i) {
                                final w = _todayWorkouts[i];
                                final name = asString(w['exercise_name'], 'Exercise');
                                final group = asString(w['muscle_group']);
                                final sets = asNum(w['sets']);
                                final reps = asNum(w['reps']);
                                final duration = asNum(w['duration_minutes']);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.fitness_center, color: scheme.primary, size: 20),
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('$group • $sets Sets × $reps Reps ($duration mins)'),
                                  trailing: StatusBadge(label: asString(w['difficulty'], 'ACTIVE')),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Today's Diet Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text("Today's Nutrition Plan", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_todayDiet.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No meal plan assigned for today yet.'),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _todayDiet.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, i) {
                                final d = _todayDiet[i];
                                final meal = asString(d['meal_type']);
                                final food = asString(d['food_name']);
                                final cal = asNum(d['calories']);
                                final prot = asNum(d['protein']);
                                final notes = asString(d['notes']);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: scheme.secondary.withValues(alpha: 0.1),
                                    child: Icon(Icons.local_dining, color: scheme.secondary, size: 20),
                                  ),
                                  title: Text('$meal: $food', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('$cal kcal • $prot g protein ${notes.isNotEmpty ? '($notes)' : ''}'),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Previous Month Progress Card
                  if (_previousMonthProgress != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, color: scheme.primary),
                                const SizedBox(width: 8),
                                Text('Previous Month Progress Snapshot', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 24,
                              runSpacing: 12,
                              children: [
                                _SnapshotItem(label: 'Recorded Date', value: asString(_previousMonthProgress!['progress_date'])),
                                _SnapshotItem(label: 'Weight', value: '${asNum(_previousMonthProgress!['weight'])} kg'),
                                _SnapshotItem(label: 'Body Fat', value: '${asNum(_previousMonthProgress!['body_fat'])} %'),
                                _SnapshotItem(label: 'Waist', value: '${asNum(_previousMonthProgress!['waist_cm'])} cm'),
                                _SnapshotItem(label: 'Arms', value: '${asNum(_previousMonthProgress!['arms_cm'])} cm'),
                              ],
                            ),
                          ],
                        ),
                      ),
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

class _SnapshotItem extends StatelessWidget {
  const _SnapshotItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}