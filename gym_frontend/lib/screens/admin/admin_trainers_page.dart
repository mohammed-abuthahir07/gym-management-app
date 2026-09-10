import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminTrainersPage extends StatefulWidget {
  const AdminTrainersPage({super.key});

  @override
  State<AdminTrainersPage> createState() => _AdminTrainersPageState();
}

class _AdminTrainersPageState extends State<AdminTrainersPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/trainers');
      List<dynamic> list = [];
      if (res is Map && res['trainers'] is List) {
        list = res['trainers'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _trainers = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load trainer staff directory.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreateTrainerDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Certified Trainer'),
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
                          decoration: const InputDecoration(labelText: 'Trainer Name *'),
                          validator: (v) => Validators.requiredField(v, label: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email Address *'),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Account Password *'),
                          validator: Validators.password,
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
                  label: 'Create Account',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      await api.post(
                        '/api/admin/trainers',
                        body: {
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                          'password': passCtrl.text,
                        },
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchTrainers();
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

  Future<void> _deleteTrainer(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Trainer'),
        content: const Text('Are you sure you want to deactivate this trainer account?'),
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
      await api.delete('/api/admin/trainers/$id');
      _fetchTrainers();
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
      onRetry: _fetchTrainers,
      isEmpty: _trainers.isEmpty,
      emptyMessage: 'No trainers registered yet. Add staff members using the button above.',
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
                        Text('Coaching Staff Administration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Manage certified trainers, credentials, and coaching credentials.'),
                      ],
                    ),
                    AppButton(
                      label: 'Add Trainer',
                      icon: Icons.person_add_outlined,
                      onPressed: _openCreateTrainerDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _trainers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final t = _trainers[idx];
                    final id = asNum(t['id']);
                    final name = asString(t['name'], 'Trainer');
                    final email = asString(t['email']);
                    final phone = asString(t['phone']);
                    final status = asString(t['status'], 'ACTIVE');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.fitness_center, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            StatusBadge(label: status, positive: status == 'ACTIVE'),
                          ],
                        ),
                        subtitle: Text('$email • ${phone.isNotEmpty ? phone : 'No phone registered'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteTrainer(id),
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
