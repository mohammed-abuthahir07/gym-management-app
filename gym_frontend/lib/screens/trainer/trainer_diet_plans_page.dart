import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerDietPlansPage extends StatefulWidget {
  const TrainerDietPlansPage({super.key});

  @override
  State<TrainerDietPlansPage> createState() => _TrainerDietPlansPageState();
}

class _TrainerDietPlansPageState extends State<TrainerDietPlansPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _dietPlans = [];
  List<Map<String, dynamic>> _members = [];

  static const List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  static const List<String> _mealTypes = [
    'BREAKFAST',
    'MORNING_SNACK',
    'LUNCH',
    'EVENING_SNACK',
    'DINNER',
    'POST_WORKOUT',
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
        api.get('/api/trainer/diet-plans'),
        api.get('/api/trainer/assigned-members').catchError((_) => <String, dynamic>{}),
      ]);

      final dietRes = results[0];
      final memRes = results[1];

      List<dynamic> dietList = [];
      if (dietRes is Map && dietRes['diet_plans'] is List) {
        dietList = dietRes['diet_plans'];
      } else if (dietRes is List) {
        dietList = dietRes;
      }

      List<dynamic> memList = [];
      if (memRes is Map && memRes['members'] is List) {
        memList = memRes['members'];
      }

      setState(() {
        _dietPlans = asMapList(dietList);
        _members = asMapList(memList);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainer diet plans.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDietDialog([Map<String, dynamic>? item]) async {
    if (_members.isEmpty && item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No assigned members available to receive diet targets.')),
      );
      return;
    }

    final isEditing = item != null;
    num? selectedMemberId = isEditing ? item['member_id'] : _members.first['id'];
    String selectedDay = isEditing ? asString(item['diet_day'], _days.first) : _days.first;
    String selectedMeal = isEditing ? asString(item['meal_type'], _mealTypes.first) : _mealTypes.first;

    final foodCtrl = TextEditingController(text: isEditing ? asString(item['food_name']) : '');
    final calCtrl = TextEditingController(text: isEditing ? asString(item['calories']) : '350');
    final protCtrl = TextEditingController(text: isEditing ? asString(item['protein']) : '25');
    final notesCtrl = TextEditingController(text: isEditing ? asString(item['notes']) : '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Diet Plan' : 'Assign Diet Plan'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isEditing) ...[
                          DropdownButtonFormField<num>(
                            initialValue: selectedMemberId,
                            decoration: const InputDecoration(labelText: 'Trainee *'),
                            items: _members.map((m) {
                              return DropdownMenuItem<num>(
                                value: m['id'],
                                child: Text(asString(m['name'])),
                              );
                            }).toList(),
                            onChanged: (v) => setDialogState(() => selectedMemberId = v),
                          ),
                          const SizedBox(height: 12),
                        ],
                        DropdownButtonFormField<String>(
                          initialValue: selectedDay,
                          decoration: const InputDecoration(labelText: 'Day of Week *'),
                          items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                          onChanged: (v) => setDialogState(() => selectedDay = v ?? _days.first),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedMeal,
                          decoration: const InputDecoration(labelText: 'Meal Timing *'),
                          items: _mealTypes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (v) => setDialogState(() => selectedMeal = v ?? _mealTypes.first),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: foodCtrl,
                          decoration: const InputDecoration(labelText: 'Food / Meal Item *'),
                          validator: (v) => Validators.requiredField(v, label: 'Food item'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: calCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Calories (kcal) *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Calories'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: protCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Protein (g) *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Protein'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(labelText: 'Dietary Notes (Optional)'),
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
                  label: isEditing ? 'Update Plan' : 'Assign Diet',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        if (!isEditing) 'member_id': selectedMemberId,
                        'diet_day': selectedDay,
                        'meal_type': selectedMeal,
                        'food_name': foodCtrl.text.trim(),
                        'calories': int.tryParse(calCtrl.text.trim()) ?? 0,
                        'protein': int.tryParse(protCtrl.text.trim()) ?? 0,
                        'notes': notesCtrl.text.trim(),
                      };

                      if (isEditing) {
                        await api.put('/api/trainer/diet-plans/${item['id']}', body: body);
                      } else {
                        await api.post('/api/trainer/diet-plans', body: body);
                      }
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

  Future<void> _deleteDiet(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Diet Plan'),
        content: const Text('Are you sure you want to remove this diet plan?'),
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
    if (confirm != true || !mounted) return;

    try {
      final api = context.read<ApiService>();
      await api.delete('/api/trainer/diet-plans/$id');
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
                        Text('Diet & Nutrition Plans', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Prescribe macro goals and nutritious meals to assigned trainees.'),
                      ],
                    ),
                    AppButton(
                      label: 'Assign Diet',
                      icon: Icons.add,
                      onPressed: () => _openDietDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_dietPlans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No diet plans registered yet. Assign your first meal plan!')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dietPlans.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final d = _dietPlans[idx];
                      final id = asNum(d['id']);
                      final memberName = asString(d['member_name'], 'Trainee');
                      final day = asString(d['diet_day']);
                      final meal = asString(d['meal_type']);
                      final food = asString(d['food_name']);
                      final cal = asNum(d['calories']);
                      final prot = asNum(d['protein']);
                      final notes = asString(d['notes']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.restaurant, color: scheme.primary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('$food ($meal)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        StatusBadge(label: day),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Trainee: $memberName • $cal kcal • $prot g Protein', style: TextStyle(color: scheme.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                    if (notes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text('Notes: $notes', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _openDietDialog(d),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () => _deleteDiet(id),
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
