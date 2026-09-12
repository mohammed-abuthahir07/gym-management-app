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

  static const List<String> _units = [
    'DAY',
    'MONTH',
    'YEAR',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  // ============================================================
  // GET ALL PLANS
  // ============================================================

  Future<void> _fetchPlans() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/plans',
      );

      List<dynamic> rawPlans = [];

      if (response is Map && response['plans'] is List) {
        rawPlans = response['plans'] as List;
      } else if (response is List) {
        rawPlans = response;
      }

      final plans = asMapList(rawPlans);

      if (!mounted) return;

      setState(() {
        _plans = plans;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load membership plans.';
        _loading = false;
      });
    }
  }

  // ============================================================
  // CREATE PLAN
  // ============================================================

  Future<void> _createPlan() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _PlanFormDialog(
          editMode: false,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _fetchPlans();

      if (!mounted) return;

      _showMessage(
        'Plan created successfully.',
      );
    }
  }

  // ============================================================
  // EDIT PLAN
  // ============================================================

  Future<void> _editPlan(
    Map<String, dynamic> plan,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PlanFormDialog(
          editMode: true,
          plan: plan,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _fetchPlans();

      if (!mounted) return;

      _showMessage(
        'Plan updated successfully.',
      );
    }
  }

  // ============================================================
  // VIEW PLAN
  // ============================================================

  Future<void> _viewPlan(
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'];

    if (planId == null) {
      _showMessage('Plan ID is missing.');
      return;
    }

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/plans/$planId',
      );

      if (!mounted) return;

      Map<String, dynamic> selectedPlan = plan;

      if (response is Map && response['plan'] is Map) {
        selectedPlan = Map<String, dynamic>.from(
          response['plan'] as Map,
        );
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final name = asString(
            selectedPlan['name'],
            'Plan',
          );

          final description = asString(
            selectedPlan['description'],
          );

          final durationValue = asNum(
            selectedPlan['duration_value'],
          );

          final durationUnit = asString(
            selectedPlan['duration_unit'],
          );

          final price = asNum(
            selectedPlan['price'],
          );

          final extraFeatures = asString(
            selectedPlan['extra_features'],
          );

          final status = asString(
            selectedPlan['status'],
            'ACTIVE',
          ).toUpperCase();

          return AlertDialog(
            title: Text(name),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InfoRow(
                      label: 'Plan ID',
                      value: '$planId',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Duration',
                      value:
                          '${durationValue.toStringAsFixed(0)} $durationUnit',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Price',
                      value:
                          '₹${price.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Status',
                      value: status,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'No description provided.',
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Extra Features',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      extraFeatures.isNotEmpty
                          ? extraFeatures
                          : 'No extra features provided.',
                    ),
                  ],
                ),
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
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Failed to load plan details.',
      );
    }
  }

  // ============================================================
  // DELETE PLAN - PERMANENT
  // ============================================================

  Future<void> _deletePlan(
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'];

    if (planId == null) {
      _showMessage('Plan ID is missing.');
      return;
    }

    final name = asString(
      plan['name'],
      'this plan',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Plan Permanently?',
          ),
          content: Text(
            'Are you sure you want to permanently delete "$name"?\n\n'
            'This will completely remove the plan from the database. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete Permanently',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final api = context.read<ApiService>();

      await api.delete(
        '/api/admin/plans/$planId',
      );

      if (!mounted) return;

      await _fetchPlans();

      if (!mounted) return;

      _showMessage(
        'Plan deleted permanently.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete plan.',
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // PLAN CARD
  // ============================================================

  Widget _buildPlanCard(
    BuildContext context,
    Map<String, dynamic> plan,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final name = asString(
      plan['name'],
      'Plan',
    );

    final description = asString(
      plan['description'],
    );

    final price = asNum(
      plan['price'],
    );

    final durationValue = asNum(
      plan['duration_value'],
    );

    final durationUnit = asString(
      plan['duration_unit'],
    );

    final extraFeatures = asString(
      plan['extra_features'],
    );

    final status = asString(
      plan['status'],
      'ACTIVE',
    ).toUpperCase();

    final isActive = status == 'ACTIVE';

    final durationText =
        '${durationValue.toStringAsFixed(0)} $durationUnit';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 700;

            // ==================================================
            // MOBILE / SMALL SCREEN
            // ==================================================

            if (compact) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            scheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.payments_outlined,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment:
                              WrapCrossAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            StatusBadge(
                              label: durationText,
                            ),
                            StatusBadge(
                              label: status,
                              positive: isActive,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    description.isNotEmpty
                        ? description
                        : 'No description provided.',
                  ),

                  if (extraFeatures.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      extraFeatures,
                      style:
                          theme.textTheme.bodySmall,
                    ),
                  ],

                  const SizedBox(height: 12),

                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _viewPlan(plan),
                        icon: const Icon(
                          Icons.visibility_outlined,
                        ),
                        label: const Text('View'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _editPlan(plan),
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        label: const Text('Edit'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _deletePlan(plan),
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ==================================================
            // DESKTOP / LARGE SCREEN
            // ==================================================

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      scheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: scheme.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment:
                            WrapCrossAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          StatusBadge(
                            label: durationText,
                          ),
                          StatusBadge(
                            label: status,
                            positive: isActive,
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        description.isNotEmpty
                            ? description
                            : 'No description provided.',
                      ),

                      if (extraFeatures.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          extraFeatures,
                          style:
                              theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'View',
                          onPressed: () =>
                              _viewPlan(plan),
                          icon: const Icon(
                            Icons.visibility_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              _editPlan(plan),
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Delete permanently',
                          onPressed: () =>
                              _deletePlan(plan),
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding =
        Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchPlans,
      isEmpty: _plans.isEmpty,
      emptyMessage:
          'No membership plans created yet.',
      child: SingleChildScrollView(
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

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final compact =
                        constraints.maxWidth < 700;

                    if (compact) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Membership Plans Administration',
                            style: theme.textTheme
                                .headlineMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Define membership tiers and pricing published on the public landing page.',
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Create Plan',
                            icon: Icons.add,
                            onPressed: _createPlan,
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
                                'Membership Plans Administration',
                                style: theme.textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Define membership tiers and pricing published on the public landing page.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        AppButton(
                          label: 'Create Plan',
                          icon: Icons.add,
                          onPressed: _createPlan,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // PLAN LIST
                // ==================================================

                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: _plans.length,
                  separatorBuilder: (
                    _,
                    __,
                  ) =>
                      const SizedBox(height: 12),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _buildPlanCard(
                      context,
                      _plans[index],
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

// ==================================================================
// PLAN FORM DIALOG
// ==================================================================

class _PlanFormDialog extends StatefulWidget {
  final bool editMode;
  final Map<String, dynamic>? plan;

  const _PlanFormDialog({
    required this.editMode,
    this.plan,
  });

  @override
  State<_PlanFormDialog> createState() =>
      _PlanFormDialogState();
}

class _PlanFormDialogState
    extends State<_PlanFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _featuresController;

  String _selectedUnit = 'MONTH';
  String _selectedStatus = 'ACTIVE';

  bool _saving = false;

  static const List<String> _units = [
    'DAY',
    'MONTH',
    'YEAR',
  ];

  static const List<String> _statuses = [
    'ACTIVE',
    'INACTIVE',
  ];

  @override
  void initState() {
    super.initState();

    final plan = widget.plan;

    _nameController = TextEditingController(
      text: widget.editMode
          ? asString(plan?['name'])
          : '',
    );

    _descriptionController =
        TextEditingController(
      text: widget.editMode
          ? asString(plan?['description'])
          : '',
    );

    _durationController =
        TextEditingController(
      text: widget.editMode
          ? asNum(
              plan?['duration_value'],
            ).toStringAsFixed(0)
          : '3',
    );

    _priceController =
        TextEditingController(
      text: widget.editMode
          ? asNum(
              plan?['price'],
            ).toStringAsFixed(0)
          : '2999',
    );

    _featuresController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              plan?['extra_features'],
            )
          : '',
    );

    if (widget.editMode) {
      final unit = asString(
        plan?['duration_unit'],
        'MONTH',
      ).toUpperCase();

      final status = asString(
        plan?['status'],
        'ACTIVE',
      ).toUpperCase();

      if (_units.contains(unit)) {
        _selectedUnit = unit;
      }

      if (_statuses.contains(status)) {
        _selectedStatus = status;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _featuresController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<void> _submit() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final durationValue = int.tryParse(
      _durationController.text.trim(),
    );

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (durationValue == null ||
        durationValue <= 0) {
      _showError(
        'Duration must be a positive integer.',
      );
      return;
    }

    if (price == null || price < 0) {
      _showError(
        'Price must be a valid non-negative number.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final api = context.read<ApiService>();

      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description':
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        'duration_value': durationValue,
        'duration_unit': _selectedUnit,
        'price': price,
        'extra_features':
            _featuresController.text.trim().isEmpty
                ? null
                : _featuresController.text.trim(),
      };

      // ========================================================
      // UPDATE
      // ========================================================

      if (widget.editMode) {
        final planId = widget.plan?['id'];

        if (planId == null) {
          throw Exception(
            'Plan ID is missing.',
          );
        }

        body['status'] = _selectedStatus;

        await api.put(
          '/api/admin/plans/$planId',
          body: body,
        );
      }

      // ========================================================
      // CREATE
      // ========================================================

      else {
        await api.post(
          '/api/admin/plans',
          body: body,
        );
      }

      // ========================================================
      // IMPORTANT
      //
      // Return result to showDialog.
      // Do NOT call setState after Navigator.pop.
      // ========================================================

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(e.message);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.editMode
            ? 'Edit Membership Plan'
            : 'Create Membership Plan',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                // ==================================================
                // NAME
                // ==================================================

                TextFormField(
                  controller: _nameController,
                  enabled: !_saving,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Plan Name *',
                    hintText:
                        'e.g. Platinum Tier',
                    prefixIcon: Icon(
                      Icons
                          .card_membership_outlined,
                    ),
                  ),
                  validator: (value) {
                    return Validators.requiredField(
                      value,
                      label: 'Plan name',
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                TextFormField(
                  controller:
                      _descriptionController,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                    prefixIcon: Icon(
                      Icons
                          .description_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // DURATION
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                            _durationController,
                        enabled: !_saving,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Duration *',
                          prefixIcon:
                              Icon(
                            Icons
                                .schedule_outlined,
                          ),
                        ),
                        validator: (value) {
                          return Validators
                              .positiveNumber(
                            value,
                            label:
                                'Duration',
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                          DropdownButtonFormField<
                              String>(
                        value: _selectedUnit,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Unit *',
                        ),
                        items:
                            _units.map(
                          (unit) {
                            return DropdownMenuItem<
                                String>(
                              value: unit,
                              child:
                                  Text(unit),
                            );
                          },
                        ).toList(),
                        onChanged: _saving
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setState(() {
                                  _selectedUnit =
                                      value;
                                });
                              },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PRICE
                // ==================================================

                TextFormField(
                  controller:
                      _priceController,
                  enabled: !_saving,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Price (₹) *',
                    prefixIcon:
                        Icon(
                      Icons.currency_rupee,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Price is required';
                    }

                    final number =
                        double.tryParse(
                      value.trim(),
                    );

                    if (number == null) {
                      return 'Enter a valid price';
                    }

                    if (number < 0) {
                      return 'Price cannot be negative';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ==================================================
                // EXTRA FEATURES
                // ==================================================

                TextFormField(
                  controller:
                      _featuresController,
                  enabled: !_saving,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Extra Perks & Features',
                    hintText:
                        'e.g. Locker access & sauna included',
                    prefixIcon:
                        Icon(
                      Icons
                          .star_border_outlined,
                    ),
                  ),
                ),

                // ==================================================
                // STATUS - EDIT ONLY
                // ==================================================

                if (widget.editMode) ...[
                  const SizedBox(height: 14),

                  DropdownButtonFormField<
                      String>(
                    value: _selectedStatus,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Status',
                      prefixIcon:
                          Icon(
                        Icons
                            .toggle_on_outlined,
                      ),
                    ),
                    items:
                        _statuses.map(
                      (status) {
                        return DropdownMenuItem<
                            String>(
                          value: status,
                          child:
                              Text(status),
                        );
                      },
                    ).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              _selectedStatus =
                                  value;
                            });
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // ==========================================================
      // ACTIONS
      // ==========================================================

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop(false);
                },
          child: const Text(
            'Cancel',
          ),
        ),

        AppButton(
          loading: _saving,
          label: widget.editMode
              ? 'Update Plan'
              : 'Save Plan',
          icon: widget.editMode
              ? Icons.save_outlined
              : Icons.add,
          onPressed: _saving
              ? null
              : _submit,
        ),
      ],
    );
  }
}

// ==================================================================
// INFO ROW
// ==================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}