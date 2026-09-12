import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerWorkoutPlansPage extends StatefulWidget {
  const TrainerWorkoutPlansPage({super.key});

  @override
  State<TrainerWorkoutPlansPage> createState() => _TrainerWorkoutPlansPageState();
}

class _TrainerWorkoutPlansPageState extends State<TrainerWorkoutPlansPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _exercises = [];

  static const List<String> _workoutDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/trainer/workout-plans'),
        api.get('/api/trainer/assigned-members').catchError((_) => <String, dynamic>{}),
        api.get('/api/member/exercises').catchError((_) => <String, dynamic>{}),
      ]);

      final plansRes = results[0];
      final memRes = results[1];
      final exRes = results[2];

      List<dynamic> planList = [];
      if (plansRes is Map && plansRes['plans'] is List) {
        planList = plansRes['plans'];
      } else if (plansRes is List) {
        planList = plansRes;
      }

      List<dynamic> memList = [];
      if (memRes is Map && memRes['members'] is List) memList = memRes['members'];

      List<dynamic> exList = [];
      if (exRes is Map && exRes['exercises'] is List) exList = exRes['exercises'];

      setState(() {
        _plans = asMapList(planList);
        _members = asMapList(memList);
        _exercises = asMapList(exList);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainer workout plans.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreatePlanDialog() async {
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least one assigned member to build a workout plan.')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise library is empty. Please contact admin to add exercises.')),
      );
      return;
    }

    num? selectedMemberId = _members.first['id'];
    num? selectedExerciseId = _exercises.first['id'];
    String selectedDay = _workoutDays.first;

    final planNameCtrl = TextEditingController(text: 'Push Pull Routine');
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '10');
    final durCtrl = TextEditingController(text: '15');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Create Trainee Workout Plan'),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<num>(
                          value: selectedMemberId,
                          decoration: const InputDecoration(labelText: 'Assigned Member *'),
                          items: _members.map((m) {
                            return DropdownMenuItem<num>(
                              value: m['id'],
                              child: Text(asString(m['name'])),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedMemberId = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: planNameCtrl,
                          decoration: const InputDecoration(labelText: 'Plan Name *'),
                          validator: (v) => Validators.requiredField(v, label: 'Plan name'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<num>(
                          value: selectedExerciseId,
                          decoration: const InputDecoration(labelText: 'Starter Exercise *'),
                          items: _exercises.map((e) {
                            return DropdownMenuItem<num>(
                              value: e['id'],
                              child: Text(asString(e['name'])),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedExerciseId = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedDay,
                          decoration: const InputDecoration(labelText: 'Day of Week *'),
                          items: _workoutDays.map((d) {
                            return DropdownMenuItem<String>(
                              value: d,
                              child: Text(d),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedDay = v ?? _workoutDays.first),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: setsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Sets *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Sets'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: repsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Reps *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Reps'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: durCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Mins'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(labelText: 'Technique Notes (Optional)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: saving,
                  label: 'Assign Plan',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      await api.post(
                        '/api/trainer/workout-plans',
                        body: {
                          'member_id': selectedMemberId,
                          'plan_name': planNameCtrl.text.trim(),
                          'exercise_id': selectedExerciseId,
                          'workout_day': selectedDay,
                          'sets': int.tryParse(setsCtrl.text.trim()) ?? 3,
                          'reps': int.tryParse(repsCtrl.text.trim()) ?? 10,
                          'duration_minutes': int.tryParse(durCtrl.text.trim()) ?? 15,
                          'notes': notesCtrl.text.trim(),
                        },
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadAll();
                    } on ApiException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    } finally {
                      if (dialogCtx.mounted) setDialogState(() => saving = false);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openAddExerciseDialog(num planId) async {
    if (_exercises.isEmpty) return;
    num? selectedExerciseId = _exercises.first['id'];
    String selectedDay = _workoutDays.first;
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');
    final durCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Exercise to Routine'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<num>(
                          value: selectedExerciseId,
                          decoration: const InputDecoration(labelText: 'Exercise *'),
                          items: _exercises.map((e) {
                            return DropdownMenuItem<num>(
                              value: e['id'],
                              child: Text(asString(e['name'])),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedExerciseId = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedDay,
                          decoration: const InputDecoration(labelText: 'Day of Week *'),
                          items: _workoutDays.map((d) {
                            return DropdownMenuItem<String>(
                              value: d,
                              child: Text(d),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedDay = v ?? _workoutDays.first),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: setsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Sets *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Sets'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: repsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Reps *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Reps'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: saving,
                  label: 'Add Exercise',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      await api.post(
                        '/api/trainer/workout-plans/$planId/exercises',
                        body: {
                          'exercise_id': selectedExerciseId,
                          'workout_day': selectedDay,
                          'sets': int.tryParse(setsCtrl.text.trim()) ?? 3,
                          'reps': int.tryParse(repsCtrl.text.trim()) ?? 12,
                          'duration_minutes': int.tryParse(durCtrl.text.trim()) ?? 10,
                          'notes': notesCtrl.text.trim(),
                        },
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadAll();
                    } on ApiException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                      }
                    } finally {
                      if (dialogCtx.mounted) setDialogState(() => saving = false);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePlan(num planId) async {
    try {
      final api = context.read<ApiService>();
      await api.delete('/api/trainer/workout-plans/$planId');
      _loadAll();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
      onRetry: _loadAll,
      isEmpty: _plans.isEmpty,
      emptyMessage: 'No workout plans have been assigned yet.',
      child: RefreshIndicator(
        onRefresh: _loadAll,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout Plans Management',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Create and manage customized training schedules for your trainees.'),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCreatePlanDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Assign Plan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final plan = _plans[idx];
                      final planId = asNum(plan['id']);
                      final planName = asString(plan['plan_name'], 'Workout Routine');
                      final memberName = asString(plan['member_name'], 'Trainee');

                      return Card(
                        child: ListTile(
                          title: Text(
                            planName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Trainee: $memberName'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Add Exercise',
                                icon: const Icon(Icons.playlist_add),
                                onPressed: () => _openAddExerciseDialog(planId),
                              ),
                              IconButton(
                                tooltip: 'Delete Plan',
                                icon: Icon(Icons.delete_outline, color: scheme.error),
                                onPressed: () => _deletePlan(planId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}