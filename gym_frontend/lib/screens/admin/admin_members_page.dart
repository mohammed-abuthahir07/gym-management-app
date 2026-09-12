import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({super.key});

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // LOAD MEMBERS + TRAINERS
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final api = context.read<ApiService>();

      final memberResponse = await api.get(
        '/api/admin/members',
      );

      debugPrint(
        'GET MEMBERS RESPONSE: $memberResponse',
      );

      final trainerResponse = await api.get(
        '/api/admin/trainers',
      );

      debugPrint(
        'GET TRAINERS RESPONSE: $trainerResponse',
      );

      List<dynamic> membersList = [];
      List<dynamic> trainersList = [];

      if (memberResponse is Map &&
          memberResponse['members'] is List) {
        membersList =
            memberResponse['members'] as List;
      } else if (memberResponse is List) {
        membersList = memberResponse;
      }

      if (trainerResponse is Map &&
          trainerResponse['trainers'] is List) {
        trainersList =
            trainerResponse['trainers'] as List;
      } else if (trainerResponse is List) {
        trainersList = trainerResponse;
      }

      if (!mounted) return;

      setState(() {
        _members = asMapList(membersList);
        _trainers = asMapList(trainersList);
      });
    } on ApiException catch (e) {
      debugPrint(
        'LOAD MEMBERS API ERROR: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      debugPrint(
        'LOAD MEMBERS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _error =
            'Failed to load member directory.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // GET SINGLE MEMBER
  // GET /api/admin/members/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getMember(
    num memberId,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/members/$memberId',
      );

      debugPrint(
        'GET MEMBER RESPONSE: $response',
      );

      if (response is Map &&
          response['member'] is Map) {
        return Map<String, dynamic>.from(
          response['member'] as Map,
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
        'GET MEMBER ERROR: $e',
      );

      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load member details.',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // VIEW MEMBER
  // GET /api/admin/members/:id
  // ============================================================

  Future<void> _viewMember(num memberId) async {
    final member = await _getMember(memberId);

    if (!mounted || member == null) {
      return;
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final name = asString(
      member['name'],
      'Member',
    );

    final email = asString(
      member['email'],
    );

    final phone = asString(
      member['phone'],
    );

    final goal = asString(
      member['fitness_goal'],
    );

    final status = asString(
      member['status'],
      'ACTIVE',
    ).toUpperCase();

    final trainerName = asString(
      member['trainer_name'],
    );

    final trainerEmail = asString(
      member['trainer_email'],
    );

    final createdAt = asString(
      member['created_at'],
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Member Details',
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ======================================================
                  // AVATAR
                  // ======================================================

                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        scheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 38,
                      color: scheme.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  StatusBadge(
                    label: status,
                    positive: status == 'ACTIVE',
                  ),

                  const SizedBox(height: 22),

                  // ======================================================
                  // MEMBER INFORMATION
                  // ======================================================

                  _MemberDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email.isEmpty
                        ? 'Not provided'
                        : email,
                  ),

                  const SizedBox(height: 12),

                  _MemberDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: phone.isEmpty
                        ? 'Not provided'
                        : phone,
                  ),

                  if (goal.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MemberDetailRow(
                      icon:
                          Icons.track_changes_outlined,
                      label: 'Goal',
                      value: goal,
                    ),
                  ],

                  const SizedBox(height: 12),

                  _MemberDetailRow(
                    icon:
                        Icons.fitness_center_outlined,
                    label: 'Trainer',
                    value: trainerName.isEmpty
                        ? 'No trainer assigned'
                        : trainerEmail.isEmpty
                            ? trainerName
                            : '$trainerName\n$trainerEmail',
                  ),

                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MemberDetailRow(
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
  // ASSIGN TRAINER
  // PUT /api/admin/members/:id/trainer
  // ============================================================

  Future<void> _openAssignTrainerDialog(
    num memberId,
    String memberName,
  ) async {
    // ------------------------------------------------------------
    // Only ACTIVE trainers can be assigned.
    // Backend rejects inactive trainers.
    // ------------------------------------------------------------

    final activeTrainers = _trainers.where(
      (trainer) {
        final status = asString(
          trainer['status'],
          'ACTIVE',
        ).toUpperCase();

        return status == 'ACTIVE';
      },
    ).toList();

    if (activeTrainers.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active trainers available. Please activate or add a trainer first.',
          ),
        ),
      );

      return;
    }

    num? selectedTrainerId =
        asNum(activeTrainers.first['id']);

    bool assigned = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons
                          .assignment_ind_outlined,
                      color: Theme.of(dialogContext)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Assign Trainer',
                      ),
                    ),
                  ],
                ),

                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member',
                        style: Theme.of(dialogContext)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        memberName,
                        style: Theme.of(dialogContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                      ),

                      const SizedBox(height: 18),

                      DropdownButtonFormField<num>(
                        initialValue:
                            selectedTrainerId,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Select Trainer *',
                          prefixIcon: Icon(
                            Icons
                                .fitness_center_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                        items: activeTrainers
                            .map(
                              (trainer) {
                                final trainerId =
                                    asNum(
                                  trainer['id'],
                                );

                                final trainerName =
                                    asString(
                                  trainer['name'],
                                  'Trainer',
                                );

                                return DropdownMenuItem<
                                    num>(
                                  value:
                                      trainerId,
                                  child: Text(
                                    trainerName,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                );
                              },
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedTrainerId =
                                      value;
                                });
                              },
                      ),
                    ],
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
                    label: 'Assign Trainer',
                    icon: Icons
                        .assignment_ind_outlined,
                    loading: saving,
                    onPressed: saving
                        ? null
                        : () async {
                            if (selectedTrainerId ==
                                null) {
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final api =
                                  context
                                      .read<ApiService>();

                              final response =
                                  await api.put(
                                '/api/admin/members/$memberId/trainer',
                                body: {
                                  'trainer_id':
                                      selectedTrainerId,
                                },
                              );

                              debugPrint(
                                'ASSIGN TRAINER RESPONSE: $response',
                              );

                              assigned = true;

                              // IMPORTANT:
                              // Close first.
                              // Never call dialog setState
                              // after pop().
                              if (dialogContext
                                  .mounted) {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              }
                            } on ApiException catch (e) {
                              debugPrint(
                                'ASSIGN TRAINER API ERROR: ${e.message}',
                              );

                              if (!dialogContext
                                  .mounted) {
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
                                'ASSIGN TRAINER ERROR: $e',
                              );

                              if (!dialogContext
                                  .mounted) {
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
                                    'Failed to assign trainer.',
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

      // ------------------------------------------------------------
      // Refresh only after dialog has closed.
      // ------------------------------------------------------------

      if (assigned && mounted) {
        await _loadData();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trainer assigned successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'ASSIGN TRAINER DIALOG ERROR: $e',
      );
    }
  }

  // ============================================================
  // REMOVE TRAINER
  // DELETE /api/admin/members/:id/trainer
  // ============================================================

  Future<void> _removeTrainer(
    num memberId,
    String memberName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: const Text(
            'Unassign Trainer',
          ),
          content: Text(
            'Are you sure you want to remove the trainer assignment from $memberName?',
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
                'Unassign',
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

      final response = await api.delete(
        '/api/admin/members/$memberId/trainer',
      );

      debugPrint(
        'REMOVE TRAINER RESPONSE: $response',
      );

      if (!mounted) return;

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trainer removed successfully.',
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
        'REMOVE TRAINER ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to remove trainer.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DEACTIVATE MEMBER
  // DELETE /api/admin/members/:id
  // ============================================================

  Future<void> _deleteMember(
    num memberId,
    String memberName,
  ) async {
    final scheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deactivate Member',
          ),
          content: Text(
            'Are you sure you want to deactivate $memberName?',
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

      final response = await api.delete(
        '/api/admin/members/$memberId',
      );

      debugPrint(
        'DELETE MEMBER RESPONSE: $response',
      );

      if (!mounted) return;

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Member deactivated successfully.',
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
        'DELETE MEMBER ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to deactivate member.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ACTIVATE MEMBER
  //
  // IMPORTANT:
  // Your current backend API list does NOT provide an explicit
  // member activation endpoint.
  //
  // Therefore we DO NOT call PUT here.
  // The UI only supports the backend operations you provided.
  // ============================================================

  // ============================================================
  // MEMBER CARD
  // ============================================================

  Widget _buildMemberCard(
    BuildContext context,
    Map<String, dynamic> member,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final id = asNum(
      member['id'],
    );

    final name = asString(
      member['name'],
      'Member',
    );

    final email = asString(
      member['email'],
    );

    final phone = asString(
      member['phone'],
    );

    final goal = asString(
      member['fitness_goal'],
    );

    final trainerName = asString(
      member['trainer_name'],
    );

    final status = asString(
      member['status'],
      'ACTIVE',
    ).toUpperCase();

    final isActive = status == 'ACTIVE';

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
                  radius: 29,
                  backgroundColor:
                      scheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: scheme.primary,
                    size: 29,
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
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 6),

                      StatusBadge(
                        label: status,
                        positive: isActive,
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  tooltip: 'Member actions',
                  onSelected: (value) {
                    if (value == 'view') {
                      _viewMember(id);
                    }

                    if (value == 'assign') {
                      _openAssignTrainerDialog(
                        id,
                        name,
                      );
                    }

                    if (value == 'remove') {
                      _removeTrainer(
                        id,
                        name,
                      );
                    }

                    if (value == 'deactivate') {
                      _deleteMember(
                        id,
                        name,
                      );
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

                      if (isActive &&
                          trainerName.isEmpty)
                        const PopupMenuItem<String>(
                          value: 'assign',
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            leading: Icon(
                              Icons
                                  .assignment_ind_outlined,
                            ),
                            title: Text(
                              'Assign Trainer',
                            ),
                          ),
                        ),

                      if (isActive &&
                          trainerName.isNotEmpty)
                        const PopupMenuItem<String>(
                          value: 'remove',
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            leading: Icon(
                              Icons
                                  .person_remove_outlined,
                            ),
                            title: Text(
                              'Unassign Trainer',
                            ),
                          ),
                        ),

                      if (isActive)
                        const PopupMenuItem<String>(
                          value: 'deactivate',
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            leading: Icon(
                              Icons
                                  .person_off_outlined,
                            ),
                            title: Text(
                              'Deactivate Member',
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

            _MemberInfoRow(
              icon: Icons.email_outlined,
              text: email.isEmpty
                  ? 'No email registered'
                  : email,
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // PHONE
            // ==========================================================

            _MemberInfoRow(
              icon: Icons.phone_outlined,
              text: phone.isEmpty
                  ? 'No phone registered'
                  : phone,
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // TRAINER
            // ==========================================================

            _MemberInfoRow(
              icon:
                  Icons.fitness_center_outlined,
              text: trainerName.isNotEmpty
                  ? 'Assigned Trainer: $trainerName'
                  : 'No trainer assigned',
              highlighted:
                  trainerName.isNotEmpty,
            ),

            if (goal.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MemberInfoRow(
                icon:
                    Icons.track_changes_outlined,
                text: 'Goal: $goal',
              ),
            ],

            const SizedBox(height: 16),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _viewMember(id);
                    },
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'View',
                    ),
                  ),

                  if (isActive &&
                      trainerName.isEmpty)
                    FilledButton.tonalIcon(
                      onPressed: () {
                        _openAssignTrainerDialog(
                          id,
                          name,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .assignment_ind_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Assign Trainer',
                      ),
                    ),

                  if (isActive &&
                      trainerName.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        _removeTrainer(
                          id,
                          name,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .person_remove_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Unassign',
                      ),
                    ),

                  if (isActive)
                    OutlinedButton.icon(
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            scheme.error,
                        side: BorderSide(
                          color: scheme.error,
                        ),
                      ),
                      onPressed: () {
                        _deleteMember(
                          id,
                          name,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .person_off_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'Deactivate',
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

    final activeMembers = _members.where(
      (member) {
        return asString(
              member['status'],
              'ACTIVE',
            ).toUpperCase() ==
            'ACTIVE';
      },
    ).length;

    final inactiveMembers =
        _members.length - activeMembers;

    final assignedMembers = _members.where(
      (member) {
        final trainerId =
            member['trainer_id'];

        return trainerId != null;
      },
    ).length;

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _loadData,
      isEmpty: _members.isEmpty,
      emptyMessage:
          'No members registered yet in the system.',
      child: RefreshIndicator(
        onRefresh: _loadData,
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
                              'Member Administration',
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
                              'Manage memberships, assign trainers, and view member goals.',
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment:
                                  Alignment.centerRight,
                              child: IconButton(
                                tooltip: 'Refresh',
                                onPressed:
                                    _loadData,
                                icon: const Icon(
                                  Icons.refresh,
                                ),
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
                                  'Member Administration',
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
                                  'Manage memberships, assign trainers, and view member goals.',
                                  style: theme
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          IconButton(
                            tooltip: 'Refresh',
                            onPressed: _loadData,
                            icon: const Icon(
                              Icons.refresh,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // MEMBER STATISTICS
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
                            _buildStatCard(
                              context,
                              title:
                                  'Total Members',
                              value:
                                  _members.length,
                              icon:
                                  Icons.groups_outlined,
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _buildStatCard(
                              context,
                              title:
                                  'Active Members',
                              value:
                                  activeMembers,
                              icon:
                                  Icons
                                      .person_outline,
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _buildStatCard(
                              context,
                              title:
                                  'Inactive Members',
                              value:
                                  inactiveMembers,
                              icon:
                                  Icons
                                      .person_off_outlined,
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _buildStatCard(
                              context,
                              title:
                                  'Assigned Trainers',
                              value:
                                  assignedMembers,
                              icon:
                                  Icons
                                      .fitness_center_outlined,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title:
                                  'Total Members',
                              value:
                                  _members.length,
                              icon:
                                  Icons
                                      .groups_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _buildStatCard(
                              context,
                              title:
                                  'Active Members',
                              value:
                                  activeMembers,
                              icon:
                                  Icons
                                      .person_outline,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _buildStatCard(
                              context,
                              title:
                                  'Inactive Members',
                              value:
                                  inactiveMembers,
                              icon:
                                  Icons
                                      .person_off_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: _buildStatCard(
                              context,
                              title:
                                  'Assigned Trainers',
                              value:
                                  assignedMembers,
                              icon:
                                  Icons
                                      .fitness_center_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ======================================================
                  // MEMBER LIST
                  // ======================================================

                  if (_members.isEmpty)
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
                                    .person_off_outlined,
                                size: 48,
                                color: scheme
                                    .onSurfaceVariant,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                'No members registered yet.',
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
                                'Members will appear here after they register.',
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
                        // ------------------------------------------------
                        // DESKTOP / TABLET
                        // ------------------------------------------------

                        if (constraints.maxWidth >=
                            850) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  540,
                              crossAxisSpacing:
                                  16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 300,
                            ),
                            itemCount:
                                _members.length,
                            itemBuilder:
                                (context, index) {
                              return _buildMemberCard(
                                context,
                                _members[index],
                              );
                            },
                          );
                        }

                        // ------------------------------------------------
                        // MOBILE / NARROW TABLET
                        // ------------------------------------------------

                        return ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              _members.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 12,
                          ),
                          itemBuilder:
                              (context, index) {
                            return _buildMemberCard(
                              context,
                              _members[index],
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
  // STAT CARD
  // ============================================================

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
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
                    '$value',
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
// MEMBER INFO ROW
// ============================================================================

class _MemberInfoRow extends StatelessWidget {
  const _MemberInfoRow({
    required this.icon,
    required this.text,
    this.highlighted = false,
  });

  final IconData icon;
  final String text;
  final bool highlighted;

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
          size: 19,
          color: highlighted
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              fontWeight: highlighted
                  ? FontWeight.w600
                  : null,
              color: highlighted
                  ? scheme.primary
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MEMBER DETAIL ROW
// ============================================================================

class _MemberDetailRow extends StatelessWidget {
  const _MemberDetailRow({
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
          width: 72,
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
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style:
                theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}