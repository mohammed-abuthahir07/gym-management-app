import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';

class AdminPlansPage extends StatefulWidget {
  const AdminPlansPage({super.key});

  @override
  State<AdminPlansPage> createState() => _AdminPlansPageState();
}

class _AdminPlansPageState extends State<AdminPlansPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  // ============================================================
  // GET ALL PLANS
  // GET /api/admin/plans
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

      debugPrint(
        'GET PLANS RESPONSE: $response',
      );

      List<dynamic> rawPlans = [];

      if (response is Map) {
        final plans = response['plans'];

        if (plans is List) {
          rawPlans = plans;
        }
      } else if (response is List) {
        rawPlans = response;
      }

      final plans = asMapList(rawPlans);

      if (!mounted) return;

      setState(() {
        _plans = plans;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      debugPrint(
        'GET PLANS API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      debugPrint(
        'GET PLANS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load membership plans.';
      });
    }
  }

  // ============================================================
  // CREATE PLAN
  // POST /api/admin/plans
  // ============================================================

  Future<void> _createPlan() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
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
  // GET SINGLE PLAN
  // GET /api/admin/plans/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getPlan(
    dynamic planId,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/plans/$planId',
      );

      debugPrint(
        'GET SINGLE PLAN RESPONSE: $response',
      );

      if (response is Map) {
        final plan = response['plan'];

        if (plan is Map) {
          return Map<String, dynamic>.from(
            plan,
          );
        }
      }

      return null;
    } on ApiException catch (e) {
      debugPrint(
        'GET SINGLE PLAN API ERROR: ${e.message}',
      );

      if (!mounted) return null;

      _showMessage(e.message);

      return null;
    } catch (e) {
      debugPrint(
        'GET SINGLE PLAN ERROR: $e',
      );

      if (!mounted) return null;

      _showMessage(
        'Failed to load plan details.',
      );

      return null;
    }
  }

  // ============================================================
  // VIEW PLAN
  // GET /api/admin/plans/:id
  // ============================================================

  Future<void> _viewPlan(
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'];

    if (planId == null) {
      _showMessage(
        'Plan ID is missing.',
      );
      return;
    }

    final latestPlan =
        await _getPlan(planId);

    if (!mounted || latestPlan == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return _PlanDetailsDialog(
          plan: latestPlan,
        );
      },
    );
  }

  // ============================================================
  // EDIT PLAN
  // PUT /api/admin/plans/:id
  // ============================================================

  Future<void> _editPlan(
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'];

    if (planId == null) {
      _showMessage(
        'Plan ID is missing.',
      );
      return;
    }

    // Get latest data from backend.
    final latestPlan =
        await _getPlan(planId);

    if (!mounted || latestPlan == null) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _PlanFormDialog(
          editMode: true,
          plan: latestPlan,
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
  // DELETE PLAN
  // DELETE /api/admin/plans/:id
  // ============================================================

  Future<void> _deletePlan(
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'];

    if (planId == null) {
      _showMessage(
        'Plan ID is missing.',
      );
      return;
    }

    final planName = asString(
      plan['name'],
      'this plan',
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Plan Permanently?',
          ),
          content: Text(
            'Are you sure you want to permanently delete "$planName"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
                  const Text(
                'Delete Permanently',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      final api =
          context.read<ApiService>();

      final response =
          await api.delete(
        '/api/admin/plans/$planId',
      );

      debugPrint(
        'DELETE PLAN RESPONSE: $response',
      );

      if (!mounted) return;

      await _fetchPlans();

      if (!mounted) return;

      _showMessage(
        'Plan deleted permanently.',
      );
    } on ApiException catch (e) {
      debugPrint(
        'DELETE PLAN API ERROR: ${e.message}',
      );

      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      debugPrint(
        'DELETE PLAN ERROR: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Failed to delete plan.',
      );
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message,
  ) {
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
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final name = asString(
      plan['name'],
      'Plan',
    );

    final description = asString(
      plan['description'],
    );

    final durationValue =
        asNum(
      plan['duration_value'],
    );

    final durationUnit =
        asString(
      plan['duration_unit'],
      'MONTH',
    ).toUpperCase();

    final price =
        asNum(
      plan['price'],
    );

    final extraFeatures =
        asString(
      plan['extra_features'],
    );

    final status =
        asString(
      plan['status'],
      'ACTIVE',
    ).toUpperCase();

    final isActive =
        status == 'ACTIVE';

    final durationText =
        '${durationValue.toStringAsFixed(0)} $durationUnit';

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder:
              (
            context,
            constraints,
          ) {
            final isSmall =
                constraints.maxWidth <
                    650;

            // ======================================================
            // SMALL SCREEN
            // ======================================================

            if (isSmall) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            scheme.primary
                                .withValues(
                          alpha: 0.10,
                        ),
                        child: Icon(
                          Icons
                              .card_membership_outlined,
                          color:
                              scheme.primary,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: theme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: [
                                _PlanChip(
                                  label:
                                      durationText,
                                ),
                                _StatusChip(
                                  status:
                                      status,
                                  active:
                                      isActive,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    description.isEmpty
                        ? 'No description provided.'
                        : description,
                    maxLines: 4,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),

                  if (extraFeatures
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      extraFeatures,
                      maxLines: 3,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ],

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _viewPlan(
                            plan,
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .visibility_outlined,
                        ),
                        label:
                            const Text(
                          'View',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _editPlan(
                            plan,
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .edit_outlined,
                        ),
                        label:
                            const Text(
                          'Edit',
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          _deletePlan(
                            plan,
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .delete_outline,
                        ),
                        label:
                            const Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ======================================================
            // DESKTOP
            // ======================================================

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      scheme.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  child: Icon(
                    Icons
                        .card_membership_outlined,
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            name,
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          _PlanChip(
                            label:
                                durationText,
                          ),
                          _StatusChip(
                            status:
                                status,
                            active:
                                isActive,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        description.isEmpty
                            ? 'No description provided.'
                            : description,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),

                      if (extraFeatures
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          extraFeatures,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: theme
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip:
                              'View',
                          onPressed: () {
                            _viewPlan(
                              plan,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .visibility_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Edit',
                          onPressed: () {
                            _editPlan(
                              plan,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .edit_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Delete permanently',
                          onPressed: () {
                            _deletePlan(
                              plan,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .card_membership_outlined,
                size: 55,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                'No membership plans created yet.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Create your first plan to get started.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 18,
              ),

              FilledButton.icon(
                onPressed:
                    _createPlan,
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  'Create Plan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    final theme =
        Theme.of(context);

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.all(30),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 52,
                  color: theme
                      .colorScheme
                      .error,
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  'Unable to load plans',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  _error ??
                      'Something went wrong.',
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 18,
                ),

                FilledButton.icon(
                  onPressed:
                      _fetchPlans,
                  icon:
                      const Icon(
                    Icons.refresh,
                  ),
                  label:
                      const Text(
                    'Retry',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final padding =
        Responsive.pagePadding(
      context,
    );

    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh:
          _fetchPlans,
      child:
          SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.all(
          padding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    final small =
                        constraints
                                .maxWidth <
                            650;

                    if (small) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Membership Plans Administration',
                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Define membership tiers and pricing.',
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                FilledButton.icon(
                              onPressed:
                                  _createPlan,
                              icon:
                                  const Icon(
                                Icons.add,
                              ),
                              label:
                                  const Text(
                                'Create Plan',
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Membership Plans Administration',
                                style: theme
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                'Define membership tiers and pricing.',
                                style: theme
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        FilledButton.icon(
                          onPressed:
                              _createPlan,
                          icon:
                              const Icon(
                            Icons.add,
                          ),
                          label:
                              const Text(
                            'Create Plan',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // ==================================================
                // SUMMARY
                // ==================================================

                LayoutBuilder(
                  builder:
                      (
                    context,
                    constraints,
                  ) {
                    final activeCount =
                        _plans.where(
                      (plan) {
                        return asString(
                              plan['status'],
                              'ACTIVE',
                            ).toUpperCase() ==
                            'ACTIVE';
                      },
                    ).length;

                    final inactiveCount =
                        _plans.length -
                            activeCount;

                    final small =
                        constraints
                                .maxWidth <
                            650;

                    if (small) {
                      return Column(
                        children: [
                          _SummaryCard(
                            title:
                                'Total Plans',
                            value:
                                '${_plans.length}',
                            icon: Icons
                                .card_membership_outlined,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _SummaryCard(
                            title:
                                'Active Plans',
                            value:
                                '$activeCount',
                            icon: Icons
                                .check_circle_outline,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _SummaryCard(
                            title:
                                'Inactive Plans',
                            value:
                                '$inactiveCount',
                            icon: Icons
                                .pause_circle_outline,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child:
                              _SummaryCard(
                            title:
                                'Total Plans',
                            value:
                                '${_plans.length}',
                            icon: Icons
                                .card_membership_outlined,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child:
                              _SummaryCard(
                            title:
                                'Active Plans',
                            value:
                                '$activeCount',
                            icon: Icons
                                .check_circle_outline,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child:
                              _SummaryCard(
                            title:
                                'Inactive Plans',
                            value:
                                '$inactiveCount',
                            icon: Icons
                                .pause_circle_outline,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // PLAN LIST
                // ==================================================

                if (_plans.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _plans.length,
                    separatorBuilder:
                        (_, __) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      return _buildPlanCard(
                        context,
                        _plans[index],
                      );
                    },
                  ),

                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CREATE / EDIT PLAN DIALOG
// ============================================================================

class _PlanFormDialog
    extends StatefulWidget {
  const _PlanFormDialog({
    required this.editMode,
    this.plan,
  });

  final bool editMode;
  final Map<String, dynamic>? plan;

  @override
  State<_PlanFormDialog> createState() =>
      _PlanFormDialogState();
}

class _PlanFormDialogState
    extends State<_PlanFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _descriptionController;

  late final TextEditingController
      _durationController;

  late final TextEditingController
      _priceController;

  late final TextEditingController
      _featuresController;

  static const List<String> _units = [
    'DAY',
    'MONTH',
    'YEAR',
  ];

  static const List<String> _statuses = [
    'ACTIVE',
    'INACTIVE',
  ];

  String _selectedUnit =
      'MONTH';

  String _selectedStatus =
      'ACTIVE';

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final plan = widget.plan;

    _nameController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              plan?['name'],
            )
          : '',
    );

    _descriptionController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              plan?['description'],
            )
          : '',
    );

    _durationController =
        TextEditingController(
      text: widget.editMode
          ? _numberToText(
              plan?[
                  'duration_value'],
              fallback: '1',
            )
          : '3',
    );

    _priceController =
        TextEditingController(
      text: widget.editMode
          ? _numberToText(
              plan?['price'],
              fallback: '0',
              decimals: true,
            )
          : '',
    );

    _featuresController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              plan?[
                  'extra_features'],
            )
          : '',
    );

    if (widget.editMode) {
      final unit =
          asString(
        plan?['duration_unit'],
        'MONTH',
      ).toUpperCase();

      final status =
          asString(
        plan?['status'],
        'ACTIVE',
      ).toUpperCase();

      if (_units.contains(unit)) {
        _selectedUnit = unit;
      }

      if (_statuses.contains(status)) {
        _selectedStatus =
            status;
      }
    }
  }

  // ============================================================
  // NUMBER TEXT
  // ============================================================

  String _numberToText(
    dynamic value, {
    required String fallback,
    bool decimals = false,
  }) {
    if (value == null) {
      return fallback;
    }

    final number =
        num.tryParse(
      value.toString(),
    );

    if (number == null) {
      return fallback;
    }

    if (decimals) {
      return number.toStringAsFixed(2);
    }

    return number.toStringAsFixed(0);
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
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_saving) return;

    final valid =
        _formKey.currentState
                ?.validate() ??
            false;

    if (!valid) {
      return;
    }

    final duration =
        int.tryParse(
      _durationController.text
          .trim(),
    );

    final price =
        double.tryParse(
      _priceController.text
          .trim(),
    );

    if (duration == null ||
        duration <= 0) {
      _showError(
        'Duration must be a positive integer.',
      );
      return;
    }

    if (price == null ||
        price < 0) {
      _showError(
        'Price must be a valid non-negative number.',
      );
      return;
    }

    final name =
        _nameController.text.trim();

    final description =
        _descriptionController.text
            .trim();

    final extraFeatures =
        _featuresController.text
            .trim();

    if (!mounted) return;

    setState(() {
      _saving = true;
    });

    try {
      final api =
          context.read<ApiService>();

      final body =
          <String, dynamic>{
        'name': name,
        'description':
            description.isEmpty
                ? null
                : description,
        'duration_value':
            duration,
        'duration_unit':
            _selectedUnit,
        'price': price,
        'extra_features':
            extraFeatures.isEmpty
                ? null
                : extraFeatures,
      };

      // ==========================================================
      // UPDATE
      // ==========================================================

      if (widget.editMode) {
        final planId =
            widget.plan?['id'];

        if (planId == null) {
          throw Exception(
            'Plan ID is missing.',
          );
        }

        body['status'] =
            _selectedStatus;

        debugPrint(
          'PUT /api/admin/plans/$planId',
        );

        debugPrint(
          'UPDATE PLAN BODY: $body',
        );

        final response =
            await api.put(
          '/api/admin/plans/$planId',
          body: body,
        );

        debugPrint(
          'UPDATE PLAN RESPONSE: $response',
        );
      }

      // ==========================================================
      // CREATE
      // ==========================================================

      else {
        debugPrint(
          'POST /api/admin/plans',
        );

        debugPrint(
          'CREATE PLAN BODY: $body',
        );

        final response =
            await api.post(
          '/api/admin/plans',
          body: body,
        );

        debugPrint(
          'CREATE PLAN RESPONSE: $response',
        );
      }

      if (!mounted) return;

      // Return true to parent.
      Navigator.of(context)
          .pop(true);
    } on ApiException catch (e) {
      debugPrint(
        'PLAN API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(e.message);
    } catch (e) {
      debugPrint(
        'PLAN ERROR: $e',
      );

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
  // ERROR MESSAGE
  // ============================================================

  void _showError(
    String message,
  ) {
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
  // BUILD FORM
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final screenWidth =
        MediaQuery.sizeOf(
      context,
    ).width;

    final screenHeight =
        MediaQuery.sizeOf(
      context,
    ).height;

    final dialogWidth =
        screenWidth < 420
            ? screenWidth * 0.92
            : screenWidth < 700
                ? screenWidth * 0.86
                : 500.0;

    final dialogHeight =
        screenHeight * 0.72;

    return AlertDialog(
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),

      titlePadding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),

      contentPadding:
          const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        8,
      ),

      actionsPadding:
          const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),

      title: Row(
        children: [
          Icon(
            widget.editMode
                ? Icons.edit_outlined
                : Icons
                    .card_membership_outlined,
            color:
                theme.colorScheme.primary,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              widget.editMode
                  ? 'Edit Membership Plan'
                  : 'Create Membership Plan',
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                // ==================================================
                // NAME
                // ==================================================

                TextFormField(
                  controller:
                      _nameController,
                  enabled: !_saving,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Plan Name *',
                    hintText:
                        'e.g. Gold Plan',
                    prefixIcon:
                        Icon(
                      Icons
                          .card_membership_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Plan name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                TextFormField(
                  controller:
                      _descriptionController,
                  enabled: !_saving,
                  maxLines: 3,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                    hintText:
                        'Describe this membership plan',
                    prefixIcon:
                        Icon(
                      Icons
                          .description_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // DURATION
                // ==================================================

                TextFormField(
                  controller:
                      _durationController,
                  enabled: !_saving,
                  keyboardType:
                      TextInputType.number,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Duration *',
                    hintText: '3',
                    prefixIcon:
                        Icon(
                      Icons
                          .schedule_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Duration is required';
                    }

                    final number =
                        int.tryParse(
                      text,
                    );

                    if (number == null ||
                        number <= 0) {
                      return 'Enter a positive integer';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // UNIT
                // ==================================================

                DropdownButtonFormField<
                    String>(
                  initialValue:
                      _selectedUnit,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Duration Unit *',
                    prefixIcon:
                        Icon(
                      Icons
                          .timelapse_outlined,
                    ),
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
                  onChanged:
                      _saving
                          ? null
                          : (value) {
                              if (value ==
                                  null) {
                                return;
                              }

                              setState(
                                () {
                                  _selectedUnit =
                                      value;
                                },
                              );
                            },
                ),

                const SizedBox(
                  height: 14,
                ),

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
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Price (₹) *',
                    hintText:
                        '4999.00',
                    prefixIcon:
                        Icon(
                      Icons
                          .currency_rupee,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Price is required';
                    }

                    final number =
                        double.tryParse(
                      text,
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

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // EXTRA FEATURES
                // ==================================================

                TextFormField(
                  controller:
                      _featuresController,
                  enabled: !_saving,
                  maxLines: 4,
                  textInputAction:
                      TextInputAction.done,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Extra Features',
                    hintText:
                        'e.g. Locker access, sauna included',
                    prefixIcon:
                        Icon(
                      Icons
                          .star_border_outlined,
                    ),
                  ),
                ),

                // ==================================================
                // STATUS
                // ==================================================

                if (widget.editMode) ...[
                  const SizedBox(
                    height: 14,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        _selectedStatus,
                    isExpanded: true,
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
                    onChanged:
                        _saving
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setState(
                                  () {
                                    _selectedStatus =
                                        value;
                                  },
                                );
                              },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // ============================================================
      // ACTIONS
      // ============================================================

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop(false);
                },
          child:
              const Text('Cancel'),
        ),

        FilledButton.icon(
          onPressed:
              _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  widget.editMode
                      ? Icons
                          .save_outlined
                      : Icons.add,
                ),
          label: Text(
            _saving
                ? 'Saving...'
                : widget.editMode
                    ? 'Update Plan'
                    : 'Create Plan',
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PLAN DETAILS DIALOG
// ============================================================================

class _PlanDetailsDialog
    extends StatelessWidget {
  const _PlanDetailsDialog({
    required this.plan,
  });

  final Map<String, dynamic> plan;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final name = asString(
      plan['name'],
      'Plan',
    );

    final description =
        asString(
      plan['description'],
    );

    final duration =
        asNum(
      plan['duration_value'],
    );

    final unit =
        asString(
      plan['duration_unit'],
      'MONTH',
    ).toUpperCase();

    final price =
        asNum(
      plan['price'],
    );

    final features =
        asString(
      plan['extra_features'],
    );

    final status =
        asString(
      plan['status'],
      'ACTIVE',
    ).toUpperCase();

    final active =
        status == 'ACTIVE';

    final createdAt =
        asString(
      plan['created_at'],
    );

    final updatedAt =
        asString(
      plan['updated_at'],
    );

    final width =
        MediaQuery.sizeOf(
      context,
    ).width;

    return AlertDialog(
      insetPadding:
          const EdgeInsets.all(16),

      title: Row(
        children: [
          Icon(
            Icons
                .card_membership_outlined,
            color: theme
                .colorScheme
                .primary,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width:
            width < 500
                ? width * 0.86
                : 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Center(
                child: _StatusChip(
                  status: status,
                  active: active,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              _DetailsRow(
                label: 'Plan ID',
                value:
                    '${plan['id'] ?? '-'}',
              ),

              const SizedBox(
                height: 12,
              ),

              _DetailsRow(
                label: 'Duration',
                value:
                    '${duration.toStringAsFixed(0)} $unit',
              ),

              const SizedBox(
                height: 12,
              ),

              _DetailsRow(
                label: 'Price',
                value:
                    '₹${price.toStringAsFixed(2)}',
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                'Description',
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                description.isEmpty
                    ? 'No description provided.'
                    : description,
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                'Extra Features',
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                features.isEmpty
                    ? 'No extra features provided.'
                    : features,
              ),

              if (createdAt.isNotEmpty) ...[
                const SizedBox(
                  height: 20,
                ),
                _DetailsRow(
                  label: 'Created',
                  value:
                      _formatDate(
                    createdAt,
                  ),
                ),
              ],

              if (updatedAt.isNotEmpty) ...[
                const SizedBox(
                  height: 12,
                ),
                _DetailsRow(
                  label: 'Updated',
                  value:
                      _formatDate(
                    updatedAt,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
          child:
              const Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(
    String value,
  ) {
    try {
      final date =
          DateTime.parse(value);

      final day =
          date.day
              .toString()
              .padLeft(2, '0');

      final month =
          date.month
              .toString()
              .padLeft(2, '0');

      final year =
          date.year.toString();

      return '$day-$month-$year';
    } catch (_) {
      if (value.contains('T')) {
        return value
            .split('T')
            .first;
      }

      return value;
    }
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard
    extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Card(
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
                icon,
                color:
                    scheme.primary,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: theme
                        .textTheme
                        .bodyMedium,
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    value,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PLAN CHIP
// ============================================================================

class _PlanChip
    extends StatelessWidget {
  const _PlanChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: scheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              scheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _StatusChip
    extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.active,
  });

  final String status;
  final bool active;

  @override
  Widget build(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    final background =
        active
            ? scheme.primary
                .withValues(
                alpha: 0.12,
              )
            : scheme.error
                .withValues(
                alpha: 0.12,
              );

    final foreground =
        active
            ? scheme.primary
            : scheme.error;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// DETAILS ROW
// ============================================================================

class _DetailsRow
    extends StatelessWidget {
  const _DetailsRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Text(
            value,
          ),
        ),
      ],
    );
  }
}