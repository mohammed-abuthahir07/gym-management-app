import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminFeesPage extends StatefulWidget {
  const AdminFeesPage({super.key});

  @override
  State<AdminFeesPage> createState() => _AdminFeesPageState();
}

class _AdminFeesPageState extends State<AdminFeesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _fees = [];
  List<Map<String, dynamic>> _members = [];

  static const List<String> _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
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
        api.get('/api/admin/fees'),
        api.get('/api/admin/members').catchError((_) => <String, dynamic>{}),
      ]);

      final feeRes = results[0];
      final memRes = results[1] as Map<String, dynamic>;

      List<dynamic> list = [];
      if (feeRes is Map && (feeRes['fees'] is List || feeRes['data'] is List)) {
        list = (feeRes['fees'] ?? feeRes['data']) as List;
      } else if (feeRes is List) {
        list = feeRes;
      }

      setState(() {
        _fees = asMapList(list);
        _members = asMapList(memRes['members']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load fee ledger.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openFeeDialog([Map<String, dynamic>? item]) async {
    if (_members.isEmpty && item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members registered to record fees against.')),
      );
      return;
    }

    final isEditing = item != null;
    num? selectedMemberId = isEditing ? item['member_id'] : _members.first['id'];
    final amountCtrl = TextEditingController(text: isEditing ? asString(item['fee_amount']) : '1500');
    final dateCtrl = TextEditingController(
      text: isEditing ? asString(item['fee_date']).split('T').first : DateTime.now().toIso8601String().split('T').first,
    );
    String selectedMonth = isEditing ? asString(item['fee_month'], 'SEPTEMBER') : 'SEPTEMBER';
    final yearCtrl = TextEditingController(text: isEditing ? asString(item['fee_year']) : '2026');
    String paymentStatus = isEditing ? asString(item['payment_status'], 'PAID') : 'PAID';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Fee Record' : 'Record Fee Payment'),
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
                            value: selectedMemberId,
                            decoration: const InputDecoration(labelText: 'Member *'),
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
                        TextFormField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Fee Amount (₹) *'),
                          validator: (v) => Validators.positiveNumber(v, label: 'Amount'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateCtrl,
                          decoration: const InputDecoration(labelText: 'Payment Date (YYYY-MM-DD) *'),
                          validator: (v) => Validators.requiredField(v, label: 'Date'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedMonth,
                                decoration: const InputDecoration(labelText: 'Month *'),
                                items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                onChanged: (v) => setDialogState(() => selectedMonth = v ?? 'SEPTEMBER'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: yearCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Year *'),
                                validator: (v) => Validators.positiveNumber(v, label: 'Year'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: paymentStatus,
                          decoration: const InputDecoration(labelText: 'Payment Status *'),
                          items: const [
                            DropdownMenuItem(value: 'PAID', child: Text('PAID')),
                            DropdownMenuItem(value: 'UNPAID', child: Text('UNPAID')),
                          ],
                          onChanged: (v) => setDialogState(() => paymentStatus = v ?? 'PAID'),
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
                  label: isEditing ? 'Save' : 'Record Fee',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);

                    Map<String, dynamic>? memberObj;
                    if (!isEditing) {
                      memberObj = _members.firstWhere((m) => m['id'] == selectedMemberId, orElse: () => _members.first);
                    }

                    try {
                      final api = context.read<ApiService>();
                      final body = {
                        if (!isEditing) ...{
                          'member_id': selectedMemberId,
                          'member_name': asString(memberObj?['name']),
                          'member_email': asString(memberObj?['email']),
                          'fitness_goal': asString(memberObj?['fitness_goal']),
                        },
                        'fee_amount': double.tryParse(amountCtrl.text.trim()) ?? 0.0,
                        'fee_date': dateCtrl.text.trim(),
                        'fee_month': selectedMonth,
                        'fee_year': int.tryParse(yearCtrl.text.trim()) ?? 2026,
                        'payment_status': paymentStatus,
                      };

                      if (isEditing) {
                        await api.put('/api/admin/fees/${item['id']}', body: body);
                      } else {
                        await api.post('/api/admin/fees', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadAll();
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

  Future<void> _deleteFee(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Fee Record'),
        content: const Text('Are you sure you want to remove this fee ledger entry?'),
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
      await api.delete('/api/admin/fees/$id');
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
      isEmpty: _fees.isEmpty,
      emptyMessage: 'No membership fee transactions recorded yet.',
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
                        Text('Membership Fees & Billing', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Manage dues, receipts, payment status, and member transactions.'),
                      ],
                    ),
                    AppButton(
                      label: 'Record Fee',
                      icon: Icons.add,
                      onPressed: () => _openFeeDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _fees.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final f = _fees[idx];
                    final id = asNum(f['id']);
                    final name = asString(f['member_name'], 'Member');
                    final amount = asNum(f['fee_amount']);
                    final month = asString(f['fee_month']);
                    final year = asString(f['fee_year']);
                    final date = asString(f['fee_date']).split('T').first;
                    final status = asString(f['payment_status'], 'PAID');

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.receipt_long, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            StatusBadge(label: status, positive: status == 'PAID'),
                          ],
                        ),
                        subtitle: Text('$month $year • Paid on: $date'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openFeeDialog(f),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteFee(id),
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
