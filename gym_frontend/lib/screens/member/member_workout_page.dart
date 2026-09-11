import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberWorkoutPage extends StatefulWidget {
  const MemberWorkoutPage({super.key});

  @override
  State<MemberWorkoutPage> createState() => _MemberWorkoutPageState();
}

class _MemberWorkoutPageState extends State<MemberWorkoutPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];
  final Set<int> _completingExerciseIds = {};
  final Set<int> _completedExerciseIds = {};

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlans();
  }

  Future<void> _fetchWorkoutPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/workout-plans');
      List<dynamic> list = [];
      if (res is Map && res['plans'] is List) {
        list = res['plans'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _plans = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load assigned workout plans.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeExercise(num planId, num exerciseId) async {
    final exId = exerciseId.toInt();
    if (_completingExerciseIds.contains(exId) || _completedExerciseIds.contains(exId)) return;

    setState(() => _completingExerciseIds.add(exId));
    try {
      final api = context.read<ApiService>();
      await api.post('/api/member/workout-plans/$planId/exercises/$exerciseId/complete');
      if (!mounted) return;
      setState(() {
        _completedExerciseIds.add(exId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout exercise marked as completed for today! Great job!'), backgroundColor: Colors.green),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        setState(() => _completedExerciseIds.add(exId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise already marked completed today.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _completingExerciseIds.remove(exId));
      }
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
      onRetry: _fetchWorkoutPlans,
      isEmpty: _plans.isEmpty,
      emptyMessage: 'No workout plans assigned yet. Your coach will assign tailored workouts soon.',
      child: RefreshIndicator(
        onRefresh: _fetchWorkoutPlans,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Workout Plans', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Review your assigned routines and track daily exercise completion.'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchWorkoutPlans,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _plans.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (context, idx) {
                      final plan = _plans[idx];
                      final planId = asNum(plan['id']);
                      final planName = asString(plan['plan_name'], 'Workout Routine');
                      final trainerName = asString(plan['trainer_name'], 'Assigned Trainer');
                      final exercises = asMapList(plan['exercises']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: scheme.primary.withValues(alpha: 0.12),
                                          child: Icon(Icons.fitness_center, color: scheme.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                planName, 
                                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Trainer: $trainerName', 
                                                style: theme.textTheme.bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(label: '${exercises.length} Exercises'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              if (exercises.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No exercises added to this plan yet.'),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: exercises.length,
                                  separatorBuilder: (_, _) => const Divider(),
                                  itemBuilder: (context, exIdx) {
                                    final ex = exercises[exIdx];
                                    final exId = asNum(ex['id']);
                                    final name = asString(ex['exercise_name'], 'Exercise');
                                    final day = asString(ex['workout_day']);
                                    final muscle = asString(ex['muscle_group']);
                                    final sets = asNum(ex['sets']);
                                    final reps = asNum(ex['reps']);
                                    final duration = asNum(ex['duration_minutes']);
                                    final notes = asString(ex['notes']);
                                    final isCompleted = _completedExerciseIds.contains(exId.toInt());
                                    final isSubmitting = _completingExerciseIds.contains(exId.toInt());

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name, 
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: scheme.secondary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(day, style: TextStyle(fontSize: 11, color: scheme.secondary, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('$muscle • $sets Sets × $reps Reps • $duration Mins'),
                                          if (notes.isNotEmpty)
                                            Text('Tip: $notes', style: TextStyle(fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                                        ],
                                      ),
                                      trailing: isCompleted
                                          ? const Chip(
                                              avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
                                              label: Text('Completed Today', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                            )
                                          : OutlinedButton.icon(
                                              onPressed: isSubmitting ? null : () => _completeExercise(planId, exId),
                                              icon: isSubmitting
                                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                                  : const Icon(Icons.check, size: 16),
                                              label: const Text('Mark Done'),
                                            ),
                                    );
                                  },
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