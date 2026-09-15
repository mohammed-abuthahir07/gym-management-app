import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';

class AdminPromotionsPage extends StatefulWidget {
  const AdminPromotionsPage({super.key});

  @override
  State<AdminPromotionsPage> createState() =>
      _AdminPromotionsPageState();
}

class _AdminPromotionsPageState
    extends State<AdminPromotionsPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _promotions = [];

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  // ============================================================
  // GET ALL PROMOTIONS
  // GET /api/admin/promotions
  // ============================================================

  Future<void> _fetchPromotions() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/promotions',
      );

      debugPrint(
        'GET PROMOTIONS RESPONSE: $response',
      );

      List<dynamic> rawList = [];

      if (response is Map) {
        final promotions =
            response['promotions'];

        if (promotions is List) {
          rawList = promotions;
        }
      } else if (response is List) {
        rawList = response;
      }

      final promotions =
          asMapList(rawList);

      if (!mounted) return;

      setState(() {
        _promotions = promotions;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      debugPrint(
        'GET PROMOTIONS API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      debugPrint(
        'GET PROMOTIONS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Failed to load promotions.';
      });
    }
  }

  // ============================================================
  // GET SINGLE PROMOTION
  // GET /api/admin/promotions/:id
  // ============================================================

  Future<Map<String, dynamic>?>
      _getPromotion(
    dynamic id,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/promotions/$id',
      );

      debugPrint(
        'GET SINGLE PROMOTION RESPONSE: '
        '$response',
      );

      if (response is Map) {
        final promotion =
            response['promotion'];

        if (promotion is Map) {
          return Map<String, dynamic>.from(
            promotion,
          );
        }
      }

      return null;
    } on ApiException catch (e) {
      debugPrint(
        'GET SINGLE PROMOTION API ERROR: '
        '${e.message}',
      );

      if (!mounted) return null;

      _showMessage(e.message);

      return null;
    } catch (e) {
      debugPrint(
        'GET SINGLE PROMOTION ERROR: $e',
      );

      if (!mounted) return null;

      _showMessage(
        'Failed to load promotion details.',
      );

      return null;
    }
  }

  // ============================================================
  // CREATE PROMOTION
  // POST /api/admin/promotions
  // ============================================================

  Future<void> _createPromotion() async {
    final result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const _PromotionFormDialog(
          editMode: false,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _fetchPromotions();

      if (!mounted) return;

      _showMessage(
        'Promotion created successfully.',
      );
    }
  }

  // ============================================================
  // VIEW PROMOTION
  // GET /api/admin/promotions/:id
  // ============================================================

  Future<void> _viewPromotion(
    Map<String, dynamic> promotion,
  ) async {
    final id = promotion['id'];

    if (id == null) {
      _showMessage(
        'Promotion ID is missing.',
      );
      return;
    }

    final latest =
        await _getPromotion(id);

    if (!mounted || latest == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return _PromotionDetailsDialog(
          promotion: latest,
        );
      },
    );
  }

  // ============================================================
  // EDIT PROMOTION
  // GET SINGLE -> PUT
  // ============================================================

  Future<void> _editPromotion(
    Map<String, dynamic> promotion,
  ) async {
    final id = promotion['id'];

    if (id == null) {
      _showMessage(
        'Promotion ID is missing.',
      );
      return;
    }

    // Get the latest record before editing.
    final latest =
        await _getPromotion(id);

    if (!mounted || latest == null) {
      return;
    }

    final result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _PromotionFormDialog(
          editMode: true,
          promotion: latest,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      await _fetchPromotions();

      if (!mounted) return;

      _showMessage(
        'Promotion updated successfully.',
      );
    }
  }

  // ============================================================
  // DELETE PROMOTION
  // DELETE /api/admin/promotions/:id
  // ============================================================

  Future<void> _deletePromotion(
    Map<String, dynamic> promotion,
  ) async {
    final id = promotion['id'];

    if (id == null) {
      _showMessage(
        'Promotion ID is missing.',
      );
      return;
    }

    final title = asString(
      promotion['title'],
      'this promotion',
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Promotion',
          ),
          content: Text(
            'Are you sure you want to permanently '
            'delete "$title"?\n\n'
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
                  const Text('Delete'),
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
        '/api/admin/promotions/$id',
      );

      debugPrint(
        'DELETE PROMOTION RESPONSE: '
        '$response',
      );

      if (!mounted) return;

      await _fetchPromotions();

      if (!mounted) return;

      _showMessage(
        'Promotion deleted successfully.',
      );
    } on ApiException catch (e) {
      debugPrint(
        'DELETE PROMOTION API ERROR: '
        '${e.message}',
      );

      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      debugPrint(
        'DELETE PROMOTION ERROR: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Failed to delete promotion.',
      );
    }
  }

  // ============================================================
  // MESSAGE
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
  // PROMOTION CARD
  // ============================================================

  Widget _buildPromotionCard(
    BuildContext context,
    Map<String, dynamic> promotion,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final title = asString(
      promotion['title'],
      'Promotion',
    );

    final code = asString(
      promotion['code'],
    );

    final description = asString(
      promotion['description'],
    );

    final discount =
        asNum(
      promotion['discount'],
    );

    final discountType =
        asString(
      promotion['discount_type'],
      'PERCENTAGE',
    ).toUpperCase();

    final startDate =
        _dateOnly(
      promotion['start_date'],
    );

    final endDate =
        _dateOnly(
      promotion['end_date'],
    );

    final status =
        asString(
      promotion['status'],
      'ACTIVE',
    ).toUpperCase();

    final isActive =
        status == 'ACTIVE';

    final discountText =
        discountType == 'PERCENTAGE'
            ? '${_numberText(discount)}% OFF'
            : '₹${_numberText(discount)} OFF';

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
            // MOBILE / SMALL
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
                              .local_offer_outlined,
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
                              height: 8,
                            ),

                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: [
                                _PromoChip(
                                  text:
                                      discountText,
                                ),
                                _PromoStatusChip(
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

                  if (description
                      .isNotEmpty)
                    Text(
                      description,
                      maxLines: 3,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),

                  if (description
                      .isNotEmpty)
                    const SizedBox(
                      height: 10,
                    ),

                  _PromoInfoLine(
                    label: 'Code',
                    value:
                        code.isEmpty
                            ? '-'
                            : code,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  _PromoInfoLine(
                    label: 'Start',
                    value:
                        startDate.isEmpty
                            ? '-'
                            : startDate,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  _PromoInfoLine(
                    label: 'End',
                    value:
                        endDate.isEmpty
                            ? '-'
                            : endDate,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _viewPromotion(
                            promotion,
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
                          _editPromotion(
                            promotion,
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
                          _deletePromotion(
                            promotion,
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
                        .local_offer_outlined,
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
                            title,
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          _PromoChip(
                            text:
                                discountText,
                          ),
                          _PromoStatusChip(
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

                      if (description
                          .isNotEmpty)
                        Text(
                          description,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),

                      const SizedBox(
                        height: 8,
                      ),

                      Wrap(
                        spacing: 18,
                        runSpacing: 6,
                        children: [
                          _PromoInfoLine(
                            label: 'Code',
                            value:
                                code.isEmpty
                                    ? '-'
                                    : code,
                          ),
                          _PromoInfoLine(
                            label:
                                'Start',
                            value:
                                startDate
                                        .isEmpty
                                    ? '-'
                                    : startDate,
                          ),
                          _PromoInfoLine(
                            label: 'End',
                            value:
                                endDate
                                        .isEmpty
                                    ? '-'
                                    : endDate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'View',
                      onPressed: () {
                        _viewPromotion(
                          promotion,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .visibility_outlined,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () {
                        _editPromotion(
                          promotion,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .edit_outlined,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        _deletePromotion(
                          promotion,
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
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER TEXT
  // ============================================================

  String _numberText(
    num value,
  ) {
    if (value % 1 == 0) {
      return value
          .toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(2);
  }

  // ============================================================
  // DATE ONLY
  // ============================================================

  String _dateOnly(
    dynamic value,
  ) {
    final text =
        asString(value);

    if (text.isEmpty) {
      return '';
    }

    if (text.contains('T')) {
      return text
          .split('T')
          .first;
    }

    if (text.contains(' ')) {
      return text
          .split(' ')
          .first;
    }

    return text;
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

    return RefreshIndicator(
      onRefresh:
          _fetchPromotions,
      child: _buildBody(
        context,
        theme,
        padding,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    double padding,
  ) {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1050,
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
                          'Promotions & Discounts Administration',
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
                          'Manage limited-time membership discount campaigns and coupon codes.',
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
                                _createPromotion,
                            icon:
                                const Icon(
                              Icons.add,
                            ),
                            label:
                                const Text(
                              'Create Promo',
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
                              'Promotions & Discounts Administration',
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
                              'Manage limited-time membership discount campaigns and coupon codes.',
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
                            _createPromotion,
                        icon:
                            const Icon(
                          Icons.add,
                        ),
                        label:
                            const Text(
                          'Create Promo',
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
                  final active =
                      _promotions.where(
                    (item) {
                      return asString(
                            item['status'],
                            'ACTIVE',
                          ).toUpperCase() ==
                          'ACTIVE';
                    },
                  ).length;

                  final inactive =
                      _promotions.length -
                          active;

                  final small =
                      constraints
                              .maxWidth <
                          650;

                  if (small) {
                    return Column(
                      children: [
                        _SummaryCard(
                          title:
                              'Total Promotions',
                          value:
                              '${_promotions.length}',
                          icon: Icons
                              .local_offer_outlined,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _SummaryCard(
                          title:
                              'Active',
                          value:
                              '$active',
                          icon: Icons
                              .check_circle_outline,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _SummaryCard(
                          title:
                              'Inactive',
                          value:
                              '$inactive',
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
                              'Total Promotions',
                          value:
                              '${_promotions.length}',
                          icon: Icons
                              .local_offer_outlined,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child:
                            _SummaryCard(
                          title:
                              'Active',
                          value:
                              '$active',
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
                              'Inactive',
                          value:
                              '$inactive',
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
              // LIST
              // ==================================================

              if (_promotions.isEmpty)
                _buildEmpty()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _promotions.length,
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
                    return _buildPromotionCard(
                      context,
                      _promotions[index],
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
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
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
                    .local_offer_outlined,
                size: 55,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                'No promotional offers created yet.',
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
                height: 18,
              ),

              FilledButton.icon(
                onPressed:
                    _createPromotion,
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  'Create Promotion',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
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
                  'Unable to load promotions',
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
                      _fetchPromotions,
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
}

// ============================================================================
// CREATE / EDIT PROMOTION DIALOG
// ============================================================================

class _PromotionFormDialog
    extends StatefulWidget {
  const _PromotionFormDialog({
    required this.editMode,
    this.promotion,
  });

  final bool editMode;
  final Map<String, dynamic>?
      promotion;

  @override
  State<_PromotionFormDialog> createState() =>
      _PromotionFormDialogState();
}

class _PromotionFormDialogState
    extends State<_PromotionFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _titleController;

  late final TextEditingController
      _codeController;

  late final TextEditingController
      _descriptionController;

  late final TextEditingController
      _discountController;

  late final TextEditingController
      _startDateController;

  late final TextEditingController
      _endDateController;

  String _discountType =
      'PERCENTAGE';

  String _status =
      'ACTIVE';

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final promotion =
        widget.promotion;

    _titleController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              promotion?['title'],
            )
          : '',
    );

    _codeController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              promotion?['code'],
            )
          : '',
    );

    _descriptionController =
        TextEditingController(
      text: widget.editMode
          ? asString(
              promotion?['description'],
            )
          : '',
    );

    _discountController =
        TextEditingController(
      text: widget.editMode
          ? _numberToText(
              promotion?['discount'],
            )
          : '20',
    );

    _startDateController =
        TextEditingController(
      text: widget.editMode
          ? _dateOnly(
              promotion?[
                  'start_date'],
            )
          : _formatDate(
              DateTime.now(),
            ),
    );

    _endDateController =
        TextEditingController(
      text: widget.editMode
          ? _dateOnly(
              promotion?['end_date'],
            )
          : _formatDate(
              DateTime.now().add(
                const Duration(
                  days: 30,
                ),
              ),
            ),
    );

    if (widget.editMode) {
      final type =
          asString(
        promotion?['discount_type'],
        'PERCENTAGE',
      ).toUpperCase();

      if (type == 'FIXED' ||
          type == 'PERCENTAGE') {
        _discountType = type;
      }

      final status =
          asString(
        promotion?['status'],
        'ACTIVE',
      ).toUpperCase();

      if (status == 'ACTIVE' ||
          status == 'INACTIVE') {
        _status = status;
      }
    }
  }

  // ============================================================
  // NUMBER TO TEXT
  // ============================================================

  String _numberToText(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    final number =
        num.tryParse(
      value.toString(),
    );

    if (number == null) {
      return '';
    }

    if (number % 1 == 0) {
      return number
          .toStringAsFixed(0);
    }

    return number
        .toStringAsFixed(2);
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    final year =
        date.year.toString();

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _dateOnly(
    dynamic value,
  ) {
    final text =
        asString(value);

    if (text.isEmpty) {
      return '';
    }

    if (text.contains('T')) {
      return text
          .split('T')
          .first;
    }

    if (text.contains(' ')) {
      return text
          .split(' ')
          .first;
    }

    return text;
  }

  // ============================================================
  // DATE VALIDATION
  // ============================================================

  String? _validateDate(
    String? value,
    String label,
  ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return '$label date is required';
    }

    final regex =
        RegExp(
      r'^\d{4}-\d{2}-\d{2}$',
    );

    if (!regex.hasMatch(text)) {
      return 'Use YYYY-MM-DD format';
    }

    final date =
        DateTime.tryParse(text);

    if (date == null) {
      return 'Invalid $label date';
    }

    // Make sure DateTime didn't normalize
    // an invalid date.
    final normalized =
        _formatDate(date);

    if (normalized != text) {
      return 'Invalid $label date';
    }

    return null;
  }

  // ============================================================
  // FORM SUBMIT
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

    final discount =
        double.tryParse(
      _discountController.text
          .trim(),
    );

    if (discount == null ||
        discount < 0) {
      _showError(
        'Discount must be a valid non-negative number.',
      );
      return;
    }

    if (_discountType ==
            'PERCENTAGE' &&
        discount > 100) {
      _showError(
        'Percentage discount cannot exceed 100.',
      );
      return;
    }

    final start =
        DateTime.tryParse(
      _startDateController.text
          .trim(),
    );

    final end =
        DateTime.tryParse(
      _endDateController.text
          .trim(),
    );

    if (start == null ||
        end == null) {
      _showError(
        'Please enter valid dates.',
      );
      return;
    }

    if (!end.isAfter(start)) {
      _showError(
        'End date must be after start date.',
      );
      return;
    }

    final title =
        _titleController.text.trim();

    final code =
        _codeController.text
            .trim()
            .toUpperCase();

    final description =
        _descriptionController
            .text
            .trim();

    final startDate =
        _startDateController
            .text
            .trim();

    final endDate =
        _endDateController
            .text
            .trim();

    if (!mounted) return;

    setState(() {
      _saving = true;
    });

    try {
      final api =
          context.read<ApiService>();

      // ==========================================================
      // REQUEST BODY
      // ==========================================================

      final body =
          <String, dynamic>{
        'title': title,
        'code': code,
        'description':
            description.isEmpty
                ? ''
                : description,
        'discount': discount,
        'discount_type':
            _discountType,
        'start_date': startDate,
        'end_date': endDate,
      };

      // PUT requires status.
      if (widget.editMode) {
        body['status'] = _status;
      }

      // ==========================================================
      // UPDATE
      // ==========================================================

      if (widget.editMode) {
        final id =
            widget.promotion?['id'];

        if (id == null) {
          throw Exception(
            'Promotion ID is missing.',
          );
        }

        debugPrint(
          'PUT /api/admin/promotions/$id',
        );

        debugPrint(
          'UPDATE PROMOTION BODY: $body',
        );

        final response =
            await api.put(
          '/api/admin/promotions/$id',
          body: body,
        );

        debugPrint(
          'UPDATE PROMOTION RESPONSE: '
          '$response',
        );
      }

      // ==========================================================
      // CREATE
      // ==========================================================

      else {
        debugPrint(
          'POST /api/admin/promotions',
        );

        debugPrint(
          'CREATE PROMOTION BODY: $body',
        );

        final response =
            await api.post(
          '/api/admin/promotions',
          body: body,
        );

        debugPrint(
          'CREATE PROMOTION RESPONSE: '
          '$response',
        );
      }

      if (!mounted) return;

      Navigator.of(context)
          .pop(true);
    } on ApiException catch (e) {
      debugPrint(
        'PROMOTION API ERROR: '
        '${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showError(e.message);
    } catch (e) {
      debugPrint(
        'PROMOTION ERROR: $e',
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
  // ERROR
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
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final screen =
        MediaQuery.sizeOf(
      context,
    );

    final dialogWidth =
        screen.width < 420
            ? screen.width * 0.90
            : screen.width < 700
                ? screen.width * 0.82
                : 520.0;

    final dialogHeight =
        screen.height * 0.70;

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
                    .local_offer_outlined,
            color:
                theme.colorScheme.primary,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              widget.editMode
                  ? 'Edit Promotion'
                  : 'Create Promotion',
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
                // TITLE
                // ==================================================

                TextFormField(
                  controller:
                      _titleController,
                  enabled: !_saving,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Promotion Title *',
                    hintText:
                        'New Year Offer',
                    prefixIcon:
                        Icon(
                      Icons
                          .local_offer_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Title is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // CODE
                // ==================================================

                TextFormField(
                  controller:
                      _codeController,
                  enabled: !_saving,
                  textCapitalization:
                      TextCapitalization
                          .characters,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Promo Code *',
                    hintText:
                        'NY2026',
                    prefixIcon:
                        Icon(
                      Icons
                          .confirmation_number_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Promo code is required';
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
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Description',
                    hintText:
                        '20 percent off all plans',
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
                // DISCOUNT
                // ==================================================

                TextFormField(
                  controller:
                      _discountController,
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
                        'Discount Value *',
                    hintText:
                        '20',
                    prefixIcon:
                        Icon(
                      Icons
                          .percent_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text =
                        value?.trim() ??
                            '';

                    if (text.isEmpty) {
                      return 'Discount is required';
                    }

                    final number =
                        double.tryParse(
                      text,
                    );

                    if (number == null) {
                      return 'Enter a valid discount';
                    }

                    if (number < 0) {
                      return 'Discount cannot be negative';
                    }

                    if (_discountType ==
                            'PERCENTAGE' &&
                        number > 100) {
                      return 'Percentage cannot exceed 100';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // DISCOUNT TYPE
                // ==================================================

                DropdownButtonFormField<
                    String>(
                  initialValue:
                      _discountType,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Discount Type *',
                    prefixIcon:
                        Icon(
                      Icons
                          .price_change_outlined,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                          'PERCENTAGE',
                      child:
                          Text(
                        'Percentage',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'FIXED',
                      child:
                          Text(
                        'Fixed Amount (₹)',
                      ),
                    ),
                  ],
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
                                  _discountType =
                                      value;
                                },
                              );
                            },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // START DATE
                // ==================================================

                TextFormField(
                  controller:
                      _startDateController,
                  enabled: !_saving,
                  keyboardType:
                      TextInputType.datetime,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Start Date *',
                    hintText:
                        '2026-01-01',
                    prefixIcon:
                        Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                  ),
                  validator: (value) {
                    return _validateDate(
                      value,
                      'Start',
                    );
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // END DATE
                // ==================================================

                TextFormField(
                  controller:
                      _endDateController,
                  enabled: !_saving,
                  keyboardType:
                      TextInputType.datetime,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'End Date *',
                    hintText:
                        '2026-01-31',
                    prefixIcon:
                        Icon(
                      Icons
                          .event_outlined,
                    ),
                  ),
                  validator: (value) {
                    return _validateDate(
                      value,
                      'End',
                    );
                  },
                ),

                // ==================================================
                // STATUS - EDIT ONLY
                // ==================================================

                if (widget.editMode) ...[
                  const SizedBox(
                    height: 14,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        _status,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Status *',
                      prefixIcon:
                          Icon(
                        Icons
                            .toggle_on_outlined,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            'ACTIVE',
                        child:
                            Text(
                          'ACTIVE',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'INACTIVE',
                        child:
                            Text(
                          'INACTIVE',
                        ),
                      ),
                    ],
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
                                    _status =
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
                    ? 'Save Changes'
                    : 'Publish Offer',
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PROMOTION DETAILS
// ============================================================================

class _PromotionDetailsDialog
    extends StatelessWidget {
  const _PromotionDetailsDialog({
    required this.promotion,
  });

  final Map<String, dynamic>
      promotion;

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

    final title = asString(
      promotion['title'],
      'Promotion',
    );

    final code = asString(
      promotion['code'],
    );

    final description = asString(
      promotion['description'],
    );

    final discount =
        asNum(
      promotion['discount'],
    );

    final type =
        asString(
      promotion['discount_type'],
      'PERCENTAGE',
    ).toUpperCase();

    final start =
        _dateOnly(
      promotion['start_date'],
    );

    final end =
        _dateOnly(
      promotion['end_date'],
    );

    final status =
        asString(
      promotion['status'],
      'ACTIVE',
    ).toUpperCase();

    final discountText =
        type == 'PERCENTAGE'
            ? '${_numberText(discount)}%'
            : '₹${_numberText(discount)}';

    final active =
        status == 'ACTIVE';

    return AlertDialog(
      insetPadding:
          const EdgeInsets.all(16),

      title: Row(
        children: [
          Icon(
            Icons
                .local_offer_outlined,
            color: theme
                .colorScheme
                .primary,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width:
            screenWidth < 500
                ? screenWidth * 0.84
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
                child:
                    _PromoStatusChip(
                  status: status,
                  active: active,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              _PromoDetailsRow(
                label: 'ID',
                value:
                    '${promotion['id'] ?? '-'}',
              ),

              const SizedBox(
                height: 12,
              ),

              _PromoDetailsRow(
                label: 'Code',
                value:
                    code.isEmpty
                        ? '-'
                        : code,
              ),

              const SizedBox(
                height: 12,
              ),

              _PromoDetailsRow(
                label: 'Discount',
                value:
                    discountText,
              ),

              const SizedBox(
                height: 12,
              ),

              _PromoDetailsRow(
                label: 'Type',
                value:
                    type,
              ),

              const SizedBox(
                height: 12,
              ),

              _PromoDetailsRow(
                label: 'Start',
                value:
                    start.isEmpty
                        ? '-'
                        : start,
              ),

              const SizedBox(
                height: 12,
              ),

              _PromoDetailsRow(
                label: 'End',
                value:
                    end.isEmpty
                        ? '-'
                        : end,
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
                height: 7,
              ),

              Text(
                description.isEmpty
                    ? 'No description provided.'
                    : description,
              ),
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

  static String _dateOnly(
    dynamic value,
  ) {
    final text =
        asString(value);

    if (text.isEmpty) {
      return '';
    }

    if (text.contains('T')) {
      return text
          .split('T')
          .first;
    }

    if (text.contains(' ')) {
      return text
          .split(' ')
          .first;
    }

    return text;
  }

  static String _numberText(
    num value,
  ) {
    if (value % 1 == 0) {
      return value
          .toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(2);
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
                    height: 4,
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
// PROMOTION CHIP
// ============================================================================

class _PromoChip
    extends StatelessWidget {
  const _PromoChip({
    required this.text,
  });

  final String text;

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
        horizontal: 10,
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
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color:
              scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _PromoStatusChip
    extends StatelessWidget {
  const _PromoStatusChip({
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
// INFO LINE
// ============================================================================

class _PromoInfoLine
    extends StatelessWidget {
  const _PromoInfoLine({
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

    return RichText(
      text: TextSpan(
        style: theme
            .textTheme
            .bodySmall,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAILS ROW
// ============================================================================

class _PromoDetailsRow
    extends StatelessWidget {
  const _PromoDetailsRow({
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
          CrossAxisAlignment
              .start,
      children: [
        SizedBox(
          width: 75,
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