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
  List<Map<String, dynamic>> _paidHistory = [];

  Map<String, dynamic>? _currentMonthStatus;

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  // ============================================================
  // FETCH FEES
  // ============================================================

  Future<void> _fetchFees() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final api = context.read<ApiService>();

    try {
      final results = await Future.wait([
        api.get('/api/member/fees'),
        api.get('/api/member/fees/current-month/paid-status'),
        api.get('/api/member/fees/paid-history'),
      ]);

      final feesResponse = results[0];
      final currentStatusResponse = results[1];
      final paidHistoryResponse = results[2];

      // ========================================================
      // ALL FEES
      // ========================================================

      final feesList = _extractList(
        feesResponse,
        const [
          'fees',
          'data',
        ],
      );

      // ========================================================
      // CURRENT MONTH STATUS
      // ========================================================

      final currentStatus =
          _extractMap(currentStatusResponse);

      // ========================================================
      // PAID HISTORY
      // ========================================================

      final paidHistoryList = _extractList(
        paidHistoryResponse,
        const [
          'fees',
          'paid_history',
          'history',
          'data',
        ],
      );

      if (!mounted) return;

      setState(() {
        _fees = asMapList(feesList);
        _currentMonthStatus = currentStatus;
        _paidHistory = asMapList(paidHistoryList);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load membership fee records.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // EXTRACT LIST
  // ============================================================

  List<dynamic> _extractList(
    dynamic response,
    List<String> keys,
  ) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      for (final key in keys) {
        final value = response[key];

        if (value is List) {
          return value;
        }
      }
    }

    if (response is Map) {
      for (final key in keys) {
        final value = response[key];

        if (value is List) {
          return value;
        }
      }
    }

    return [];
  }

  // ============================================================
  // EXTRACT MAP
  // ============================================================

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return {};
  }

  // ============================================================
  // CURRENT PAYMENT STATUS
  // ============================================================

  String get _currentPaymentStatus {
    final value =
        _currentMonthStatus?['payment_status'];

    if (value == null) {
      return 'UNPAID';
    }

    final status =
        value.toString().trim().toUpperCase();

    return status.isEmpty ? 'UNPAID' : status;
  }

  // ============================================================
  // CURRENT MONTH
  // ============================================================

  String get _currentMonth {
    return asString(
      _currentMonthStatus?['month'],
      'CURRENT MONTH',
    ).toUpperCase();
  }

  // ============================================================
  // CURRENT YEAR
  // ============================================================

  String get _currentYear {
    return asString(
      _currentMonthStatus?['year'],
      '',
    );
  }

  // ============================================================
  // CURRENT FEE
  //
  // First use current-status fee_amount.
  // If backend returns null, find amount from /fees.
  // ============================================================

  num get _currentFeeAmount {
    final apiAmount =
        _currentMonthStatus?['fee_amount'];

    if (apiAmount != null) {
      final amount = asNum(apiAmount);

      if (amount > 0) {
        return amount;
      }
    }

    final currentFee =
        _findDetailedFee(
      _currentMonth,
      _currentYear,
    );

    if (currentFee != null) {
      return asNum(
        currentFee['fee_amount'],
      );
    }

    return 0;
  }

  // ============================================================
  // FIND DETAILED FEE BY MONTH + YEAR
  // ============================================================

  Map<String, dynamic>? _findDetailedFee(
    String month,
    String year,
  ) {
    for (final fee in _fees) {
      final feeMonth = asString(
        fee['fee_month'],
        '',
      ).toUpperCase();

      final feeYear = asString(
        fee['fee_year'],
        '',
      );

      if (feeMonth == month.toUpperCase() &&
          feeYear == year) {
        return fee;
      }
    }

    return null;
  }

  // ============================================================
  // SHOW INDIVIDUAL FEE DETAILS
  // ============================================================

  Future<void> _showFeeDetails(
    int feeId,
  ) async {
    final api = context.read<ApiService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final response = await api.get(
        '/api/member/fees/$feeId',
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      final fee = _extractFeeObject(response);

      if (fee == null || fee.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fee details not found.',
            ),
          ),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (_) {
          return _FeeDetailsDialog(
            fee: fee,
          );
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load fee details.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EXTRACT SINGLE FEE
  // ============================================================

  Map<String, dynamic>? _extractFeeObject(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      if (response['fee'] is Map) {
        return Map<String, dynamic>.from(
          response['fee'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }

      if (response.containsKey('fee_amount') ||
          response.containsKey('fee_date') ||
          response.containsKey('payment_status')) {
        return response;
      }
    }

    if (response is Map) {
      if (response['fee'] is Map) {
        return Map<String, dynamic>.from(
          response['fee'] as Map,
        );
      }

      if (response['data'] is Map) {
        return Map<String, dynamic>.from(
          response['data'] as Map,
        );
      }
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final padding =
        Responsive.pagePadding(context);

    final status =
        _currentPaymentStatus;

    final isPaid = status == 'PAID';

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchFees,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchFees,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Membership Fees & Dues',
                              style: theme
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Review your current payment status and fee history.',
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed:
                            _loading
                                ? null
                                : _fetchFees,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CURRENT MONTH CARD
                  // ==================================================

                  Card(
                    color: scheme
                        .surfaceContainerHighest,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder:
                            (
                              context,
                              constraints,
                            ) {
                          final small =
                              constraints.maxWidth <
                                  600;

                          if (small) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _buildStatusHeader(
                                  context,
                                  isPaid,
                                  status,
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                _buildCurrentFee(
                                  context,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child:
                                    _buildStatusHeader(
                                  context,
                                  isPaid,
                                  status,
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              _buildCurrentFee(
                                context,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // PAID HISTORY
                  // ==================================================

                  Text(
                    'Paid Fee History',
                    style: theme.textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_paidHistory.isEmpty)
                    _buildEmptyCard(
                      context,
                      'No paid fee history found.',
                    )
                  else
                    _buildPaidHistory(
                      context,
                    ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // ALL FEES
                  // ==================================================

                  Text(
                    'All Fee Records',
                    style: theme.textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_fees.isEmpty)
                    _buildEmptyCard(
                      context,
                      'No fee transaction records found.',
                    )
                  else
                    _buildAllFees(
                      context,
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

  // ============================================================
  // STATUS HEADER
  // ============================================================

  Widget _buildStatusHeader(
    BuildContext context,
    bool isPaid,
    String status,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          isPaid
              ? Icons.check_circle
              : Icons.error_outline,
          color: isPaid
              ? scheme.primary
              : scheme.error,
          size: 34,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Current Month Billing Status',
                style: theme.textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPaid
                    ? 'Your membership fee is paid for this month.'
                    : 'Your membership fee is currently unpaid.',
                style: theme
                    .textTheme
                    .bodySmall,
              ),
              const SizedBox(height: 10),
              StatusBadge(
                label: status,
                positive: isPaid,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CURRENT FEE
  // ============================================================

  Widget _buildCurrentFee(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final amount =
        _currentFeeAmount;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outlineVariant,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            '$_currentMonth $_currentYear',
            style: theme
                .textTheme
                .bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            amount > 0
                ? '₹${amount.toStringAsFixed(0)}'
                : '—',
            style: theme
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Current fee',
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
                  scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAID HISTORY
  //
  // IMPORTANT:
  // paid-history API only returns:
  // fee_month
  // fee_year
  // payment_status
  //
  // We use /fees to find amount/date when available.
  // ============================================================

  Widget _buildPaidHistory(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children:
          _paidHistory.map((history) {
        final month = asString(
          history['fee_month'],
          '',
        ).toUpperCase();

        final year = asString(
          history['fee_year'],
          '',
        );

        final status = asString(
          history['payment_status'],
          'PAID',
        ).toUpperCase();

        // Find matching detailed fee.
        final detailedFee =
            _findDetailedFee(
          month,
          year,
        );

        final amount = detailedFee == null
            ? 0
            : asNum(
                detailedFee['fee_amount'],
              );

        final date = detailedFee == null
            ? ''
            : _formatDate(
                detailedFee['fee_date'],
              );

        final feeId =
            detailedFee == null
                ? null
                : _toInt(
                    detailedFee['id'],
                  );

        return Card(
          margin:
              const EdgeInsets.only(
            bottom: 10,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(12),
            onTap: feeId == null
                ? null
                : () {
                    _showFeeDetails(
                      feeId,
                    );
                  },
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        scheme.primary
                            .withValues(
                      alpha: 0.10,
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color:
                          scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$month $year',
                          style: theme
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          date.isEmpty
                              ? 'Payment recorded'
                              : 'Paid on: $date',
                          style: theme
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      if (amount > 0)
                        Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style: theme
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      StatusBadge(
                        label: status,
                        positive:
                            status == 'PAID',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // ALL FEES
  // ============================================================

  Widget _buildAllFees(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children:
          _fees.map((fee) {
        final id =
            _toInt(fee['id']);

        final amount = asNum(
          fee['fee_amount'],
        );

        final month = asString(
          fee['fee_month'],
          '',
        ).toUpperCase();

        final year = asString(
          fee['fee_year'],
          '',
        );

        final date = _formatDate(
          fee['fee_date'],
        );

        final status = asString(
          fee['payment_status'],
          'UNPAID',
        ).toUpperCase();

        final isPaid =
            status == 'PAID';

        return Card(
          margin:
              const EdgeInsets.only(
            bottom: 10,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(12),
            onTap: id == null
                ? null
                : () {
                    _showFeeDetails(
                      id,
                    );
                  },
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder:
                    (
                      context,
                      constraints,
                    ) {
                  final small =
                      constraints.maxWidth <
                          600;

                  if (small) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  scheme.primary
                                      .withValues(
                                alpha: 0.10,
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color:
                                    scheme.primary,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                '$month $year',
                                style: theme
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: status,
                              positive:
                                  isPaid,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Payment date: $date',
                          style: theme
                              .textTheme
                              .bodySmall,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Amount: ₹${amount.toStringAsFixed(0)}',
                          style: theme
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            scheme.primary
                                .withValues(
                          alpha: 0.10,
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color:
                              scheme.primary,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              '$month $year',
                              style: theme
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Payment date: $date',
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: theme
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      StatusBadge(
                        label: status,
                        positive:
                            isPaid,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 15,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // EMPTY CARD
  // ============================================================

  Widget _buildEmptyCard(
    BuildContext context,
    String message,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons
                    .receipt_long_outlined,
                size: 42,
                color:
                    scheme.onSurfaceVariant,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                message,
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTEGER HELPER
  // ============================================================

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // DATE HELPER
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return '';
    }

    return text.split('T').first;
  }
}


// ================================================================
// FEE DETAILS DIALOG
// ================================================================

class _FeeDetailsDialog extends StatelessWidget {
  const _FeeDetailsDialog({
    required this.fee,
  });

  final Map<String, dynamic> fee;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = asNum(
      fee['fee_amount'],
    );

    final status = asString(
      fee['payment_status'],
      'UNPAID',
    ).toUpperCase();

    final date =
        fee['fee_date'] == null
            ? '—'
            : fee['fee_date']
                .toString()
                .split('T')
                .first;

    return AlertDialog(
      title: const Text(
        'Fee Details',
      ),
      content:
          SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Month',
              value: asString(
                fee['fee_month'],
                '—',
              ),
            ),
            _DetailRow(
              label: 'Year',
              value: asString(
                fee['fee_year'],
                '—',
              ),
            ),
            _DetailRow(
              label: 'Fee Amount',
              value:
                  '₹${amount.toStringAsFixed(0)}',
            ),
            _DetailRow(
              label: 'Fee Date',
              value: date,
            ),
            _DetailRow(
              label: 'Payment Status',
              value: status,
            ),
            if (fee['member_name'] != null)
              _DetailRow(
                label: 'Member',
                value: asString(
                  fee['member_name'],
                ),
              ),
            if (fee['member_email'] != null)
              _DetailRow(
                label: 'Email',
                value: asString(
                  fee['member_email'],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
          ),
        ),
      ],
    );
  }
}


// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}