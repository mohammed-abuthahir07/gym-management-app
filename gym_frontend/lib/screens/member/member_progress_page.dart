import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class MemberProgressPage extends StatefulWidget {
  const MemberProgressPage({super.key});

  @override
  State<MemberProgressPage> createState() => _MemberProgressPageState();
}

class _MemberProgressPageState extends State<MemberProgressPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _progressList = [];

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/progress');
      List<dynamic> list = [];
      if (res is Map && res['progress'] is List) {
        list = res['progress'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _progressList = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load progress records.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final dateCtrl = TextEditingController(
      text: isEditing ? asString(item['progress_date']).split('T').first : DateTime.now().toIso8601String().split('T').first,
    );
    final weightCtrl = TextEditingController(text: isEditing ? asString(item['weight']) : '');
    final bodyFatCtrl = TextEditingController(text: isEditing ? asString(item['body_fat']) : '');
    final waistCtrl = TextEditingController(text: isEditing ? asString(item['waist_cm']) : '');
    final armsCtrl = TextEditingController(text: isEditing ? asString(item['arms_cm']) : '');
    final notesCtrl = TextEditingController(text: isEditing ? asString(item['notes']) : '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Update Body Measurements' : 'Record Body Measurements'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: dateCtrl,
                          decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD) *'),
                          validator: (v) => Validators.requiredField(v, label: 'Date'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          validator: (v) => v != null && v.isNotEmpty ? Validators.positiveNumber(v, label: 'Weight') : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: bodyFatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Body Fat Percentage (%)'),
                          validator: (v) => v != null && v.isNotEmpty ? Validators.positiveNumber(v, label: 'Body fat') : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: waistCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Waist Size (cm)'),
                          validator: (v) => v != null && v.isNotEmpty ? Validators.positiveNumber(v, label: 'Waist') : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: armsCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Arms Size (cm)'),
                          validator: (v) => v != null && v.isNotEmpty ? Validators.positiveNumber(v, label: 'Arms') : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          decoration: const InputDecoration(labelText: 'Notes (Optional)'),
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
                  label: isEditing ? 'Save' : 'Record',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'progress_date': dateCtrl.text.trim(),
                        'weight': double.tryParse(weightCtrl.text.trim()) ?? 0.0,
                        'body_fat': double.tryParse(bodyFatCtrl.text.trim()) ?? 0.0,
                        'waist_cm': double.tryParse(waistCtrl.text.trim()) ?? 0.0,
                        'arms_cm': double.tryParse(armsCtrl.text.trim()) ?? 0.0,
                        'notes': notesCtrl.text.trim(),
                      };

                      if (isEditing) {
                        await api.put('/api/member/progress/${item['id']}', body: body);
                      } else {
                        await api.post('/api/member/progress', body: body);
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchProgress();
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

  Future<void> _deleteProgress(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this progress entry?'),
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
      await api.delete('/api/member/progress/$id');
      _fetchProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress entry removed.')));
      }
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
      onRetry: _fetchProgress,
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
                        Text('Body Progress Tracking', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Consistent measurement entries to visualize physical gains over time.'),
                      ],
                    ),
                    AppButton(
                      label: 'Add Entry',
                      icon: Icons.add,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_progressList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No progress check-ins logged yet. Add your first entry!')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _progressList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final p = _progressList[idx];
                      final id = asNum(p['id']);
                      final date = asString(p['progress_date']).split('T').first;
                      final weight = asNum(p['weight']);
                      final bodyFat = asNum(p['body_fat']);
                      final waist = asNum(p['waist_cm']);
                      final arms = asNum(p['arms_cm']);
                      final notes = asString(p['notes']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20),
                                        onPressed: () => _openDialog(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                        onPressed: () => _deleteProgress(id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 24,
                                runSpacing: 8,
                                children: [
                                  _StatBadgeItem(label: 'Weight', value: '$weight kg'),
                                  _StatBadgeItem(label: 'Body Fat', value: '$bodyFat %'),
                                  _StatBadgeItem(label: 'Waist', value: '$waist cm'),
                                  _StatBadgeItem(label: 'Arms', value: '$arms cm'),
                                ],
                              ),
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Notes: $notes', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                              ],
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

class _StatBadgeItem extends StatelessWidget {
  const _StatBadgeItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
