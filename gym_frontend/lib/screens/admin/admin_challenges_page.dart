import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() => _AdminChallengesPageState();
}

class _AdminChallengesPageState extends State<AdminChallengesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/challenges');
      List<dynamic> list = [];
      if (res is Map && res['challenges'] is List) {
        list = res['challenges'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _challenges = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load challenges.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final titleCtrl = TextEditingController(text: isEditing ? asString(item['title']) : '');
    final descCtrl = TextEditingController(text: isEditing ? asString(item['description']) : '');
    final rewardCtrl = TextEditingController(text: isEditing ? asString(item['reward']) : 'Free Shaker Cup');
    String status = isEditing ? asString(item['status'], 'ACTIVE') : 'ACTIVE';

    final startCtrl = TextEditingController(
      text: isEditing ? asString(item['start_date']).split('T').first : DateTime.now().toIso8601String().split('T').first,
    );
    final endCtrl = TextEditingController(
      text: isEditing ? asString(item['end_date']).split('T').first : DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T').first,
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Challenge' : 'Launch New Challenge'),
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
                          decoration: const InputDecoration(labelText: 'Challenge Title *', isDense: true),
                          validator: (v) => Validators.requiredField(v, label: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Rules & Target Description', isDense: true),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startCtrl,
                                decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD) *', isDense: true),
                                validator: (v) => Validators.requiredField(v, label: 'Start date'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: endCtrl,
                                decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD) *', isDense: true),
                                validator: (v) => Validators.requiredField(v, label: 'End date'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: rewardCtrl,
                          decoration: const InputDecoration(labelText: 'Reward / Prize (e.g. Free T-shirt) *', isDense: true),
                          validator: (v) => Validators.requiredField(v, label: 'Reward'),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: status,
                            decoration: const InputDecoration(labelText: 'Status *', isDense: true),
                            items: const [
                              DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                              DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                            ],
                            onChanged: (v) => setDialogState(() => status = v ?? 'ACTIVE'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: saving,
                  label: isEditing ? 'Save Changes' : 'Create Challenge',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'title': titleCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'start_date': startCtrl.text.trim(),
                        'end_date': endCtrl.text.trim(),
                        'reward': rewardCtrl.text.trim(),
                        if (isEditing) 'status': status,
                      };

                      if (isEditing) {
                        await api.put('/api/admin/challenges/${item['id']}', body: body);
                      } else {
                        await api.post('/api/admin/challenges', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchChallenges();
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

  Future<void> _deleteChallenge(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Challenge'),
        content: const Text('Are you sure you want to remove this challenge?'),
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
      await api.delete('/api/admin/challenges/$id');
      _fetchChallenges();
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
      onRetry: _fetchChallenges,
      isEmpty: _challenges.isEmpty,
      emptyMessage: 'No gym challenges registered yet.',
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
                          Text('Challenges Administration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Design gym-wide milestones and prize challenges for members.'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: 'New Challenge',
                      icon: Icons.add,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final c = _challenges[idx];
                    final id = asNum(c['id']);
                    final title = asString(c['title'], 'Challenge');
                    final reward = asString(c['reward']);
                    final start = asString(c['start_date']).split('T').first;
                    final end = asString(c['end_date']).split('T').first;
                    final challengeStatus = asString(c['status'], 'ACTIVE');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.military_tech, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(label: challengeStatus),
                          ],
                        ),
                        subtitle: Text('Valid: $start to $end • Prize: $reward'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteChallenge(id),
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