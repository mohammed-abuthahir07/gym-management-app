import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminTrainersPage extends StatefulWidget {
  const AdminTrainersPage({super.key});

  @override
  State<AdminTrainersPage> createState() => _AdminTrainersPageState();
}

class _AdminTrainersPageState extends State<AdminTrainersPage> {
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
  // GET /api/admin/trainers
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

      if (!mounted) return;

      setState(() {
        _trainers = asMapList(trainersList);
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
        _error = 'Failed to load trainer staff directory.';
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
  // POST /api/admin/trainers
  // ============================================================

  Future<void> _openCreateTrainerDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    bool trainerCreated = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;
          bool obscurePassword = true;

          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Theme.of(dialogContext)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add Trainer',
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            enabled: !saving,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText: 'Trainer Name *',
                              hintText:
                                  'Enter trainer name',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                            validator: (value) {
                              return Validators.requiredField(
                                value,
                                label: 'Name',
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: emailController,
                            enabled: !saving,
                            keyboardType:
                                TextInputType.emailAddress,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Email Address *',
                              hintText:
                                  'trainer@example.com',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                              ),
                            ),
                            validator:
                                Validators.email,
                          ),

                          const SizedBox(height: 14),

                          TextFormField(
                            controller: phoneController,
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
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

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
                                  'Account Password *',
                              hintText:
                                  'Enter trainer password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon:
                                  IconButton(
                                tooltip:
                                    obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                onPressed: saving
                                    ? null
                                    : () {
                                        setDialogState(
                                          () {
                                            obscurePassword =
                                                !obscurePassword;
                                          },
                                        );
                                      },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator:
                                Validators.password,
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
                    child: const Text(
                      'Cancel',
                    ),
                  ),

                  AppButton(
                    label: 'Create Account',
                    icon: Icons.person_add_outlined,
                    loading: saving,
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final api =
                                  context.read<ApiService>();

                              final response =
                                  await api.post(
                                '/api/admin/trainers',
                                body: {
                                  'name':
                                      nameController.text
                                          .trim(),
                                  'email':
                                      emailController.text
                                          .trim(),
                                  'phone':
                                      phoneController.text
                                          .trim(),
                                  'password':
                                      passwordController
                                          .text,
                                },
                              );

                              debugPrint(
                                'CREATE TRAINER RESPONSE: $response',
                              );

                              trainerCreated = true;

                              if (dialogContext.mounted) {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              }
                            } on ApiException catch (e) {
                              debugPrint(
                                'CREATE TRAINER API ERROR: ${e.message}',
                              );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message,
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint(
                                'CREATE TRAINER ERROR: $e',
                              );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to create trainer account.',
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                ],
              );
            },
          );
        },
      );

      if (trainerCreated && mounted) {
        await _fetchTrainers();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trainer account created successfully.',
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
  // GET /api/admin/trainers/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getTrainer(
    num id,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/trainers/$id',
      );

      debugPrint(
        'GET TRAINER RESPONSE: $response',
      );

      if (response is Map &&
          response['trainer'] is Map) {
        return Map<String, dynamic>.from(
          response['trainer'] as Map,
        );
      }

      return null;
    } on ApiException catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
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
  // GET /api/admin/trainers/:id
  // ============================================================

  Future<void> _viewTrainer(num id) async {
    final trainer = await _getTrainer(id);

    if (!mounted || trainer == null) {
      return;
    }

    final scheme = Theme.of(context).colorScheme;

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
    );

    final createdAt = asString(
      trainer['created_at'],
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Trainer Details',
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      scheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 34,
                    color: scheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 6),

                StatusBadge(
                  label: status.toUpperCase(),
                  positive:
                      status.toUpperCase() ==
                          'ACTIVE',
                ),

                const SizedBox(height: 22),

                _TrainerDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email.isEmpty
                      ? 'Not provided'
                      : email,
                ),

                const SizedBox(height: 12),

                _TrainerDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: phone.isEmpty
                      ? 'Not provided'
                      : phone,
                ),

                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _TrainerDetailRow(
                    icon:
                        Icons.calendar_today_outlined,
                    label: 'Created',
                    value: createdAt
                        .split('T')
                        .first,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EDIT TRAINER
  // PUT /api/admin/trainers/:id
  // ============================================================

  Future<void> _openEditTrainerDialog(
    num id,
  ) async {
    final trainer = await _getTrainer(id);

    if (!mounted || trainer == null) {
      return;
    }

    final nameController = TextEditingController(
      text: asString(trainer['name']),
    );

    final emailController = TextEditingController(
      text: asString(trainer['email']),
    );

    final phoneController = TextEditingController(
      text: asString(trainer['phone']),
    );

    final passwordController =
        TextEditingController();

    final formKey = GlobalKey<FormState>();

    String selectedStatus = asString(
      trainer['status'],
      'ACTIVE',
    ).toUpperCase();

    bool trainerUpdated = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;
          bool obscurePassword = true;

          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Theme.of(dialogContext)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Edit Trainer',
                      ),
                    ),
                  ],
                ),

                content: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ==================================================
                          // NAME
                          // ==================================================

                          TextFormField(
                            controller: nameController,
                            enabled: !saving,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Trainer Name *',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                            validator: (value) {
                              return Validators.requiredField(
                                value,
                                label: 'Name',
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // EMAIL
                          // ==================================================

                          TextFormField(
                            controller: emailController,
                            enabled: !saving,
                            keyboardType:
                                TextInputType.emailAddress,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Email Address *',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                              ),
                            ),
                            validator:
                                Validators.email,
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // PHONE
                          // ==================================================

                          TextFormField(
                            controller: phoneController,
                            enabled: !saving,
                            keyboardType:
                                TextInputType.phone,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Phone Number',
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

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
                                TextInputAction.next,
                            decoration:
                                InputDecoration(
                              labelText:
                                  'New Password',
                              hintText:
                                  'Leave empty to keep current password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                              ),
                              suffixIcon:
                                  IconButton(
                                tooltip:
                                    obscurePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                onPressed: saving
                                    ? null
                                    : () {
                                        setDialogState(
                                          () {
                                            obscurePassword =
                                                !obscurePassword;
                                          },
                                        );
                                      },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final text =
                                  value?.trim() ?? '';

                              if (text.isEmpty) {
                                return null;
                              }

                              return Validators.password(
                                value,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // STATUS
                          // ==================================================

                          DropdownButtonFormField<String>(
                            initialValue:
                                selectedStatus,
                            decoration:
                                const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(
                                Icons
                                    .toggle_on_outlined,
                              ),
                              border:
                                  OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'ACTIVE',
                                child: Text(
                                  'ACTIVE',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'INACTIVE',
                                child: Text(
                                  'INACTIVE',
                                ),
                              ),
                            ],
                            onChanged: saving
                                ? null
                                : (value) {
                                    if (value ==
                                        null) {
                                      return;
                                    }

                                    setDialogState(() {
                                      selectedStatus =
                                          value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                actions: [
                  // ========================================================
                  // CANCEL
                  // ========================================================

                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            Navigator.of(
                              dialogContext,
                            ).pop();
                          },
                    child: const Text(
                      'Cancel',
                    ),
                  ),

                  // ========================================================
                  // SAVE
                  // ========================================================

                  AppButton(
                    label: 'Save Changes',
                    icon: Icons.save_outlined,
                    loading: saving,
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!
                                .validate()) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final api =
                                  context.read<ApiService>();

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
                                'status':
                                    selectedStatus,
                              };

                              // Only send password when
                              // admin entered a new one.
                              if (passwordController
                                  .text
                                  .trim()
                                  .isNotEmpty) {
                                body['password'] =
                                    passwordController
                                        .text;
                              }

                              final response =
                                  await api.put(
                                '/api/admin/trainers/$id',
                                body: body,
                              );

                              debugPrint(
                                'UPDATE TRAINER RESPONSE: $response',
                              );

                              trainerUpdated = true;

                              if (dialogContext.mounted) {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              }
                            } on ApiException catch (e) {
                              debugPrint(
                                'UPDATE TRAINER API ERROR: ${e.message}',
                              );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message,
                                  ),
                                ),
                              );
                            } catch (e) {
                              debugPrint(
                                'UPDATE TRAINER ERROR: $e',
                              );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to update trainer.',
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                ],
              );
            },
          );
        },
      );

      // ============================================================
      // REFRESH ONLY AFTER DIALOG CLOSED
      // ============================================================

      if (trainerUpdated && mounted) {
        await _fetchTrainers();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trainer updated successfully.',
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
  // CHANGE STATUS
  // PUT /api/admin/trainers/:id
  // ============================================================

  Future<void> _changeTrainerStatus(
    num id,
    String currentStatus,
  ) async {
    final newStatus =
        currentStatus.toUpperCase() == 'ACTIVE'
            ? 'INACTIVE'
            : 'ACTIVE';

    final isActivating = newStatus == 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text(
            isActivating
                ? 'Activate Trainer'
                : 'Deactivate Trainer',
          ),
          content: Text(
            isActivating
                ? 'Are you sure you want to activate this trainer account?'
                : 'Are you sure you want to deactivate this trainer account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isActivating
                    ? scheme.primary
                    : scheme.error,
                foregroundColor: isActivating
                    ? scheme.onPrimary
                    : scheme.onError,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                isActivating
                    ? 'Activate'
                    : 'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final api = context.read<ApiService>();

      final response = await api.put(
        '/api/admin/trainers/$id',
        body: {
          'status': newStatus,
        },
      );

      debugPrint(
        'CHANGE TRAINER STATUS RESPONSE: $response',
      );

      if (!mounted) return;

      await _fetchTrainers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActivating
                ? 'Trainer activated successfully.'
                : 'Trainer deactivated successfully.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      debugPrint(
        'CHANGE TRAINER STATUS ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to change trainer status.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE / DEACTIVATE
  // DELETE /api/admin/trainers/:id
  // ============================================================

  Future<void> _deleteTrainer(num id) async {
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deactivate Trainer',
          ),
          content: const Text(
            'Are you sure you want to deactivate this trainer account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
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

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final api = context.read<ApiService>();

      await api.delete(
        '/api/admin/trainers/$id',
      );

      if (!mounted) return;

      await _fetchTrainers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trainer deactivated successfully.',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      debugPrint(
        'DELETE TRAINER ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to deactivate trainer.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TRAINER CARD
  // ============================================================

  Widget _buildTrainerCard(
    BuildContext context,
    Map<String, dynamic> trainer,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
    );

    final isActive =
        status.toUpperCase() == 'ACTIVE';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      scheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      StatusBadge(
                        label:
                            status.toUpperCase(),
                        positive: isActive,
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Trainer actions',
                  onSelected: (value) {
                    if (value == 'view') {
                      _viewTrainer(id);
                    }

                    if (value == 'edit') {
                      _openEditTrainerDialog(id);
                    }

                    if (value == 'status') {
                      _changeTrainerStatus(
                        id,
                        status,
                      );
                    }

                    if (value == 'delete') {
                      _deleteTrainer(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading: Icon(
                            Icons
                                .visibility_outlined,
                          ),
                          title: Text(
                            'View Details',
                          ),
                        ),
                      ),

                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading: Icon(
                            Icons.edit_outlined,
                          ),
                          title: Text(
                            'Edit Trainer',
                          ),
                        ),
                      ),

                      PopupMenuItem<String>(
                        value: 'status',
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading: Icon(
                            isActive
                                ? Icons
                                    .person_off_outlined
                                : Icons
                                    .person_add_outlined,
                          ),
                          title: Text(
                            isActive
                                ? 'Deactivate'
                                : 'Activate',
                          ),
                        ),
                      ),

                      if (isActive)
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            leading: Icon(
                              Icons
                                  .delete_outline,
                            ),
                            title: Text(
                              'Deactivate',
                            ),
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // EMAIL
            // ==========================================================

            _TrainerInfoRow(
              icon: Icons.email_outlined,
              text: email.isEmpty
                  ? 'No email registered'
                  : email,
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // PHONE
            // ==========================================================

            _TrainerInfoRow(
              icon: Icons.phone_outlined,
              text: phone.isEmpty
                  ? 'No phone registered'
                  : phone,
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // ACTION BUTTONS
            // ==========================================================

            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _viewTrainer(id);
                    },
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'View',
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: () {
                      _openEditTrainerDialog(id);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Edit',
                    ),
                  ),

                  OutlinedButton.icon(
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor: isActive
                          ? scheme.error
                          : scheme.primary,
                      side: BorderSide(
                        color: isActive
                            ? scheme.error
                            : scheme.primary,
                      ),
                    ),
                    onPressed: () {
                      _changeTrainerStatus(
                        id,
                        status,
                      );
                    },
                    icon: Icon(
                      isActive
                          ? Icons
                              .person_off_outlined
                          : Icons
                              .person_add_outlined,
                      size: 18,
                    ),
                    label: Text(
                      isActive
                          ? 'Deactivate'
                          : 'Activate',
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final padding =
        Responsive.pagePadding(context);

    final activeCount = _trainers.where(
      (trainer) =>
          asString(
            trainer['status'],
            'ACTIVE',
          ).toUpperCase() ==
          'ACTIVE',
    ).length;

    final inactiveCount = _trainers.length -
        activeCount;

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchTrainers,
      isEmpty: _trainers.isEmpty,
      emptyMessage:
          'No trainers registered yet. Add staff members using the button above.',
      child: RefreshIndicator(
        onRefresh: _fetchTrainers,
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
                  // ======================================================
                  // PAGE HEADER
                  // ======================================================

                  LayoutBuilder(
                    builder:
                        (context, constraints) {
                      final isSmall =
                          constraints.maxWidth <
                              650;

                      if (isSmall) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coaching Staff Administration',
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
                              'Manage certified trainers, credentials, and coaching staff.',
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label:
                                    'Add Trainer',
                                icon: Icons
                                    .person_add_outlined,
                                onPressed:
                                    _openCreateTrainerDialog,
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
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Coaching Staff Administration',
                                  style: theme
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Manage certified trainers, credentials, and coaching staff.',
                                  style: theme
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          AppButton(
                            label: 'Add Trainer',
                            icon: Icons
                                .person_add_outlined,
                            onPressed:
                                _openCreateTrainerDialog,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // STAT CARDS
                  // ======================================================

                  LayoutBuilder(
                    builder:
                        (context, constraints) {
                      final isSmall =
                          constraints.maxWidth <
                              650;

                      if (isSmall) {
                        return Column(
                          children: [
                            _buildCountCard(
                              context,
                              title:
                                  'Total Trainers',
                              count:
                                  _trainers.length,
                              icon:
                                  Icons.groups_outlined,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            _buildCountCard(
                              context,
                              title:
                                  'Active Trainers',
                              count:
                                  activeCount,
                              icon:
                                  Icons
                                      .person_outline,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            _buildCountCard(
                              context,
                              title:
                                  'Inactive Trainers',
                              count:
                                  inactiveCount,
                              icon:
                                  Icons
                                      .person_off_outlined,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _buildCountCard(
                              context,
                              title:
                                  'Total Trainers',
                              count:
                                  _trainers.length,
                              icon:
                                  Icons
                                      .groups_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _buildCountCard(
                              context,
                              title:
                                  'Active Trainers',
                              count:
                                  activeCount,
                              icon:
                                  Icons
                                      .person_outline,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _buildCountCard(
                              context,
                              title:
                                  'Inactive Trainers',
                              count:
                                  inactiveCount,
                              icon:
                                  Icons
                                      .person_off_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ======================================================
                  // TRAINER LIST
                  // ======================================================

                  if (_trainers.isEmpty)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          30,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons
                                    .fitness_center_outlined,
                                size: 48,
                                color: scheme
                                    .onSurfaceVariant,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                'No trainers registered yet.',
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
                                height: 6,
                              ),

                              Text(
                                'Use the Add Trainer button to create the first trainer account.',
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
                    )
                  else
                    LayoutBuilder(
                      builder:
                          (context, constraints) {
                        if (constraints.maxWidth >=
                            850) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  520,
                              crossAxisSpacing:
                                  16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 270,
                            ),
                            itemCount:
                                _trainers.length,
                            itemBuilder:
                                (context, index) {
                              return _buildTrainerCard(
                                context,
                                _trainers[index],
                              );
                            },
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              _trainers.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 12,
                          ),
                          itemBuilder:
                              (context, index) {
                            return _buildTrainerCard(
                              context,
                              _trainers[index],
                            );
                          },
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

  // ============================================================
  // COUNT CARD
  // ============================================================

  Widget _buildCountCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  scheme.primary.withValues(
                alpha: 0.12,
              ),
              child: Icon(
                icon,
                color: scheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 3),
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

            if (title == 'Total Trainers')
              IconButton(
                tooltip: 'Refresh',
                onPressed: _fetchTrainers,
                icon: const Icon(
                  Icons.refresh,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TRAINER INFO ROW
// ============================================================================

class _TrainerInfoRow extends StatelessWidget {
  const _TrainerInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: scheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TRAINER DETAIL ROW
// ============================================================================

class _TrainerDetailRow extends StatelessWidget {
  const _TrainerDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: scheme.primary,
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 70,
          child: Text(
            label,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:
                theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}