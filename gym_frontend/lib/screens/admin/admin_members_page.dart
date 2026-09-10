import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({super.key});

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/admin/members'),
        api.get('/api/admin/trainers').catchError((_) => <String, dynamic>{}),
      ]);

      final memRes = results[0] as Map<String, dynamic>;
      final trRes = results[1] as Map<String, dynamic>;

      setState(() {
        _members = asMapList(memRes['members']);
        _trainers = asMapList(trRes['trainers']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load member directory.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAssignTrainerDialog(num memberId, String memberName) async {
    if (_trainers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trainers available. Please add trainers first.')),
      );
      return;
    }

    num? selectedTrainerId = _trainers.first['id'];

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text('Assign Coach to $memberName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<num>(
                    initialValue: selectedTrainerId,
                    decoration: const InputDecoration(labelText: 'Select Coach *'),
                    items: _trainers.map((t) {
                      return DropdownMenuItem<num>(
                        value: t['id'],
                        child: Text(asString(t['name'])),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedTrainerId = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: saving,
                  label: 'Assign Coach',
                  onPressed: () async {
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      await api.put('/api/admin/members/$memberId/trainer', body: {'trainer_id': selectedTrainerId});
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();
                    } on ApiException catch (e) {
                      if (dialogCtx.mounted) ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text(e.message)));
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

  Future<void> _removeTrainer(num memberId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unassign Trainer'),
        content: const Text('Remove trainer assignment for this member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final api = context.read<ApiService>();
      await api.delete('/api/admin/members/$memberId/trainer');
      if (mounted) _loadData();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _deleteMember(num memberId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Member'),
        content: const Text('Are you sure you want to deactivate this member account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final api = context.read<ApiService>();
      await api.delete('/api/admin/members/$memberId');
      if (mounted) _loadData();
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
      onRetry: _loadData,
      isEmpty: _members.isEmpty,
      emptyMessage: 'No members registered yet in the system.',
      child: SingleChildScrollView(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Member Administration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Manage memberships, assign trainers, and view member goals.'),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final m = _members[idx];
                    final id = asNum(m['id']);
                    final name = asString(m['name'], 'Member');
                    final email = asString(m['email']);
                    final phone = asString(m['phone']);
                    final trainerName = asString(m['trainer_name']);
                    final status = asString(m['status'], 'ACTIVE');
                    final goal = asString(m['fitness_goal']);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: scheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      StatusBadge(label: status, positive: status == 'ACTIVE'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$email • $phone'),
                                  const SizedBox(height: 2),
                                  Text(
                                    trainerName.isNotEmpty ? 'Assigned Trainer: $trainerName' : 'No trainer assigned',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: trainerName.isNotEmpty ? scheme.primary : Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (goal.isNotEmpty)
                                    Text('Goal: $goal', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                                ],
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (trainerName.isNotEmpty)
                                  OutlinedButton(
                                    onPressed: () => _removeTrainer(id),
                                    child: const Text('Unassign'),
                                  )
                                else
                                  FilledButton.tonal(
                                    onPressed: () => _openAssignTrainerDialog(id, name),
                                    child: const Text('Assign Coach'),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteMember(id),
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
