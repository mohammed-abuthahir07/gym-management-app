import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';

class AdminTrainersPage extends StatefulWidget {
  const AdminTrainersPage({super.key});

  @override
  State<AdminTrainersPage> createState() =>
      _AdminTrainersPageState();
}

class _AdminTrainersPageState
    extends State<AdminTrainersPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  // ============================================================
  // GET ALL TRAINERS
  //
  // GET /api/admin/trainers
  // Auth: ADMIN JWT
  // ============================================================

  Future<void> _fetchTrainers() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/trainers',
      );

      debugPrint(
        'GET TRAINERS RESPONSE: $response',
      );

      List<dynamic> trainersList = [];

      if (response is Map) {
        final trainers = response['trainers'];

        if (trainers is List) {
          trainersList = trainers;
        }
      } else if (response is List) {
        trainersList = response;
      }

      final parsedTrainers =
          asMapList(trainersList);

      if (!mounted) return;

      setState(() {
        _trainers = parsedTrainers;
        _error = null;
      });
    } on ApiException catch (e) {
      debugPrint(
        'GET TRAINERS API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      debugPrint(
        'GET TRAINERS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _error =
            'Failed to load trainers.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // CREATE TRAINER
  //
  // POST /api/admin/trainers
  //
  // Body:
  // {
  //   "name": "...",
  //   "email": "...",
  //   "phone": "...",
  //   "password": "..."
  // }
  // ============================================================

  Future<void> _openCreateTrainerDialog() async {
    final nameController =
        TextEditingController();

    final emailController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final passwordController =
        TextEditingController();

    final formKey =
        GlobalKey<FormState>();

    bool created = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;
          bool obscurePassword = true;

          return StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {
              return AlertDialog(
                title: const Text(
                  'Add Trainer',
                ),

                content: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child:
                        SingleChildScrollView(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          // ==================================================
                          // NAME
                          // ==================================================

                          TextFormField(
                            controller:
                                nameController,
                            enabled: !saving,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Trainer Name *',
                              hintText:
                                  'Enter trainer name',
                              prefixIcon:
                                  Icon(
                                Icons
                                    .person_outline,
                              ),
                            ),
                            validator:
                                (value) {
                              final text =
                                  value?.trim() ??
                                      '';

                              if (text.isEmpty) {
                                return 'Name is required';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // EMAIL
                          // ==================================================

                          TextFormField(
                            controller:
                                emailController,
                            enabled: !saving,
                            keyboardType:
                                TextInputType
                                    .emailAddress,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Email Address *',
                              hintText:
                                  'trainer@example.com',
                              prefixIcon:
                                  Icon(
                                Icons
                                    .email_outlined,
                              ),
                            ),
                            validator:
                                (value) {
                              final email =
                                  value?.trim() ??
                                      '';

                              if (email.isEmpty) {
                                return 'Email is required';
                              }

                              final emailRegex =
                                  RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              );

                              if (!emailRegex
                                  .hasMatch(
                                      email)) {
                                return 'Enter a valid email';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // PHONE
                          // ==================================================

                          TextFormField(
                            controller:
                                phoneController,
                            enabled: !saving,
                            keyboardType:
                                TextInputType.phone,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Phone Number',
                              hintText:
                                  'Enter phone number',
                              prefixIcon:
                                  Icon(
                                Icons
                                    .phone_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // PASSWORD
                          // ==================================================

                          TextFormField(
                            controller:
                                passwordController,
                            enabled: !saving,
                            obscureText:
                                obscurePassword,
                            textInputAction:
                                TextInputAction.done,
                            decoration:
                                InputDecoration(
                              labelText:
                                  'Password *',
                              hintText:
                                  'Enter trainer password',
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .lock_outline,
                              ),
                              suffixIcon:
                                  IconButton(
                                tooltip:
                                    obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                onPressed:
                                    saving
                                        ? null
                                        : () {
                                            setDialogState(
                                              () {
                                                obscurePassword =
                                                    !obscurePassword;
                                              },
                                            );
                                          },
                                icon:
                                    Icon(
                                  obscurePassword
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              final password =
                                  value ?? '';

                              if (password
                                  .trim()
                                  .isEmpty) {
                                return 'Password is required';
                              }

                              if (password.length <
                                  6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            Navigator.of(
                              dialogContext,
                            ).pop();
                          },
                    child:
                        const Text('Cancel'),
                  ),

                  FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey
                                .currentState!
                                .validate()) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final api =
                                  context.read<
                                      ApiService>();

                              final body =
                                  <String, dynamic>{
                                'name':
                                    nameController
                                        .text
                                        .trim(),
                                'email':
                                    emailController
                                        .text
                                        .trim(),
                                'phone':
                                    phoneController
                                        .text
                                        .trim(),
                                'password':
                                    passwordController
                                        .text,
                              };

                              final response =
                                  await api.post(
                                '/api/admin/trainers',
                                body: body,
                              );

                              debugPrint(
                                'CREATE TRAINER RESPONSE: $response',
                              );

                              created = true;

                              if (dialogContext
                                  .mounted) {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              }
                            } on ApiException catch (e) {
                              debugPrint(
                                'CREATE TRAINER API ERROR: ${e.message}',
                              );

                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(
                                    e.message,
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint(
                                'CREATE TRAINER ERROR: $e',
                              );

                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to create trainer.',
                                  ),
                                ),
                              );
                            }
                          },
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .person_add_outlined,
                          ),
                    label: Text(
                      saving
                          ? 'Creating...'
                          : 'Create Trainer',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      // ==========================================================
      // REFRESH AFTER DIALOG CLOSED
      // ==========================================================

      if (created && mounted) {
        await _fetchTrainers();

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Trainer created successfully.',
            ),
          ),
        );
      }
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
    }
  }

  // ============================================================
  // GET SINGLE TRAINER
  //
  // GET /api/admin/trainers/:id
  // ============================================================

  Future<Map<String, dynamic>?>
      _getTrainer(num id) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/trainers/$id',
      );

      debugPrint(
        'GET TRAINER RESPONSE: $response',
      );

      if (response is Map) {
        final trainer =
            response['trainer'];

        if (trainer is Map) {
          return Map<String, dynamic>.from(
            trainer,
          );
        }
      }

      return null;
    } on ApiException catch (e) {
      debugPrint(
        'GET TRAINER API ERROR: ${e.message}',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );

      return null;
    } catch (e) {
      debugPrint(
        'GET TRAINER ERROR: $e',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load trainer details.',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // VIEW TRAINER
  //
  // GET /api/admin/trainers/:id
  // ============================================================

  Future<void> _viewTrainer(num id) async {
    final trainer =
        await _getTrainer(id);

    if (!mounted || trainer == null) {
      return;
    }

    final name = asString(
      trainer['name'],
      'Trainer',
    );

    final email = asString(
      trainer['email'],
    );

    final phone = asString(
      trainer['phone'],
    );

    final status = asString(
      trainer['status'],
      'ACTIVE',
    ).toUpperCase();

    final createdAt = asString(
      trainer['created_at'],
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme =
            Theme.of(dialogContext);

        final scheme =
            theme.colorScheme;

        return AlertDialog(
          title: const Text(
            'Trainer Details',
          ),

          content: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 500,
              maxHeight: 500,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                        scheme.primary
                            .withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(
                      Icons
                          .fitness_center,
                      size: 34,
                      color:
                          scheme.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    name,
                    textAlign:
                        TextAlign.center,
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _StatusChip(
                    status: status,
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _DetailRow(
                    icon:
                        Icons.email_outlined,
                    label: 'Email',
                    value:
                        email.isEmpty
                            ? 'Not provided'
                            : email,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _DetailRow(
                    icon:
                        Icons.phone_outlined,
                    label: 'Phone',
                    value:
                        phone.isEmpty
                            ? 'Not provided'
                            : phone,
                  ),

                  if (createdAt
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 14,
                    ),
                    _DetailRow(
                      icon: Icons
                          .calendar_today_outlined,
                      label: 'Created',
                      value: _formatDate(
                        createdAt,
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
                  dialogContext,
                ).pop();
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DELETE / DEACTIVATE TRAINER
  //
  // DELETE /api/admin/trainers/:id
  //
  // IMPORTANT:
  // Backend does NOT permanently delete.
  // It changes status to INACTIVE.
  // ============================================================

  Future<void> _deleteTrainer(
    num id,
    String trainerName,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme =
            Theme.of(dialogContext)
                .colorScheme;

        return AlertDialog(
          title: const Text(
            'Deactivate Trainer',
          ),

          content: Text(
            'Are you sure you want to deactivate "$trainerName"?',
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
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    scheme.error,
                foregroundColor:
                    scheme.onError,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Deactivate',
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
        '/api/admin/trainers/$id',
      );

      debugPrint(
        'DELETE TRAINER RESPONSE: $response',
      );

      if (!mounted) return;

      await _fetchTrainers();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Trainer deactivated successfully.',
          ),
        ),
      );
    } on ApiException catch (e) {
      debugPrint(
        'DELETE TRAINER API ERROR: ${e.message}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      debugPrint(
        'DELETE TRAINER ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to deactivate trainer.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Not available';
    }

    try {
      final date =
          DateTime.parse(value);

      final day =
          date.day.toString().padLeft(
                2,
                '0',
              );

      final month =
          date.month.toString().padLeft(
                2,
                '0',
              );

      return '$day-$month-${date.year}';
    } catch (_) {
      if (value.contains('T')) {
        return value.split('T').first;
      }

      return value;
    }
  }

  // ============================================================
  // TRAINER CARD
  // ============================================================

  Widget _buildTrainerCard(
    BuildContext context,
    Map<String, dynamic> trainer,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final id = asNum(
      trainer['id'],
    );

    final name = asString(
      trainer['name'],
      'Trainer',
    );

    final email = asString(
      trainer['email'],
    );

    final phone = asString(
      trainer['phone'],
    );

    final status = asString(
      trainer['status'],
      'ACTIVE',
    ).toUpperCase();

    final isActive =
        status == 'ACTIVE';

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ========================================================
            // HEADER
            // ========================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      scheme.primary
                          .withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons
                        .fitness_center,
                    color:
                        scheme.primary,
                    size: 28,
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

                      _StatusChip(
                        status: status,
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<
                    String>(
                  tooltip:
                      'Trainer actions',
                  onSelected:
                      (value) {
                    if (value ==
                        'view') {
                      _viewTrainer(id);
                    }

                    if (value ==
                        'deactivate') {
                      _deleteTrainer(
                        id,
                        name,
                      );
                    }
                  },
                  itemBuilder:
                      (context) {
                    return [
                      const PopupMenuItem<
                          String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .visibility_outlined,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'View Details',
                            ),
                          ],
                        ),
                      ),

                      if (isActive)
                        const PopupMenuItem<
                            String>(
                          value:
                              'deactivate',
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .person_off_outlined,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Deactivate',
                              ),
                            ],
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            const Divider(
              height: 1,
            ),

            const SizedBox(
              height: 14,
            ),

            // ========================================================
            // EMAIL
            // ========================================================

            _InfoRow(
              icon:
                  Icons.email_outlined,
              text: email.isEmpty
                  ? 'No email registered'
                  : email,
            ),

            const SizedBox(
              height: 10,
            ),

            // ========================================================
            // PHONE
            // ========================================================

            _InfoRow(
              icon:
                  Icons.phone_outlined,
              text: phone.isEmpty
                  ? 'No phone registered'
                  : phone,
            ),

            const SizedBox(
              height: 16,
            ),

            // ========================================================
            // VIEW / DEACTIVATE
            // ========================================================

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _viewTrainer(id);
                  },
                  icon: const Icon(
                    Icons
                        .visibility_outlined,
                    size: 18,
                  ),
                  label:
                      const Text('View'),
                ),

                if (isActive)
                  OutlinedButton.icon(
                    style: OutlinedButton
                        .styleFrom(
                      foregroundColor:
                          scheme.error,
                      side: BorderSide(
                        color:
                            scheme.error,
                      ),
                    ),
                    onPressed: () {
                      _deleteTrainer(
                        id,
                        name,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .person_off_outlined,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Deactivate',
                    ),
                  ),
              ],
            ),
          ],
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

    final scheme =
        theme.colorScheme;

    final padding =
        Responsive.pagePadding(
      context,
    );

    final activeCount =
        _trainers.where(
      (trainer) {
        return asString(
              trainer['status'],
              'ACTIVE',
            ).toUpperCase() ==
            'ACTIVE';
      },
    ).length;

    final inactiveCount =
        _trainers.length -
            activeCount;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTrainers,
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _error != null
                ? _buildErrorState()
                : SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        EdgeInsets.all(
                      padding,
                    ),
                    child: Center(
                      child:
                          ConstrainedBox(
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
                                    constraints.maxWidth <
                                        650;

                                if (small) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        'Trainers',
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
                                        'Manage your gym trainers and coaching staff.',
                                        style: theme
                                            .textTheme
                                            .bodyMedium,
                                      ),

                                      const SizedBox(
                                        height: 16,
                                      ),

                                      SizedBox(
                                        width: double
                                            .infinity,
                                        child:
                                            FilledButton
                                                .icon(
                                          onPressed:
                                              _openCreateTrainerDialog,
                                          icon:
                                              const Icon(
                                            Icons
                                                .person_add_outlined,
                                          ),
                                          label:
                                              const Text(
                                            'Add Trainer',
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
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            'Trainers',
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
                                            'Manage your gym trainers and coaching staff.',
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

                                    FilledButton
                                        .icon(
                                      onPressed:
                                          _openCreateTrainerDialog,
                                      icon:
                                          const Icon(
                                        Icons
                                            .person_add_outlined,
                                      ),
                                      label:
                                          const Text(
                                        'Add Trainer',
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
                            // STATISTICS
                            // ==================================================

                            LayoutBuilder(
                              builder:
                                  (
                                context,
                                constraints,
                              ) {
                                final small =
                                    constraints.maxWidth <
                                        650;

                                if (small) {
                                  return Column(
                                    children: [
                                      _buildCountCard(
                                        context,
                                        'Total Trainers',
                                        _trainers
                                            .length,
                                        Icons
                                            .groups_outlined,
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildCountCard(
                                        context,
                                        'Active Trainers',
                                        activeCount,
                                        Icons
                                            .person_outline,
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildCountCard(
                                        context,
                                        'Inactive Trainers',
                                        inactiveCount,
                                        Icons
                                            .person_off_outlined,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child:
                                          _buildCountCard(
                                        context,
                                        'Total Trainers',
                                        _trainers
                                            .length,
                                        Icons
                                            .groups_outlined,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child:
                                          _buildCountCard(
                                        context,
                                        'Active Trainers',
                                        activeCount,
                                        Icons
                                            .person_outline,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child:
                                          _buildCountCard(
                                        context,
                                        'Inactive Trainers',
                                        inactiveCount,
                                        Icons
                                            .person_off_outlined,
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
                            // EMPTY
                            // ==================================================

                            if (_trainers
                                .isEmpty)
                              _buildEmptyState()
                            else
                              LayoutBuilder(
                                builder:
                                    (
                                  context,
                                  constraints,
                                ) {
                                  if (constraints
                                          .maxWidth >=
                                      850) {
                                    return GridView
                                        .builder(
                                      shrinkWrap:
                                          true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent:
                                            520,
                                        crossAxisSpacing:
                                            16,
                                        mainAxisSpacing:
                                            16,
                                        mainAxisExtent:
                                            260,
                                      ),
                                      itemCount:
                                          _trainers
                                              .length,
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        return _buildTrainerCard(
                                          context,
                                          _trainers[
                                              index],
                                        );
                                      },
                                    );
                                  }

                                  return ListView
                                      .separated(
                                    shrinkWrap:
                                        true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _trainers
                                            .length,
                                    separatorBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      return const SizedBox(
                                        height: 12,
                                      );
                                    },
                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      return _buildTrainerCard(
                                        context,
                                        _trainers[
                                            index],
                                      );
                                    },
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
      ),
    );
  }

  // ============================================================
  // COUNT CARD
  // ============================================================

  Widget _buildCountCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Card(
      color:
          scheme.surfaceContainerHighest,
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  scheme.primary
                      .withValues(
                alpha: 0.12,
              ),
              child: Icon(
                icon,
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
                    title,
                    style: theme
                        .textTheme
                        .bodyMedium,
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    '$count',
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

            if (title ==
                'Total Trainers')
              IconButton(
                tooltip:
                    'Refresh',
                onPressed:
                    _fetchTrainers,
                icon: const Icon(
                  Icons.refresh,
                ),
              ),
          ],
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

    final scheme =
        theme.colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons
                    .fitness_center_outlined,
                size: 52,
                color:
                    scheme.onSurfaceVariant,
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                'No trainers registered yet.',
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
                height: 6,
              ),

              Text(
                'Click "Add Trainer" to create the first trainer account.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(
                height: 18,
              ),

              FilledButton.icon(
                onPressed:
                    _openCreateTrainerDialog,
                icon: const Icon(
                  Icons
                      .person_add_outlined,
                ),
                label:
                    const Text(
                  'Add Trainer',
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

    final scheme =
        theme.colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 500,
          ),
          child: Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(28),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .error_outline,
                    size: 52,
                    color:
                        scheme.error,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    'Unable to load trainers',
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
                        _fetchTrainers,
                    icon: const Icon(
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
  });

  final String status;

  @override
  Widget build(
    BuildContext context,
  ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    final active =
        status.toUpperCase() ==
            'ACTIVE';

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
// INFO ROW
// ============================================================================

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color:
              scheme.onSurfaceVariant,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color:
              scheme.primary,
        ),

        const SizedBox(
          width: 12,
        ),

        SizedBox(
          width: 65,
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

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Text(
            value,
            maxLines: 4,
            overflow:
                TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}