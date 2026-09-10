import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberFeesPage extends StatefulWidget {
  const MemberFeesPage({super.key});

  @override
  State<MemberFeesPage> createState() => _MemberFeesPageState();
}

class _MemberFeesPageState extends State<MemberFeesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _fees = [];
  Map<String, dynamic>? _currentMonthStatus;

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  Future<void> _fetchFees() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/member/fees').catchError((_) => <String, dynamic>{}),
        api.get('/api/member/fees/current-month/paid-status').catchError((_) => <String, dynamic>{}),
      ]);

      final feesRes = results[0];
      final statusRes = results[1] as Map<String, dynamic>;

      List<dynamic> list = [];
      if (feesRes is Map && (feesRes['fees'] is List || feesRes['data'] is List)) {
        list = (feesRes['fees'] ?? feesRes['data']) as List;
      } else if (feesRes is List) {
        list = feesRes;
      }

      setState(() {
        _fees = asMapList(list);
        _currentMonthStatus = statusRes;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load membership fee records.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    final status = asString(_currentMonthStatus?['payment_status'] ?? _currentMonthStatus?['status'], 'PAID');

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchFees,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchFees,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                          Text('Membership Fees & Dues', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Review your payment history and current billing standing.'),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchFees,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current Month Status Card
                  Card(
                    color: scheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                status.toUpperCase() == 'PAID' ? Icons.check_circle : Icons.error_outline,
                                color: status.toUpperCase() == 'PAID' ? Colors.green : Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current Month Billing Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(
                                    status.toUpperCase() == 'PAID'
                                        ? 'Your account is in good standing.'
                                        : 'Fee payment is due for this cycle.',
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StatusBadge(
                            label: status.toUpperCase(),
                            positive: status.toUpperCase() == 'PAID',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Payment Logs & Receipts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (_fees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('No fee transaction history found.')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _fees.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final fee = _fees[idx];
                        final amount = asNum(fee['fee_amount']);
                        final month = asString(fee['fee_month']);
                        final year = asString(fee['fee_year']);
                        final date = asString(fee['fee_date']).split('T').first;
                        final feeStatus = asString(fee['payment_status'], 'PAID');

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.receipt_long, color: scheme.primary),
                            ),
                            title: Text('$month $year', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Paid on: $date'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(width: 12),
                                StatusBadge(label: feeStatus, positive: feeStatus.toUpperCase() == 'PAID'),
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
      ),
    );
  }
}
