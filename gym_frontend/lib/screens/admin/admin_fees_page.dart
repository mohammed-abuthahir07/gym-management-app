import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminFeesPage extends StatefulWidget {
  const AdminFeesPage({super.key});

  @override
  State<AdminFeesPage> createState() => _AdminFeesPageState();
}

class _AdminFeesPageState extends State<AdminFeesPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _fees = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _currentMonthMembers = [];

  num _totalMembersCount = 0;
  num _paidCount = 0;
  num _unpaidCount = 0;

  String _currentMonthName = '';
  num _currentYear = DateTime.now().year;

  late TabController _tabController;

  static const List<String> _months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String _dateOnly(dynamic value) {
    final text = asString(value);

    if (text.isEmpty) {
      return '';
    }

    return text.split('T').first;
  }

  String _todayString() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  bool _isValidDateFormat(String value) {
    final text = value.trim();

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return false;
    }

    final parts = text.split('-');

    if (parts.length != 3) {
      return false;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return false;
    }

    if (year < 2000 || year > 2100) {
      return false;
    }

    if (month < 1 || month > 12) {
      return false;
    }

    if (day < 1 || day > 31) {
      return false;
    }

    final date = DateTime(year, month, day);

    return date.year == year &&
        date.month == month &&
        date.day == day;
  }

  String? _validateDate(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Payment date is required';
    }

    if (!_isValidDateFormat(text)) {
      return 'Use YYYY-MM-DD';
    }

    return null;
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(text);

    if (amount == null) {
      return 'Enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  String? _validateYear(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Year is required';
    }

    final year = int.tryParse(text);

    if (year == null) {
      return 'Enter a valid year';
    }

    if (year < 2000 || year > 2100) {
      return 'Enter a valid year';
    }

    return null;
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red : null,
        ),
      );
  }

  // ============================================================
  // LOAD ALL DATA
  // ============================================================

  Future<void> _loadAll() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      final results = await Future.wait<dynamic>([
        api.get('/api/admin/fees'),
        api.get('/api/admin/members'),
        api.get('/api/admin/fees/current-month'),
      ]);

      final feeRes = _asMap(results[0]);
      final memberRes = _asMap(results[1]);
      final currentMonthRes = _asMap(results[2]);

      final feeList = feeRes['fees'] is List
          ? feeRes['fees'] as List
          : <dynamic>[];

      final memberList = memberRes['members'] is List
          ? memberRes['members'] as List
          : <dynamic>[];

      final currentMonthList = currentMonthRes['members'] is List
          ? currentMonthRes['members'] as List
          : <dynamic>[];

      final fees = asMapList(feeList);
      final members = asMapList(memberList);
      final currentMembers = asMapList(currentMonthList);

      if (!mounted) return;

      setState(() {
        _fees = fees;
        _members = members;
        _currentMonthMembers = currentMembers;

        _totalMembersCount = asNum(
          currentMonthRes['total_members'] ?? members.length,
        );

        _paidCount = asNum(
          currentMonthRes['paid'] ?? 0,
        );

        _unpaidCount = asNum(
          currentMonthRes['unpaid'] ?? 0,
        );

        _currentMonthName = asString(
          currentMonthRes['month'],
          _months[DateTime.now().month - 1],
        );

        _currentYear = asNum(
          currentMonthRes['year'] ?? DateTime.now().year,
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load fee information.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // CREATE / UPDATE FEE
  // ============================================================

  Future<void> _openFeeDialog([
    Map<String, dynamic>? item,
  ]) async {
    final bool isEditing = item != null;

    if (!isEditing && _members.isEmpty) {
      _showMessage(
        'No members registered to record fees against.',
        error: true,
      );
      return;
    }

    final initialMemberId = isEditing
        ? asNum(item['member_id'])
        : asNum(_members.first['id']);

    num? selectedMemberId = initialMemberId;

    final amountController = TextEditingController(
      text: isEditing
          ? asString(item['fee_amount'])
          : '1500',
    );

    final dateController = TextEditingController(
      text: isEditing
          ? _dateOnly(item['fee_date'])
          : _todayString(),
    );

    String selectedMonth = isEditing
        ? asString(
            item['fee_month'],
            _months[DateTime.now().month - 1],
          )
        : _months[DateTime.now().month - 1];

    final yearController = TextEditingController(
      text: isEditing
          ? asString(item['fee_year'])
          : DateTime.now().year.toString(),
    );

    String paymentStatus = isEditing
        ? asString(
            item['payment_status'],
            'PAID',
          )
        : 'PAID';

    final formKey = GlobalKey<FormState>();

    bool dialogSaving = false;
    bool savedSuccessfully = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing
                        ? Icons.edit_note_outlined
                        : Icons.receipt_long_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Edit Fee Record'
                          : 'Record Fee Payment',
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ==================================================
                        // MEMBER
                        // ==================================================

                        if (!isEditing) ...[
                          DropdownButtonFormField<num>(
                            value: selectedMemberId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Member *',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                            items: _members.map((member) {
                              return DropdownMenuItem<num>(
                                value: asNum(member['id']),
                                child: Text(
                                  asString(
                                    member['name'],
                                    'Member',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Select a member';
                              }

                              return null;
                            },
                            onChanged: dialogSaving
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      selectedMemberId = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ==================================================
                        // EDIT MEMBER INFORMATION
                        // ==================================================

                        if (isEditing) ...[
                          _MemberInfoBox(
                            name: asString(
                              item['member_name'],
                              'Member',
                            ),
                            email: asString(
                              item['member_email'],
                              'No email',
                            ),
                            fitnessGoal: asString(
                              item['fitness_goal'],
                              'General Fitness',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ==================================================
                        // AMOUNT
                        // ==================================================

                        TextFormField(
                          controller: amountController,
                          enabled: !dialogSaving,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Fee Amount (₹) *',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                            ),
                          ),
                          validator: _validateAmount,
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // DATE
                        // ==================================================

                        TextFormField(
                          controller: dateController,
                          enabled: !dialogSaving,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText:
                                'Payment Date (YYYY-MM-DD) *',
                            hintText: '2026-09-09',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          validator: _validateDate,
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // MONTH + YEAR
                        // ==================================================

                        LayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            if (constraints.maxWidth < 380) {
                              return Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedMonth,
                                    isExpanded: true,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'Month *',
                                      prefixIcon: Icon(
                                        Icons.date_range_outlined,
                                      ),
                                    ),
                                    items: _months.map((month) {
                                      return DropdownMenuItem<String>(
                                        value: month,
                                        child: Text(month),
                                      );
                                    }).toList(),
                                    onChanged: dialogSaving
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              selectedMonth =
                                                  value ??
                                                      selectedMonth;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: yearController,
                                    enabled: !dialogSaving,
                                    keyboardType:
                                        TextInputType.number,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'Year *',
                                      prefixIcon: Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                    ),
                                    validator: _validateYear,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      DropdownButtonFormField<String>(
                                    value: selectedMonth,
                                    isExpanded: true,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'Month *',
                                      prefixIcon: Icon(
                                        Icons.date_range_outlined,
                                      ),
                                    ),
                                    items: _months.map((month) {
                                      return DropdownMenuItem<String>(
                                        value: month,
                                        child: Text(month),
                                      );
                                    }).toList(),
                                    onChanged: dialogSaving
                                        ? null
                                        : (value) {
                                            setDialogState(() {
                                              selectedMonth =
                                                  value ??
                                                      selectedMonth;
                                            });
                                          },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: yearController,
                                    enabled: !dialogSaving,
                                    keyboardType:
                                        TextInputType.number,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'Year *',
                                      prefixIcon: Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                    ),
                                    validator: _validateYear,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // PAYMENT STATUS
                        // ==================================================

                        DropdownButtonFormField<String>(
                          value: paymentStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Payment Status *',
                            prefixIcon: Icon(
                              Icons.payment_outlined,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'PAID',
                              child: Text('PAID'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'UNPAID',
                              child: Text('UNPAID'),
                            ),
                          ],
                          onChanged: dialogSaving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    paymentStatus =
                                        value ?? 'PAID';
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: dialogSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                AppButton(
                  loading: dialogSaving,
                  label: isEditing
                      ? 'Save Changes'
                      : 'Record Fee',
                  icon: isEditing
                      ? Icons.save_outlined
                      : Icons.add,
                  onPressed: dialogSaving
                      ? null
                      : () async {
                          // ============================================
                          // VALIDATE
                          // ============================================

                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          // ============================================
                          // MEMBER
                          // ============================================

                          Map<String, dynamic>? member;

                          if (!isEditing) {
                            if (selectedMemberId == null) {
                              _showDialogError(
                                dialogContext,
                                'Please select a member.',
                              );
                              return;
                            }

                            member = _members.firstWhere(
                              (m) =>
                                  asNum(m['id']) ==
                                  selectedMemberId,
                              orElse: () =>
                                  <String, dynamic>{},
                            );

                            if (member.isEmpty) {
                              _showDialogError(
                                dialogContext,
                                'Selected member was not found.',
                              );
                              return;
                            }
                          }

                          // ============================================
                          // BUILD REQUEST BODY
                          // ============================================

                          final Map<String, dynamic> body;

                          if (isEditing) {
                            body = {
                              'member_name': asString(
                                item['member_name'],
                              ),
                              'member_email': asString(
                                item['member_email'],
                              ),
                              'fitness_goal': asString(
                                item['fitness_goal'],
                              ),
                              'fee_amount': double.parse(
                                amountController.text.trim(),
                              ),
                              'fee_date':
                                  dateController.text.trim(),
                              'fee_month': selectedMonth,
                              'fee_year': int.parse(
                                yearController.text.trim(),
                              ),
                              'payment_status': paymentStatus,
                            };
                          } else {
                            body = {
                              'member_id': selectedMemberId,
                              'member_name': asString(
                                member?['name'],
                              ),
                              'member_email': asString(
                                member?['email'],
                              ),
                              'fitness_goal': asString(
                                member?['fitness_goal'],
                              ),
                              'fee_amount': double.parse(
                                amountController.text.trim(),
                              ),
                              'fee_date':
                                  dateController.text.trim(),
                              'fee_month': selectedMonth,
                              'fee_year': int.parse(
                                yearController.text.trim(),
                              ),
                              'payment_status': paymentStatus,
                            };
                          }

                          setDialogState(() {
                            dialogSaving = true;
                          });

                          try {
                            final api =
                                context.read<ApiService>();

                            if (isEditing) {
                              await api.put(
                                '/api/admin/fees/${item['id']}',
                                body: body,
                              );
                            } else {
                              await api.post(
                                '/api/admin/fees',
                                body: body,
                              );
                            }

                            savedSuccessfully = true;

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } on ApiException catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                dialogSaving = false;
                              });

                              _showDialogError(
                                dialogContext,
                                e.message,
                              );
                            }
                          } catch (_) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                dialogSaving = false;
                              });

                              _showDialogError(
                                dialogContext,
                                'Failed to save fee record.',
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );

    // ==============================================================
    // DIALOG CLOSED
    // ==============================================================

    amountController.dispose();
    dateController.dispose();
    yearController.dispose();

    if (savedSuccessfully && mounted) {
      _showMessage(
        isEditing
            ? 'Fee updated successfully.'
            : 'Fee created successfully.',
      );

      await _loadAll();
    }
  }

  void _showDialogError(
    BuildContext dialogContext,
    String message,
  ) {
    if (!dialogContext.mounted) return;

    ScaffoldMessenger.of(dialogContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteFee(num id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Fee Record'),
          content: const Text(
            'Are you sure you want to permanently delete this fee record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final api = context.read<ApiService>();

      await api.delete(
        '/api/admin/fees/$id',
      );

      _showMessage(
        'Fee deleted successfully.',
      );

      await _loadAll();
    } on ApiException catch (e) {
      _showMessage(
        e.message,
        error: true,
      );
    } catch (_) {
      _showMessage(
        'Failed to delete fee.',
        error: true,
      );
    }
  }

  // ============================================================
  // MEMBER FEE HISTORY
  // ============================================================

  Future<void> _viewMemberHistory(
    num memberId,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/fees/member/$memberId',
      );

      final data = _asMap(response);

      final history = data['fees'] is List
          ? asMapList(data['fees'])
          : <Map<String, dynamic>>[];

      final memberName = history.isNotEmpty
          ? asString(
              history.first['member_name'],
              'Member',
            )
          : 'Member';

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$memberName - Fee History',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 650,
              height: 450,
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'No fee history found.',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      itemCount: history.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final fee = history[index];

                        final amount = asNum(
                          fee['fee_amount'],
                        );

                        final status = asString(
                          fee['payment_status'],
                          'UNPAID',
                        );

                        final isPaid = status == 'PAID';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 21,
                                backgroundColor: isPaid
                                    ? Colors.green.withValues(
                                        alpha: 0.10,
                                      )
                                    : Colors.orange.withValues(
                                        alpha: 0.10,
                                      ),
                                child: Icon(
                                  isPaid
                                      ? Icons.check_circle_outline
                                      : Icons.pending_outlined,
                                  color: isPaid
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${amount.toStringAsFixed(0)}',
                                      style: theme
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${asString(fee['fee_month'])} '
                                      '${asString(fee['fee_year'])}',
                                      style: theme
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _dateOnly(
                                        fee['fee_date'],
                                      ),
                                      style: theme
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: status,
                                positive: isPaid,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } on ApiException catch (e) {
      _showMessage(
        e.message,
        error: true,
      );
    } catch (_) {
      _showMessage(
        'Failed to load member fee history.',
        error: true,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _loadAll,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1150,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ========================================================
                  // HEADER
                  // ========================================================

                  _buildHeader(theme),

                  const SizedBox(height: 24),

                  // ========================================================
                  // STATISTICS
                  // ========================================================

                  _buildStatistics(),

                  const SizedBox(height: 28),

                  // ========================================================
                  // TABS
                  // ========================================================

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorSize:
                          TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(
                          icon: Icon(
                            Icons.receipt_long_outlined,
                          ),
                          text: 'Full Ledger History',
                        ),
                        Tab(
                          icon: Icon(
                            Icons.calendar_month_outlined,
                          ),
                          text: 'Current Month Status',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ========================================================
                  // TAB CONTENT
                  // ========================================================

                  SizedBox(
                    height: 570,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLedgerTab(
                          theme,
                          scheme,
                        ),
                        _buildCurrentMonthTab(
                          theme,
                          scheme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Membership Fees & Billing',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage dues, payments, fee history and member billing.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Record Fee',
                  icon: Icons.add,
                  onPressed: () =>
                      _openFeeDialog(),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membership Fees & Billing',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage dues, payments, fee history and member billing.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 150,
              child: AppButton(
                label: 'Record Fee',
                icon: Icons.add,
                onPressed: () =>
                    _openFeeDialog(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final activeMembersCard = StatCard(
          title: 'Active Members',
          value: '$_totalMembersCount',
          icon: Icons.group_outlined,
        );

        final paidCard = StatCard(
          title: 'Paid ($_currentMonthName)',
          value: '$_paidCount',
          icon: Icons.check_circle_outline,
        );

        final unpaidCard = StatCard(
          title: 'Unpaid ($_currentMonthName)',
          value: '$_unpaidCount',
          icon: Icons.warning_amber_outlined,
        );

        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: activeMembersCard,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: paidCard,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: unpaidCard,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: activeMembersCard,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: paidCard,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: unpaidCard,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LEDGER TAB
  // ============================================================

  Widget _buildLedgerTab(
    ThemeData theme,
    ColorScheme scheme,
  ) {
    if (_fees.isEmpty) {
      return const Center(
        child: Text(
          'No membership fee transactions recorded yet.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        4,
        4,
        4,
        24,
      ),
      itemCount: _fees.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
      itemBuilder: (
        context,
        index,
      ) {
        final fee = _fees[index];

        final id = asNum(fee['id']);
        final memberId = asNum(
          fee['member_id'],
        );

        final name = asString(
          fee['member_name'],
          'Member',
        );

        final email = asString(
          fee['member_email'],
        );

        final amount = asNum(
          fee['fee_amount'],
        );

        final month = asString(
          fee['fee_month'],
        );

        final year = asString(
          fee['fee_year'],
        );

        final date = _dateOnly(
          fee['fee_date'],
        );

        final status = asString(
          fee['payment_status'],
          'UNPAID',
        );

        final isPaid = status == 'PAID';

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                // ========================================================
                // MOBILE
                // ========================================================

                if (constraints.maxWidth < 650) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor:
                                scheme.primary
                                    .withValues(
                              alpha: 0.10,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: scheme.primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: theme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: theme
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                                const SizedBox(height: 7),
                                StatusBadge(
                                  label: status,
                                  positive: isPaid,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '₹${amount.toStringAsFixed(0)}',
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: scheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 17,
                              color:
                                  scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$month $year',
                                style: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              date,
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
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                _viewMemberHistory(
                              memberId,
                            ),
                            icon: const Icon(
                              Icons.history,
                              size: 18,
                            ),
                            label:
                                const Text('History'),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () =>
                                _openFeeDialog(fee),
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () =>
                                _deleteFee(id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // ========================================================
                // DESKTOP / TABLET
                // ========================================================

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          scheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: theme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              StatusBadge(
                                label: status,
                                positive: isPaid,
                              ),
                            ],
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$month $year',
                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
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
                    ),

                    const SizedBox(width: 20),

                    SizedBox(
                      width: 100,
                      child: Text(
                        '₹${amount.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip:
                              'View member history',
                          onPressed: () =>
                              _viewMemberHistory(
                            memberId,
                          ),
                          icon: const Icon(
                            Icons.history,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              _openFeeDialog(fee),
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () =>
                              _deleteFee(id),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CURRENT MONTH TAB
  // ============================================================

  Widget _buildCurrentMonthTab(
    ThemeData theme,
    ColorScheme scheme,
  ) {
    if (_currentMonthMembers.isEmpty) {
      return const Center(
        child: Text(
          'No active members found for the current month.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        4,
        4,
        4,
        24,
      ),
      itemCount: _currentMonthMembers.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
      itemBuilder: (
        context,
        index,
      ) {
        final member =
            _currentMonthMembers[index];

        final memberId = asNum(
          member['member_id'],
        );

        final name = asString(
          member['member_name'],
          'Member',
        );

        final email = asString(
          member['member_email'],
        );

        final goal = asString(
          member['fitness_goal'],
          'General Fitness',
        );

        final status = asString(
          member['payment_status'],
          'UNPAID',
        );

        final isPaid = status == 'PAID';

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                // ========================================================
                // MOBILE
                // ========================================================

                if (constraints.maxWidth < 650) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: isPaid
                                ? Colors.green.withValues(
                                    alpha: 0.10,
                                  )
                                : Colors.orange.withValues(
                                    alpha: 0.10,
                                  ),
                            child: Icon(
                              isPaid
                                  ? Icons.check_circle_outline
                                  : Icons.hourglass_empty,
                              color: isPaid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: theme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: theme
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          StatusBadge(
                            label: status,
                            positive: isPaid,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 18,
                              color:
                                  scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                goal,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: theme
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _viewMemberHistory(
                            memberId,
                          ),
                          icon: const Icon(
                            Icons.history,
                            size: 18,
                          ),
                          label:
                              const Text('Fee History'),
                        ),
                      ),
                    ],
                  );
                }

                // ========================================================
                // DESKTOP / TABLET
                // ========================================================

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isPaid
                          ? Colors.green.withValues(
                              alpha: 0.10,
                            )
                          : Colors.orange.withValues(
                              alpha: 0.10,
                            ),
                      child: Icon(
                        isPaid
                            ? Icons.check_circle_outline
                            : Icons.hourglass_empty,
                        color: isPaid
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 18,
                            color:
                                scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    StatusBadge(
                      label: status,
                      positive: isPaid,
                    ),

                    const SizedBox(width: 12),

                    OutlinedButton.icon(
                      onPressed: () =>
                          _viewMemberHistory(
                        memberId,
                      ),
                      icon: const Icon(
                        Icons.history,
                        size: 18,
                      ),
                      label: const Text('History'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ======================================================================
// MEMBER INFO BOX
// ======================================================================

class _MemberInfoBox extends StatelessWidget {
  final String name;
  final String email;
  final String fitnessGoal;

  const _MemberInfoBox({
    required this.name,
    required this.email,
    required this.fitnessGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 19,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Member Information',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 5),

          Text(
            'Fitness Goal: $fitnessGoal',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}