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
                          initialValue: selectedMemberId,
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
                          initialValue: selectedExerciseId,
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
                          initialValue: selectedDay,
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
                          initialValue: selectedExerciseId,
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
                          initialValue: selectedDay,
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
                          'reps': int.tryParse(repsCtrl.text.trim()) ?? 10,
                          'duration_minutes': int.tryParse(durCtrl.text.trim()) ?? 10,
                          'notes': notesCtrl.text.trim(),
                        },
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadAll();
                    } on ApiException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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

  Future<void> _deletePlan(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this workout plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final api = context.read<ApiService>();
      await api.delete('/api/trainer/workout-plans/$id');
      _loadAll();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
                        Text('Workout Plan Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Assign and fine-tune routines for your assigned members.'),
                      ],
                    ),
                    AppButton(
                      label: 'Create Plan',
                      icon: Icons.add,
                      onPressed: _openCreatePlanDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_plans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No workout plans created yet. Build a workout plan for a member!')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                      final p = _plans[idx];
                      final id = asNum(p['id']);
                      final planName = asString(p['plan_name'], 'Workout Plan');
                      final memberName = asString(p['member_name'], 'Trainee');
                      final memberEmail = asString(p['member_email']);

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
                                        child: Icon(Icons.fitness_center, color: scheme.primary),
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                          Text('Trainee: $memberName ($memberEmail)', style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Add Exercise',
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _openAddExerciseDialog(id),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete Plan',
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deletePlan(id),
                                      ),
                                    ],
                                  ),
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
    );
  }
}
