import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  @override
  State<TrainerDashboardPage> createState() =>
      _TrainerDashboardPageState();
}

class _TrainerDashboardPageState
    extends State<TrainerDashboardPage> {
  bool _loading = true;
  String? _error;

  num _assignedMembers = 0;
  num _dietPlans = 0;
  num _workoutPlans = 0;

  List<Map<String, dynamic>> _checkIns = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchDashboard();
      }
    });
  }

  // ============================================================
  // FETCH DASHBOARD
  // ============================================================

  Future<void> _fetchDashboard() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      final results = await Future.wait<dynamic>([
        api.get('/api/trainer/dashboard/assigned-members'),
        api.get('/api/trainer/dashboard/diet-plans'),
        api.get('/api/trainer/dashboard/workout-plans'),
        api
            .get('/api/trainer/dashboard/check-ins')
            .catchError((_) => <String, dynamic>{}),
      ]);

      if (!mounted) return;

      // ==========================================================
      // SAFE RESPONSE CONVERSION
      // ==========================================================

      final memRes = results[0] is Map
          ? Map<String, dynamic>.from(results[0] as Map)
          : <String, dynamic>{};

      final dietRes = results[1] is Map
          ? Map<String, dynamic>.from(results[1] as Map)
          : <String, dynamic>{};

      final workoutRes = results[2] is Map
          ? Map<String, dynamic>.from(results[2] as Map)
          : <String, dynamic>{};

      final checkinRes = results[3] is Map
          ? Map<String, dynamic>.from(results[3] as Map)
          : <String, dynamic>{};

      // ==========================================================
      // UPDATE DATA
      // ==========================================================

      setState(() {
        _assignedMembers = asNum(memRes['total']);
        _dietPlans = asNum(dietRes['total']);
        _workoutPlans = asNum(workoutRes['total']);
        _checkIns = asMapList(checkinRes['members']);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load trainer dashboard.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  _DashboardHeader(
                    onRefresh: _fetchDashboard,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // STAT CARDS
                  // ==================================================

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = Responsive.gridCount(
                        context,
                        mobile: 1,
                        tablet: 3,
                        desktop: 3,
                      );

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          // ------------------------------------------------
                          // FIXED: Increased mobile height to 140 to 
                          // completely prevent bottom overflow.
                          // ------------------------------------------------
                          mainAxisExtent: Responsive.isMobile(context)
                              ? 140
                              : 135,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _CompactStatCard(
                              title: 'Assigned Trainees',
                              value: '$_assignedMembers Members',
                              icon: Icons.groups_outlined,
                            );
                          }

                          if (index == 1) {
                            return _CompactStatCard(
                              title: 'Active Workout Blueprints',
                              value: '$_workoutPlans Plans',
                              icon: Icons.fitness_center_outlined,
                            );
                          }

                          return _CompactStatCard(
                            title: 'Target Nutrition Diets',
                            value: '$_dietPlans Meals',
                            icon: Icons.restaurant_outlined,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // CHECK-IN CONSISTENCY
                  // ==================================================

                  _CheckInSection(
                    checkIns: _checkIns,
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

// ======================================================================
// DASHBOARD HEADER
// ======================================================================

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainer Dashboard',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Roster overview, active plans, and member consistency.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Refresh',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trainer Dashboard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Roster overview, active plans, and member consistency.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

// ======================================================================
// COMPACT STAT CARD
// ======================================================================

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 20,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// CHECK-IN SECTION
// ======================================================================

class _CheckInSection extends StatelessWidget {
  const _CheckInSection({
    required this.checkIns,
  });

  final List<Map<String, dynamic>> checkIns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trainee Check-in Consistency',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 6),
            if (checkIns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No trainee check-in logs recorded for this period.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkIns.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
                itemBuilder: (context, index) {
                  final item = checkIns[index];

                  final name = asString(
                    item['member_name'],
                    'Member',
                  );

                  final days = asNum(
                    item['check_in_days'],
                  );

                  return _CheckInRow(
                    name: name,
                    days: days,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// CHECK-IN ROW
// ======================================================================

class _CheckInRow extends StatelessWidget {
  const _CheckInRow({
    required this.name,
    required this.days,
  });

  final String name;
  final num days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: scheme.primary.withValues(alpha: 0.10),
            child: Icon(
              Icons.person_outline,
              color: scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Monthly Gym Attendance: $days days',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: StatusBadge(
              label: '$days Days',
              positive: days >= 10,
            ),
          ),
        ],
      ),
    );
  }
}