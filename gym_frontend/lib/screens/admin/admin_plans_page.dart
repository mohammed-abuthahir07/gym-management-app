import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminPlansPage extends StatefulWidget {
  const AdminPlansPage({super.key});

  @override
  State<AdminPlansPage> createState() => _AdminPlansPageState();
}

class _AdminPlansPageState extends State<AdminPlansPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];

  static const List<String> _units = ['DAY', 'MONTH', 'YEAR'];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/plans');
      List<dynamic> list = [];
      if (res is Map && res['plans'] is List) {
        list = res['plans'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _plans = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load plans.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreatePlanDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durValCtrl = TextEditingController(text: '3');
    String selectedUnit = _units[1]; // MONTH
    final priceCtrl = TextEditingController(text: '2999');
    final featuresCtrl = TextEditingController(text: 'Locker access & sauna included');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Membership Tier'),
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
                          decoration: const InputDecoration(labelText: 'Plan Name (e.g. Platinum Tier) *'),
                          validator: (v) => Validators.requiredField(v, label: 'Plan name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Description'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: durValCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Duration Value *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Duration'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: const InputDecoration(labelText: 'Unit *'),
                                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setDialogState(() => selectedUnit = v ?? 'MONTH'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (₹) *'),
                          validator: (v) => Validators.positiveNumber(v, label: 'Price'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: featuresCtrl,
                          decoration: const InputDecoration(labelText: 'Extra Perks & Features'),
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
                  label: 'Save Plan',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      await api.post(
                        '/api/admin/plans',
                        body: {
                          'name': nameCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'duration_value': int.tryParse(durValCtrl.text.trim()) ?? 1,
                          'duration_unit': selectedUnit,
                          'price': double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                          'extra_features': featuresCtrl.text.trim(),
                        },
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchPlans();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchPlans,
      isEmpty: _plans.isEmpty,
      emptyMessage: 'No membership plans created yet.',
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
                        Text('Membership Plans Administration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Define membership tiers and pricing published on the public landing page.'),
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final p = _plans[idx];
                    final name = asString(p['name'], 'Plan');
                    final desc = asString(p['description']);
                    final price = asNum(p['price']);
                    final durVal = asNum(p['duration_value']);
                    final durUnit = asString(p['duration_unit']);
                    final status = asString(p['status'], 'ACTIVE');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.payments_outlined, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            StatusBadge(label: '$durVal $durUnit'),
                          ],
                        ),
                        subtitle: Text(desc.isNotEmpty ? desc : 'Full facility access tier'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 12),
                            StatusBadge(label: status, positive: status == 'ACTIVE'),
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
