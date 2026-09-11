import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class MemberCheatDaysPage extends StatefulWidget {
  const MemberCheatDaysPage({super.key});

  @override
  State<MemberCheatDaysPage> createState() => _MemberCheatDaysPageState();
}

class _MemberCheatDaysPageState extends State<MemberCheatDaysPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cheatDays = [];

  @override
  void initState() {
    super.initState();
    _fetchCheatDays();
  }

  Future<void> _fetchCheatDays() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/cheat-days');
      List<dynamic> list = [];
      if (res is Map && res['cheat_days'] is List) {
        list = res['cheat_days'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _cheatDays = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load cheat meals.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final rawDate = isEditing ? asString(item['cheat_date']) : '';
    final formattedDate = rawDate.contains('T') ? rawDate.split('T').first : rawDate;

    final dateCtrl = TextEditingController(
      text: isEditing && formattedDate.isNotEmpty ? formattedDate : DateTime.now().toIso8601String().split('T').first,
    );
    final foodCtrl = TextEditingController(text: isEditing ? asString(item['food_name']) : '');
    final qtyCtrl = TextEditingController(text: isEditing ? asString(item['quantity']) : '');
    final calCtrl = TextEditingController(text: isEditing ? asString(item['calories']) : '');
    final notesCtrl = TextEditingController(text: isEditing ? asString(item['notes']) : '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Cheat Meal' : 'Log Cheat Meal'),
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
                          controller: foodCtrl,
                          decoration: const InputDecoration(labelText: 'Food Name *'),
                          validator: (v) => Validators.requiredField(v, label: 'Food name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: qtyCtrl,
                          decoration: const InputDecoration(labelText: 'Portion / Quantity (e.g. 2 slices)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: calCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Estimated Calories'),
                          validator: (v) => v != null && v.isNotEmpty ? Validators.positiveNumber(v, label: 'Calories') : null,
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
                  label: isEditing ? 'Save Changes' : 'Log Meal',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'cheat_date': dateCtrl.text.trim(),
                        'food_name': foodCtrl.text.trim(),
                        'quantity': qtyCtrl.text.trim(),
                        'calories': int.tryParse(calCtrl.text.trim()) ?? 0,
                        'notes': notesCtrl.text.trim(),
                      };

                      if (isEditing) {
                        await api.put('/api/member/cheat-days/${item['id']}', body: body);
                      } else {
                        await api.post('/api/member/cheat-days', body: body);
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchCheatDays();
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

  Future<void> _deleteCheatMeal(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to remove this cheat meal log?'),
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
      await api.delete('/api/member/cheat-days/$id');
      _fetchCheatDays();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cheat meal deleted.')));
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
      onRetry: _fetchCheatDays,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cheat Meal Diary', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          const Text('Transparently log treats so your coach can balance your calories.', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Log Cheat Meal',
                      icon: Icons.add,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_cheatDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('No cheat meals recorded yet. Clean streak!')),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cheatDays.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = _cheatDays[i];
                      final id = asNum(item['id']);
                      final food = asString(item['food_name'], 'Cheat Item');
                      final qty = asString(item['quantity']);
                      final cal = asNum(item['calories']);
                      final rawDate = asString(item['cheat_date']);
                      final date = rawDate.contains('T') ? rawDate.split('T').first : rawDate;
                      final notes = asString(item['notes']);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: scheme.error.withValues(alpha: 0.1),
                                child: Icon(Icons.fastfood, color: scheme.error, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(food, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(date, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('$qty • $cal kcal', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
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
                                onPressed: () => _openDialog(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                onPressed: () => _deleteCheatMeal(id),
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