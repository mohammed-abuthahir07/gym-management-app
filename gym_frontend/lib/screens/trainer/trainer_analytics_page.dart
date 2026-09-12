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

  // ============================================================
  // FETCH TODAY WORKOUT ANALYTICS
  // ============================================================

  Future<void> _fetchAnalytics() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/analytics/today-workouts',
      );

      if (!mounted) return;

      List<Map<String, dynamic>> workouts = [];

      if (response is Map) {
        final dynamic data =
            response['workouts'] ?? response['data'];

        if (data is List) {
          workouts = asMapList(data);
        }
      } else if (response is List) {
        workouts = asMapList(response);
      }

      setState(() {
        _todayWorkouts = workouts;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load today workout analytics.';
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildWorkoutContent(theme, scheme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Workout Progression",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Live trainee completion status for today's scheduled exercises.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _fetchAnalytics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
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
                    "Today's Workout Progression",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Live trainee completion status for today's scheduled exercises.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            OutlinedButton.icon(
              onPressed: _loading ? null : _fetchAnalytics,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // WORKOUT CONTENT
  // ============================================================

  Widget _buildWorkoutContent(
    ThemeData theme,
    ColorScheme scheme,
  ) {
    if (_todayWorkouts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 50,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 52,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No assigned workouts scheduled for trainees today.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0;
            index < _todayWorkouts.length;
            index++) ...[
          _WorkoutProgressCard(
            workout: _todayWorkouts[index],
          ),
          if (index != _todayWorkouts.length - 1)
            const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ==================================================================
// WORKOUT PROGRESS CARD
// ==================================================================

class _WorkoutProgressCard extends StatelessWidget {
  const _WorkoutProgressCard({
    required this.workout,
  });

  final Map<String, dynamic> workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final memberName = asString(
      workout['member_name'] ?? workout['name'],
      'Trainee',
    );

    final planName = asString(
      workout['plan_name'] ?? workout['workout_name'],
      'Daily Routine',
    );

    final totalExercises = _readNum(
      workout['total_exercises'] ?? workout['total'],
    );

    final completedExercises = _readNum(
      workout['completed_exercises'] ?? workout['completed'],
    );

    final remainingValue = workout['remaining_exercises'];

    final remainingExercises = remainingValue != null
        ? _readNum(remainingValue)
        : _calculateRemaining(
            totalExercises,
            completedExercises,
          );

    final status = asString(
      workout['status'],
      _calculateStatus(
        totalExercises,
        completedExercises,
      ),
    ).toUpperCase();

    final progress = totalExercises > 0
        ? (completedExercises / totalExercises)
            .clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;

            if (isMobile) {
              return _buildMobileCard(
                context,
                theme,
                scheme,
                memberName,
                planName,
                totalExercises,
                completedExercises,
                remainingExercises,
                status,
                progress,
              );
            }

            return _buildDesktopCard(
              context,
              theme,
              scheme,
              memberName,
              planName,
              totalExercises,
              completedExercises,
              remainingExercises,
              status,
              progress,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE CARD
  // ============================================================

  Widget _buildMobileCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    String memberName,
    String planName,
    num totalExercises,
    num completedExercises,
    num remainingExercises,
    String status,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: scheme.primary.withValues(
                alpha: 0.10,
              ),
              child: Icon(
                Icons.person_pin,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plan: $planName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        _buildStatusBadge(
          context,
          status,
        ),

        const SizedBox(height: 18),

        _buildProgressSection(
          context,
          progress,
          totalExercises,
          completedExercises,
          remainingExercises,
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP CARD
  // ============================================================

  Widget _buildDesktopCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    String memberName,
    String planName,
    num totalExercises,
    num completedExercises,
    num remainingExercises,
    String status,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: scheme.primary.withValues(
                alpha: 0.10,
              ),
              child: Icon(
                Icons.person_pin,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plan: $planName',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildStatusBadge(
              context,
              status,
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildProgressSection(
          context,
          progress,
          totalExercises,
          completedExercises,
          remainingExercises,
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS SECTION
  // ============================================================

  Widget _buildProgressSection(
    BuildContext context,
    double progress,
    num totalExercises,
    num completedExercises,
    num remainingExercises,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final percentage =
        (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 9,
          borderRadius: BorderRadius.circular(6),
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 450;

            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completedExercises / $totalExercises exercises completed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Remaining: $remainingExercises',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$percentage% complete',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Text(
                    '$completedExercises / $totalExercises exercises completed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Remaining: $remainingExercises',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
  ) {
    final positive = status == 'COMPLETED';

    return StatusBadge(
      label: status,
      positive: positive,
    );
  }

  // ============================================================
  // SAFE NUMBER READER
  // ============================================================

  num _readNum(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value;
    }

    return num.tryParse(
          value.toString(),
        ) ??
        0;
  }

  // ============================================================
  // REMAINING
  // ============================================================

  num _calculateRemaining(
    num total,
    num completed,
  ) {
    final remaining = total - completed;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }

  // ============================================================
  // STATUS FALLBACK
  // ============================================================

  String _calculateStatus(
    num total,
    num completed,
  ) {
    if (total <= 0) {
      return 'NOT_STARTED';
    }

    if (completed >= total) {
      return 'COMPLETED';
    }

    if (completed > 0) {
      return 'IN_PROGRESS';
    }

    return 'NOT_STARTED';
  }
}