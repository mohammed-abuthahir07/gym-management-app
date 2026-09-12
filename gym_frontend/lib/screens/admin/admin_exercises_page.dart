import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminExercisesPage extends StatefulWidget {
  const AdminExercisesPage({super.key});

  @override
  State<AdminExercisesPage> createState() => _AdminExercisesPageState();
}

class _AdminExercisesPageState extends State<AdminExercisesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _exercises = [];

  static const List<String> _difficulties = ['BEGINNER', 'INTERMEDIATE', 'DIFFICULT'];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/exercises');
      List<dynamic> list = [];
      if (res is Map) {
        if (res['exercises'] is List) {
          list = res['exercises'];
        } else if (res['data'] is List) {
          list = res['data'];
        }
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _exercises = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load exercises.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: isEditing ? asString(item['name']) : '');
    final muscleCtrl = TextEditingController(text: isEditing ? asString(item['muscle_group']) : 'Chest');
    final eqCtrl = TextEditingController(text: isEditing ? asString(item['equipment']) : 'Barbell');
    final instCtrl = TextEditingController(text: isEditing ? asString(item['instructions']) : '');
    final imgCtrl = TextEditingController(text: isEditing ? asString(item['image_url']) : '');
    final vidCtrl = TextEditingController(text: isEditing ? asString(item['video_url']) : '');
    String difficulty = isEditing ? asString(item['difficulty'], 'BEGINNER') : 'BEGINNER';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise to Library'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Exercise Name *'),
                          validator: (v) => Validators.requiredField(v, label: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: muscleCtrl,
                                decoration: const InputDecoration(labelText: 'Muscle Group *'),
                                validator: (v) => Validators.requiredField(v, label: 'Muscle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: eqCtrl,
                                decoration: const InputDecoration(labelText: 'Equipment'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _difficulties.contains(difficulty) ? difficulty : 'BEGINNER',
                          decoration: const InputDecoration(labelText: 'Difficulty Tier *'),
                          items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                          onChanged: (v) => setDialogState(() => difficulty = v ?? 'BEGINNER'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: instCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Instructions / Technique cues'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: imgCtrl,
                          decoration: const InputDecoration(labelText: 'Image URL'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: vidCtrl,
                          decoration: const InputDecoration(labelText: 'Video URL'),
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
                  label: isEditing ? 'Save' : 'Add Exercise',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'name': nameCtrl.text.trim(),
                        'muscle_group': muscleCtrl.text.trim(),
                        'equipment': eqCtrl.text.trim(),
                        'instructions': instCtrl.text.trim(),
                        'image_url': imgCtrl.text.trim(),
                        'video_url': vidCtrl.text.trim(),
                        'difficulty': difficulty,
                      };

                      if (isEditing) {
                        final exerciseId = asNum(item['id']);
                        await api.put('/api/admin/exercises/$exerciseId', body: body);
                      } else {
                        await api.post('/api/admin/exercises', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchExercises();
                    } on ApiException catch (e) {
                      if (dialogCtx.mounted) {
                        ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text(e.message)));
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

  Future<void> _deleteExercise(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text('Are you sure you want to remove this exercise from the database?'),
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
      await api.delete('/api/admin/exercises/$id');
      _fetchExercises();
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
      onRetry: _fetchExercises,
      isEmpty: _exercises.isEmpty,
      emptyMessage: 'No exercises in the gym database yet.',
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exercise Database Administration',
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text('Manage all library movements accessible to trainers and trainees.'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: 'Add Exercise',
                      icon: Icons.add,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final ex = _exercises[idx];
                    final id = asNum(ex['id']);
                    final name = asString(ex['name'], 'Exercise');
                    final muscle = asString(ex['muscle_group']);
                    final diff = asString(ex['difficulty'], 'BEGINNER');

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.fitness_center, color: scheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Muscle Group: $muscle',
                                        style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(label: diff),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _openDialog(ex),
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _deleteExercise(id),
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    side: const BorderSide(color: Colors.redAccent),
                                  ),
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