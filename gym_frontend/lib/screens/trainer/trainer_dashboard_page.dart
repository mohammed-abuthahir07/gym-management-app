import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  bool _loading = true;
  String? _error;

  num _assignedMembers = 0;
  num _dietPlans = 0;
  num _workoutPlans = 0;
  List<Map<String, dynamic>> _checkIns = [];

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
        api.get('/api/trainer/dashboard/assigned-members'),
        api.get('/api/trainer/dashboard/diet-plans'),
        api.get('/api/trainer/dashboard/workout-plans'),
        api.get('/api/trainer/dashboard/check-ins').catchError((_) => <String, dynamic>{}),
      ]);

      final memRes = results[0] as Map<String, dynamic>;
      final dietRes = results[1] as Map<String, dynamic>;
      final workoutRes = results[2] as Map<String, dynamic>;
      final checkinRes = results[3] as Map<String, dynamic>;

      setState(() {
        _assignedMembers = asNum(memRes['total']);
        _dietPlans = asNum(dietRes['total']);
        _workoutPlans = asNum(workoutRes['total']);
        _checkIns = asMapList(checkinRes['members']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainer dashboard.');
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
                          Text('Trainer Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Roster overview, active plans, and member consistency.'),
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
                      final cols = Responsive.gridCount(context, mobile: 1, tablet: 3, desktop: 3);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 2.0 : 1.6,
                        children: [
                          StatCard(
                            title: 'Assigned Trainees',
                            value: '$_assignedMembers Members',
                            icon: Icons.groups_outlined,
                          ),
                          StatCard(
                            title: 'Active Workout Blueprints',
                            value: '$_workoutPlans Plans',
                            icon: Icons.fitness_center_outlined,
                          ),
                          StatCard(
                            title: 'Target Nutrition Diets',
                            value: '$_dietPlans Meals',
                            icon: Icons.restaurant_outlined,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Member Check-in Consistency
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_available, color: scheme.primary),
                              const SizedBox(width: 8),
                              Text('Trainee Check-in Consistency', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_checkIns.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('No trainee check-in logs recorded for this period.'),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _checkIns.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = _checkIns[idx];
                                final name = asString(item['member_name'], 'Member');
                                final days = asNum(item['check_in_days']);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.person_outline, color: scheme.primary),
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Monthly Gym Attendance: $days days'),
                                  trailing: StatusBadge(
                                    label: '$days Days',
                                    positive: days >= 10,
                                  ),
                                );
                              },
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
