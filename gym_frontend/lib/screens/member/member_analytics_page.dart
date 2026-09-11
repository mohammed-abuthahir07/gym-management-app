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

  // ============================================================
  // API CALLS
  // ============================================================

  Future<dynamic> _safeGet(String endpoint) async {
    try {
      final api = context.read<ApiService>();
      return await api.get(endpoint);
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchAnalytics() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        _safeGet(
          '/api/member/analytics/current-month-checkin-days',
        ),
        _safeGet(
          '/api/member/analytics/current-month-payment-status',
        ),
        _safeGet(
          '/api/member/analytics/tomorrow-workout',
        ),
        _safeGet(
          '/api/member/analytics/current-month-cheat-meals',
        ),
        _safeGet(
          '/api/member/analytics/current-month-progress',
        ),
      ]);

      if (!mounted) return;

      final hasAnyData = results.any((result) => result != null);

      setState(() {
        _checkins = results[0];
        _paymentStatus = results[1];
        _tomorrowWorkout = results[2];
        _cheatMeals = results[3];
        _monthProgress = results[4];

        if (!hasAnyData) {
          _error = 'Failed to load member analytics.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load member analytics.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // SAFE VALUE HELPERS
  // ============================================================

  num _extractNumber(
    dynamic response,
    List<String> keys, {
    num defaultValue = 0,
  }) {
    if (response is num) {
      return response;
    }

    if (response is Map) {
      for (final key in keys) {
        final value = response[key];

        if (value is num) {
          return value;
        }

        if (value is String) {
          final parsed = num.tryParse(value);
          if (parsed != null) {
            return parsed;
          }
        }
      }

      // Sometimes API wraps the actual data inside "data".
      final data = response['data'];

      if (data is Map) {
        for (final key in keys) {
          final value = data[key];

          if (value is num) {
            return value;
          }

          if (value is String) {
            final parsed = num.tryParse(value);
            if (parsed != null) {
              return parsed;
            }
          }
        }
      }
    }

    return defaultValue;
  }

  String _extractString(
    dynamic response,
    List<String> keys, {
    String defaultValue = '',
  }) {
    if (response is String) {
      return response;
    }

    if (response is Map) {
      for (final key in keys) {
        final value = response[key];

        if (value != null) {
          final text = value.toString().trim();

          if (text.isNotEmpty) {
            return text;
          }
        }
      }

      final data = response['data'];

      if (data is Map) {
        for (final key in keys) {
          final value = data[key];

          if (value != null) {
            final text = value.toString().trim();

            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }
    }

    return defaultValue;
  }

  // ============================================================
  // CHECK-IN COUNT
  // ============================================================

  num get _checkinDays {
    return _extractNumber(
      _checkins,
      [
        'total',
        'checkin_days',
        'checkinDays',
        'days',
        'count',
      ],
    );
  }

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  String get _paymentStatusText {
    final status = _extractString(
      _paymentStatus,
      [
        'status',
        'payment_status',
        'paymentStatus',
      ],
      defaultValue: 'UNKNOWN',
    );

    return status.toUpperCase();
  }

  bool get _isPaymentPaid {
    final status = _paymentStatusText;

    return status == 'PAID' ||
        status == 'SUCCESS' ||
        status == 'COMPLETED';
  }

  // ============================================================
  // CHEAT MEALS
  // ============================================================

  num get _cheatMealCount {
    if (_cheatMeals is Map) {
      final map = _cheatMeals as Map;

      final direct = _extractNumber(
        map,
        [
          'total',
          'count',
          'cheat_meals',
          'cheatMeals',
        ],
      );

      if (direct != 0) {
        return direct;
      }

      final meals = map['cheat_meals'];

      if (meals is List) {
        return meals.length;
      }

      final data = map['data'];

      if (data is List) {
        return data.length;
      }
    }

    if (_cheatMeals is List) {
      return (_cheatMeals as List).length;
    }

    return 0;
  }

  // ============================================================
  // TOMORROW WORKOUT
  // ============================================================

  List<Map<String, dynamic>> get _tomorrowWorkoutList {
    if (_tomorrowWorkout is List) {
      return asMapList(_tomorrowWorkout);
    }

    if (_tomorrowWorkout is Map) {
      final map = _tomorrowWorkout as Map;

      if (map['workouts'] is List) {
        return asMapList(map['workouts']);
      }

      if (map['workout'] is List) {
        return asMapList(map['workout']);
      }

      if (map['data'] is List) {
        return asMapList(map['data']);
      }

      if (map['data'] is Map) {
        final data = map['data'];

        if (data['workouts'] is List) {
          return asMapList(data['workouts']);
        }

        if (data['workout'] is List) {
          return asMapList(data['workout']);
        }
      }
    }

    return [];
  }

  String get _tomorrowPlanName {
    return _extractString(
      _tomorrowWorkout,
      [
        'plan_name',
        'planName',
        'workout_name',
        'workoutName',
        'day',
        'workout_day',
      ],
      defaultValue: 'Tomorrow\'s Workout',
    );
  }

  // ============================================================
  // CURRENT MONTH PROGRESS
  // ============================================================

  Map<String, dynamic>? get _latestProgress {
    if (_monthProgress is List) {
      final list = asMapList(_monthProgress);

      if (list.isEmpty) {
        return null;
      }

      return list.first;
    }

    if (_monthProgress is Map) {
      final map = _monthProgress as Map;

      // progress is an object
      if (map['progress'] is Map) {
        return Map<String, dynamic>.from(
          map['progress'] as Map,
        );
      }

      // progress is a list
      if (map['progress'] is List) {
        final list = asMapList(map['progress']);

        if (list.isNotEmpty) {
          return list.first;
        }
      }

      // data is an object
      if (map['data'] is Map) {
        final data = map['data'];

        if (data['progress'] is Map) {
          return Map<String, dynamic>.from(
            data['progress'] as Map,
          );
        }

        return Map<String, dynamic>.from(data);
      }

      // data is a list
      if (map['data'] is List) {
        final list = asMapList(map['data']);

        if (list.isNotEmpty) {
          return list.first;
        }
      }

      // Direct progress object
      if (map.containsKey('progress_date') ||
          map.containsKey('weight') ||
          map.containsKey('body_fat') ||
          map.containsKey('waist_cm') ||
          map.containsKey('arms_cm')) {
        return Map<String, dynamic>.from(map);
      }
    }

    return null;
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final text = value.toString();

    if (text.isEmpty) {
      return '-';
    }

    if (text.contains('T')) {
      return text.split('T').first;
    }

    return text;
  }

  String _formatNumber(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toString();
    }

    final parsed = num.tryParse(value.toString());

    if (parsed == null) {
      return '-';
    }

    if (parsed % 1 == 0) {
      return parsed.toInt().toString();
    }

    return parsed.toString();
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
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Fitness Analytics',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Detailed breakdown of this month\'s discipline and upcoming workouts.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchAnalytics,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // TOP ANALYTICS CARDS
                  // ==================================================

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = Responsive.gridCount(
                        context,
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      );

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              Responsive.isMobile(context) ? 1.9 : 1.55,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return StatCard(
                              title: 'Month Attendance / Check-Ins',
                              value:
                                  '${_formatNumber(_checkinDays)} Days Completed',
                              icon: Icons.check_circle_outline,
                            );
                          }

                          if (index == 1) {
                            return _buildPaymentCard(
                              context,
                              scheme,
                              theme,
                            );
                          }

                          return StatCard(
                            title: 'Month Cheat Meals Logged',
                            value:
                                '${_formatNumber(_cheatMealCount)} Treats',
                            icon: Icons.fastfood_outlined,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // TOMORROW WORKOUT
                  // ==================================================

                  _buildTomorrowWorkoutCard(
                    context,
                    scheme,
                    theme,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CURRENT MONTH PROGRESS
                  // ==================================================

                  _buildProgressCard(
                    context,
                    scheme,
                    theme,
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

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    final status = _paymentStatusText;

    final bool paid = _isPaymentPaid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.payment_outlined,
              color: scheme.primary,
              size: 26,
            ),
            const SizedBox(height: 12),
            Text(
              'Monthly Fee Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            StatusBadge(
              label: status,
              positive: paid,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOMORROW WORKOUT CARD
  // ============================================================

  Widget _buildTomorrowWorkoutCard(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    final workouts = _tomorrowWorkoutList;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.next_plan_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tomorrow\'s Workout Schedule',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (workouts.isEmpty)
              _buildEmptySection(
                context,
                icon: Icons.self_improvement_outlined,
                message:
                    'No workout scheduled for tomorrow or it is an active rest day.',
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _tomorrowPlanName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              ...workouts.map(
                (workout) => _buildWorkoutItem(
                  context,
                  workout,
                  scheme,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WORKOUT ITEM
  // ============================================================

  Widget _buildWorkoutItem(
    BuildContext context,
    Map<String, dynamic> workout,
    ColorScheme scheme,
  ) {
    final exerciseName = asString(
      workout['exercise_name'] ??
          workout['exerciseName'] ??
          workout['name'],
      'Exercise',
    );

    final sets = workout['sets'];
    final reps = workout['reps'];
    final duration = workout['duration_minutes'];

    String details = '';

    if (sets != null && reps != null) {
      details = '${_formatNumber(sets)} sets × ${_formatNumber(reps)} reps';
    } else if (duration != null) {
      details =
          '${_formatNumber(duration)} minutes';
    } else {
      details = 'Workout exercise';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(
              alpha: 0.10,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center,
            size: 17,
            color: scheme.primary,
          ),
        ),
        title: Text(
          exerciseName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(details),
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    final progress = _latestProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_graph_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current Month Progress Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (progress == null)
              _buildEmptySection(
                context,
                icon: Icons.monitor_weight_outlined,
                message:
                    'No measurement entries recorded yet this month.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = Responsive.isMobile(context);

                  return Wrap(
                    spacing: isMobile ? 12 : 28,
                    runSpacing: 16,
                    children: [
                      _buildProgressItem(
                        context,
                        label: 'Latest Check-in',
                        value: _formatDate(
                          progress['progress_date'],
                        ),
                      ),
                      _buildProgressItem(
                        context,
                        label: 'Current Weight',
                        value:
                            '${_formatNumber(progress['weight'])} kg',
                      ),
                      _buildProgressItem(
                        context,
                        label: 'Body Fat',
                        value:
                            '${_formatNumber(progress['body_fat'])} %',
                      ),
                      _buildProgressItem(
                        context,
                        label: 'Waist',
                        value:
                            '${_formatNumber(progress['waist_cm'])} cm',
                      ),
                      _buildProgressItem(
                        context,
                        label: 'Arms',
                        value:
                            '${_formatNumber(progress['arms_cm'])} cm',
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS ITEM
  // ============================================================

  Widget _buildProgressItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 130,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY SECTION
  // ============================================================

  Widget _buildEmptySection(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}