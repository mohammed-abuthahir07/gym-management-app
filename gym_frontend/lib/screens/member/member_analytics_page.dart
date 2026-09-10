import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberAnalyticsPage extends StatefulWidget {
  const MemberAnalyticsPage({super.key});

  @override
  State<MemberAnalyticsPage> createState() => _MemberAnalyticsPageState();
}

class _MemberAnalyticsPageState extends State<MemberAnalyticsPage> {
  bool _loading = true;
  String? _error;

  dynamic _checkins;
  dynamic _paymentStatus;
  dynamic _tomorrowWorkout;
  dynamic _cheatMeals;
  dynamic _monthProgress;

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
      final results = await Future.wait([
        api.get('/api/member/analytics/current-month-checkin-days').catchError((_) => null),
        api.get('/api/member/analytics/current-month-payment-status').catchError((_) => null),
        api.get('/api/member/analytics/tomorrow-workout').catchError((_) => null),
        api.get('/api/member/analytics/current-month-cheat-meals').catchError((_) => null),
        api.get('/api/member/analytics/current-month-progress').catchError((_) => null),
      ]);

      setState(() {
        _checkins = results[0];
        _paymentStatus = results[1];
        _tomorrowWorkout = results[2];
        _cheatMeals = results[3];
        _monthProgress = results[4];
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load member analytics.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    // Parse analytics values
    final checkinDays = asNum(_checkins is Map ? _checkins['total'] ?? _checkins['checkin_days'] : 0);
    final status = asString(_paymentStatus is Map ? _paymentStatus['status'] ?? _paymentStatus['payment_status'] : 'PAID');
    final cheatTotal = asNum(_cheatMeals is Map ? _cheatMeals['total'] ?? _cheatMeals['count'] : 0);

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
                          Text('Personal Fitness Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Detailed breakdown of this month\'s discipline and upcoming workouts.'),
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

                  // Analytics Cards Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 1.8 : 1.6,
                        children: [
                          StatCard(
                            title: 'Month Attendance / Check-Ins',
                            value: '$checkinDays Days Completed',
                            icon: Icons.check_circle_outline,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.payment_outlined, color: scheme.primary),
                                  const SizedBox(height: 12),
                                  const Text('Monthly Fee Status'),
                                  const SizedBox(height: 8),
                                  StatusBadge(label: status.toUpperCase(), positive: status.toUpperCase() == 'PAID'),
                                ],
                              ),
                            ),
                          ),
                          StatCard(
                            title: 'Month Cheat Meals Logged',
                            value: '$cheatTotal Treats',
                            icon: Icons.fastfood_outlined,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tomorrow Workout Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.next_plan_outlined, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text("Tomorrow's Workout Schedule", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_tomorrowWorkout == null || (_tomorrowWorkout is Map && (_tomorrowWorkout['workouts'] == null || (_tomorrowWorkout['workouts'] as List).isEmpty)))
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No workout scheduled for tomorrow or it is an active rest day.'),
                            )
                          else ...[
                            Text(
                              asString(_tomorrowWorkout is Map ? _tomorrowWorkout['plan_name'] ?? _tomorrowWorkout['day'] : 'Tomorrow'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_tomorrowWorkout is Map && _tomorrowWorkout['workouts'] is List)
                              ...asMapList(_tomorrowWorkout['workouts']).map((w) {
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.circle, size: 8),
                                  title: Text(asString(w['exercise_name'] ?? w['name'])),
                                  subtitle: Text('${asNum(w['sets'])} sets × ${asNum(w['reps'])} reps'),
                                );
                              }),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Current Month Progress Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_graph_outlined, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text("Current Month Progress Summary", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_monthProgress == null || (_monthProgress is Map && _monthProgress['progress'] == null))
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No measurement entries recorded yet this month.'),
                            )
                          else ...[
                            Builder(
                              builder: (context) {
                                final prog = _monthProgress is Map && _monthProgress['progress'] is Map
                                    ? _monthProgress['progress'] as Map
                                    : (_monthProgress as Map);
                                return Wrap(
                                  spacing: 24,
                                  runSpacing: 12,
                                  children: [
                                    _AnalyticItem(label: 'Latest Check-in', value: asString(prog['progress_date']).split('T').first),
                                    _AnalyticItem(label: 'Current Weight', value: '${asNum(prog['weight'])} kg'),
                                    _AnalyticItem(label: 'Body Fat %', value: '${asNum(prog['body_fat'])} %'),
                                    _AnalyticItem(label: 'Waist', value: '${asNum(prog['waist_cm'])} cm'),
                                    _AnalyticItem(label: 'Arms', value: '${asNum(prog['arms_cm'])} cm'),
                                  ],
                                );
                              },
                            ),
                          ],
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

class _AnalyticItem extends StatelessWidget {
  const _AnalyticItem({required this.label, required this.value});
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
