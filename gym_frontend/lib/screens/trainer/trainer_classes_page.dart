import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerClassesPage extends StatefulWidget {
  const TrainerClassesPage({super.key});

  @override
  State<TrainerClassesPage> createState() => _TrainerClassesPageState();
}

class _TrainerClassesPageState extends State<TrainerClassesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/trainer/class-schedules');
      List<dynamic> list = [];
      if (res is Map && res['classes'] is List) {
        list = res['classes'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _classes = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainer class schedules.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openClassDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final titleCtrl = TextEditingController(text: isEditing ? asString(item['title']) : 'Morning HIIT & Core');
    final dateCtrl = TextEditingController(
      text: isEditing ? asString(item['class_date']).split('T').first : DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T').first,
    );
    final startCtrl = TextEditingController(text: isEditing ? asString(item['start_time']) : '07:00:00');
    final endCtrl = TextEditingController(text: isEditing ? asString(item['end_time']) : '08:00:00');
    final capCtrl = TextEditingController(text: isEditing ? asString(item['capacity']) : '20');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Class Schedule' : 'Create Class Schedule'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(labelText: 'Class Title (e.g. Morning HIIT) *'),
                          validator: (v) => Validators.requiredField(v, label: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateCtrl,
                          decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD) *'),
                          validator: (v) => Validators.requiredField(v, label: 'Date'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startCtrl,
                                decoration: const InputDecoration(labelText: 'Start Time (HH:MM:SS) *'),
                                validator: (v) => Validators.requiredField(v, label: 'Start time'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: endCtrl,
                                decoration: const InputDecoration(labelText: 'End Time (HH:MM:SS) *'),
                                validator: (v) => Validators.requiredField(v, label: 'End time'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: capCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max Capacity (Trainees) *'),
                          validator: (v) => Validators.positiveNumber(v, label: 'Capacity'),
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
                  label: isEditing ? 'Save Changes' : 'Schedule Class',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'title': titleCtrl.text.trim(),
                        'class_date': dateCtrl.text.trim(),
                        'start_time': startCtrl.text.trim(),
                        'end_time': endCtrl.text.trim(),
                        'capacity': int.tryParse(capCtrl.text.trim()) ?? 15,
                      };

                      if (isEditing) {
                        await api.put('/api/trainer/class-schedules/${item['id']}', body: body);
                      } else {
                        await api.post('/api/trainer/class-schedules', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchClasses();
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

  Future<void> _deleteClass(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel / Delete Class'),
        content: const Text('Are you sure you want to cancel this scheduled class?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Back')),
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
      await api.delete('/api/trainer/class-schedules/$id');
      _fetchClasses();
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
      onRetry: _fetchClasses,
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
                        Text('Group Classes Schedule', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Manage group training sessions, timeslots, and participant capacity.'),
                      ],
                    ),
                    AppButton(
                      label: 'Add Class',
                      icon: Icons.add,
                      onPressed: () => _openClassDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_classes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No group classes scheduled yet. Add a new class!')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _classes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final c = _classes[idx];
                      final id = asNum(c['id']);
                      final title = asString(c['title'], 'Group Training');
                      final date = asString(c['class_date']).split('T').first;
                      final start = asString(c['start_time']);
                      final end = asString(c['end_time']);
                      final cap = asNum(c['capacity']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.timer_outlined, color: scheme.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Date: $date • $start to $end', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                                    const SizedBox(height: 2),
                                    Text('Max Capacity: $cap trainees', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _openClassDialog(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () => _deleteClass(id),
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
