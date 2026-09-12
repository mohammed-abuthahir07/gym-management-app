import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminPromotionsPage extends StatefulWidget {
  const AdminPromotionsPage({super.key});

  @override
  State<AdminPromotionsPage> createState() => _AdminPromotionsPageState();
}

class _AdminPromotionsPageState extends State<AdminPromotionsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _promotions = [];

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/admin/promotions');
      List<dynamic> list = [];
      if (res is Map && res['promotions'] is List) {
        list = res['promotions'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _promotions = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load promotions.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDialog([Map<String, dynamic>? item]) async {
    final isEditing = item != null;
    final titleCtrl = TextEditingController(text: isEditing ? asString(item['title']) : '');
    final codeCtrl = TextEditingController(text: isEditing ? asString(item['code']) : '');
    final descCtrl = TextEditingController(text: isEditing ? asString(item['description']) : '');
    final discountCtrl = TextEditingController(text: isEditing ? asString(item['discount']) : '20');
    String discountType = isEditing ? asString(item['discount_type'], 'PERCENTAGE') : 'PERCENTAGE';
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
              title: Text(isEditing ? 'Edit Promotion Deal' : 'Add Promotion Deal'),
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
                          decoration: const InputDecoration(labelText: 'Promotion Title *', isDense: true),
                          validator: (v) => Validators.requiredField(v, label: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Promo Code (e.g. NY2026) *', isDense: true),
                          validator: (v) => Validators.requiredField(v, label: 'Promo code'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descCtrl,
                          decoration: const InputDecoration(labelText: 'Description', isDense: true),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: discountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Discount Value *', isDense: true),
                                validator: (v) => Validators.positiveNumber(v, label: 'Discount'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: discountType,
                                decoration: const InputDecoration(labelText: 'Type *', isDense: true),
                                items: const [
                                  DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percent', overflow: TextOverflow.ellipsis)),
                                  DropdownMenuItem(value: 'FIXED', child: Text('Fixed (₹)', overflow: TextOverflow.ellipsis)),
                                ],
                                onChanged: (v) => setDialogState(() => discountType = v ?? 'PERCENTAGE'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startCtrl,
                                decoration: const InputDecoration(labelText: 'Start (YYYY-MM-DD) *', isDense: true),
                                validator: (v) => Validators.requiredField(v, label: 'Start date'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: endCtrl,
                                decoration: const InputDecoration(labelText: 'End (YYYY-MM-DD) *', isDense: true),
                                validator: (v) => Validators.requiredField(v, label: 'End date'),
                              ),
                            ),
                          ],
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
                  label: isEditing ? 'Save Changes' : 'Publish Offer',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        'title': titleCtrl.text.trim(),
                        'code': codeCtrl.text.trim().toUpperCase(),
                        'description': descCtrl.text.trim(),
                        'discount': double.tryParse(discountCtrl.text.trim()) ?? 0.0,
                        'discount_type': discountType,
                        'start_date': startCtrl.text.trim(),
                        'end_date': endCtrl.text.trim(),
                        if (isEditing) 'status': status,
                      };

                      if (isEditing) {
                        await api.put('/api/admin/promotions/${item['id']}', body: body);
                      } else {
                        await api.post('/api/admin/promotions', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _fetchPromotions();
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

  Future<void> _deletePromotion(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Promotion'),
        content: const Text('Are you sure you want to remove this promotional code?'),
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
      await api.delete('/api/admin/promotions/$id');
      _fetchPromotions();
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
      onRetry: _fetchPromotions,
      isEmpty: _promotions.isEmpty,
      emptyMessage: 'No promotional offers created yet.',
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
                          Text('Promotions & Discounts Administration', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Manage limited-time membership discount campaigns and coupon codes.'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: 'Create Promo',
                      icon: Icons.add,
                      onPressed: () => _openDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _promotions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final p = _promotions[idx];
                    final id = asNum(p['id']);
                    final title = asString(p['title'], 'Offer');
                    final code = asString(p['code']);
                    final discount = asNum(p['discount']);
                    final type = asString(p['discount_type'], 'PERCENTAGE');
                    final end = asString(p['end_date']).split('T').first;

                    final label = type == 'PERCENTAGE' ? '$discount% OFF' : '₹$discount OFF';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.local_offer, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(label: label),
                          ],
                        ),
                        subtitle: Text('Code: $code • Valid until: $end'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openDialog(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deletePromotion(id),
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