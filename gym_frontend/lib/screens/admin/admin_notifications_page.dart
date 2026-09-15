import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState
    extends State<AdminNotificationsPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // =========================================================
  // LOAD ALL DATA
  // =========================================================

  Future<void> _loadAll() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      // -------------------------------------------------------
      // LOAD NOTIFICATIONS
      // -------------------------------------------------------

      final notificationResponse =
          await api.get('/api/admin/notifications');

      List<dynamic> notificationList = [];

      if (notificationResponse is Map) {
        if (notificationResponse['notifications'] is List) {
          notificationList =
              notificationResponse['notifications'] as List;
        } else if (notificationResponse['data'] is List) {
          notificationList =
              notificationResponse['data'] as List;
        }
      } else if (notificationResponse is List) {
        notificationList = notificationResponse;
      }

      // -------------------------------------------------------
      // LOAD MEMBERS
      // -------------------------------------------------------

      List<Map<String, dynamic>> members = [];

      try {
        final memberResponse =
            await api.get('/api/admin/members');

        if (memberResponse is Map) {
          if (memberResponse['members'] is List) {
            members = asMapList(memberResponse['members']);
          } else if (memberResponse['data'] is List) {
            members = asMapList(memberResponse['data']);
          }
        } else if (memberResponse is List) {
          members = asMapList(memberResponse);
        }
      } catch (_) {
        // Do not fail notification page if member API fails.
        members = [];
      }

      // -------------------------------------------------------
      // LOAD TRAINERS
      // -------------------------------------------------------

      List<Map<String, dynamic>> trainers = [];

      try {
        final trainerResponse =
            await api.get('/api/admin/trainers');

        if (trainerResponse is Map) {
          if (trainerResponse['trainers'] is List) {
            trainers = asMapList(trainerResponse['trainers']);
          } else if (trainerResponse['data'] is List) {
            trainers = asMapList(trainerResponse['data']);
          }
        } else if (trainerResponse is List) {
          trainers = asMapList(trainerResponse);
        }
      } catch (_) {
        // Do not fail notification page if trainer API fails.
        trainers = [];
      }

      if (!mounted) return;

      setState(() {
        _notifications = asMapList(notificationList);
        _members = members;
        _trainers = trainers;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load notifications.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // =========================================================
  // OPEN CREATE / EDIT DIALOG
  // =========================================================

  Future<void> _openNotificationDialog([
    Map<String, dynamic>? item,
  ]) async {
    final bool isEditing = item != null;

    // -------------------------------------------------------
    // CONTROLLERS
    // -------------------------------------------------------

    final titleController = TextEditingController(
      text: isEditing
          ? asString(item['title'])
          : 'Gym Announcement',
    );

    final messageController = TextEditingController(
      text: isEditing
          ? asString(item['message'])
          : '',
    );

    final formKey = GlobalKey<FormState>();

    // -------------------------------------------------------
    // TARGET
    // -------------------------------------------------------

    String targetType = 'ALL_MEMBERS';

    num? selectedMemberId;
    num? selectedTrainerId;

    if (_members.isNotEmpty) {
      selectedMemberId = asNum(_members.first['id']);
    }

    if (_trainers.isNotEmpty) {
      selectedTrainerId = asNum(_trainers.first['id']);
    }

    bool? saved;

    try {
      saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;

          return StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {
              return AlertDialog(
                title: Text(
                  isEditing
                      ? 'Edit Notification'
                      : 'Send Notification',
                ),

                content: SizedBox(
                  width: 500,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // TARGET AUDIENCE
                          // =================================================

                          if (!isEditing) ...[
                            DropdownButtonFormField<String>(
                              value: targetType,
                              isExpanded: true,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Target Audience *',
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ALL_MEMBERS',
                                  child: Text(
                                    'All Members',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'ALL_TRAINERS',
                                  child: Text(
                                    'All Trainers',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'SPECIFIC_MEMBER',
                                  child: Text(
                                    'Specific Member',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'SPECIFIC_TRAINER',
                                  child: Text(
                                    'Specific Trainer',
                                  ),
                                ),
                              ],
                              onChanged: saving
                                  ? null
                                  : (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setDialogState(() {
                                        targetType = value;

                                        if (targetType ==
                                                'SPECIFIC_MEMBER' &&
                                            _members
                                                .isNotEmpty) {
                                          selectedMemberId =
                                              asNum(
                                            _members.first['id'],
                                          );
                                        }

                                        if (targetType ==
                                                'SPECIFIC_TRAINER' &&
                                            _trainers
                                                .isNotEmpty) {
                                          selectedTrainerId =
                                              asNum(
                                            _trainers.first['id'],
                                          );
                                        }
                                      });
                                    },
                            ),

                            const SizedBox(height: 14),

                            // =================================================
                            // SPECIFIC MEMBER
                            // =================================================

                            if (targetType ==
                                'SPECIFIC_MEMBER') ...[
                              if (_members.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                  child: const Text(
                                    'No members available.',
                                  ),
                                )
                              else
                                DropdownButtonFormField<num>(
                                  value: selectedMemberId,
                                  isExpanded: true,
                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        'Select Member *',
                                    isDense: true,
                                  ),
                                  items: _members.map((member) {
                                    final id =
                                        asNum(member['id']);

                                    final name = asString(
                                      member['name'],
                                      'Member',
                                    );

                                    final email = asString(
                                      member['email'],
                                    );

                                    return DropdownMenuItem<num>(
                                      value: id,
                                      child: Text(
                                        email.isEmpty
                                            ? name
                                            : '$name ($email)',
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: saving
                                      ? null
                                      : (value) {
                                          setDialogState(() {
                                            selectedMemberId =
                                                value;
                                          });
                                        },
                                ),

                              const SizedBox(height: 14),
                            ],

                            // =================================================
                            // SPECIFIC TRAINER
                            // =================================================

                            if (targetType ==
                                'SPECIFIC_TRAINER') ...[
                              if (_trainers.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                  child: const Text(
                                    'No trainers available.',
                                  ),
                                )
                              else
                                DropdownButtonFormField<num>(
                                  value: selectedTrainerId,
                                  isExpanded: true,
                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        'Select Trainer *',
                                    isDense: true,
                                  ),
                                  items: _trainers.map((trainer) {
                                    final id =
                                        asNum(trainer['id']);

                                    final name = asString(
                                      trainer['name'],
                                      'Trainer',
                                    );

                                    final email = asString(
                                      trainer['email'],
                                    );

                                    return DropdownMenuItem<num>(
                                      value: id,
                                      child: Text(
                                        email.isEmpty
                                            ? name
                                            : '$name ($email)',
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: saving
                                      ? null
                                      : (value) {
                                          setDialogState(() {
                                            selectedTrainerId =
                                                value;
                                          });
                                        },
                                ),

                              const SizedBox(height: 14),
                            ],
                          ],

                          // =================================================
                          // TITLE
                          // =================================================

                          TextFormField(
                            controller: titleController,
                            enabled: !saving,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Notification Title *',
                              hintText:
                                  'Enter notification title',
                              isDense: true,
                            ),
                            validator: (value) =>
                                Validators.requiredField(
                              value,
                              label: 'Title',
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =================================================
                          // MESSAGE
                          // =================================================

                          TextFormField(
                            controller: messageController,
                            enabled: !saving,
                            maxLines: 5,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Notification Message *',
                              hintText:
                                  'Enter notification message',
                              isDense: true,
                              alignLabelWithHint: true,
                            ),
                            validator: (value) =>
                                Validators.requiredField(
                              value,
                              label: 'Message',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================================================
                // ACTIONS
                // =========================================================

                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            Navigator.of(
                              dialogContext,
                            ).pop(false);
                          },
                    child: const Text('Cancel'),
                  ),

                  AppButton(
                    loading: saving,
                    label: isEditing
                        ? 'Save Changes'
                        : 'Send Notification',
                    icon: isEditing
                        ? Icons.save_outlined
                        : Icons.send_outlined,
                    onPressed: () async {
                      // ---------------------------------------------------
                      // FORM VALIDATION
                      // ---------------------------------------------------

                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // ---------------------------------------------------
                      // TARGET VALIDATION
                      // ---------------------------------------------------

                      if (!isEditing &&
                          targetType ==
                              'SPECIFIC_MEMBER' &&
                          selectedMemberId == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a member.',
                            ),
                          ),
                        );

                        return;
                      }

                      if (!isEditing &&
                          targetType ==
                              'SPECIFIC_TRAINER' &&
                          selectedTrainerId == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a trainer.',
                            ),
                          ),
                        );

                        return;
                      }

                      // ---------------------------------------------------
                      // START SAVING
                      // ---------------------------------------------------

                      setDialogState(() {
                        saving = true;
                      });

                      final api =
                          context.read<ApiService>();

                      final body = {
                        'title':
                            titleController.text.trim(),
                        'message':
                            messageController.text.trim(),
                      };

                      try {
                        // =================================================
                        // EDIT
                        // =================================================

                        if (isEditing) {
                          await api.put(
                            '/api/admin/notifications/${item['id']}',
                            body: body,
                          );
                        }

                        // =================================================
                        // CREATE
                        // =================================================

                        else {
                          switch (targetType) {
                            case 'ALL_MEMBERS':
                              await api.post(
                                '/api/admin/notifications/members',
                                body: body,
                              );
                              break;

                            case 'ALL_TRAINERS':
                              await api.post(
                                '/api/admin/notifications/trainers',
                                body: body,
                              );
                              break;

                            case 'SPECIFIC_MEMBER':
                              await api.post(
                                '/api/admin/notifications/member/$selectedMemberId',
                                body: body,
                              );
                              break;

                            case 'SPECIFIC_TRAINER':
                              await api.post(
                                '/api/admin/notifications/trainer/$selectedTrainerId',
                                body: body,
                              );
                              break;
                          }
                        }

                        // -------------------------------------------------
                        // CLOSE DIALOG FIRST
                        // -------------------------------------------------

                        if (!dialogContext.mounted) {
                          return;
                        }

                        Navigator.of(
                          dialogContext,
                        ).pop(true);
                      } on ApiException catch (e) {
                        if (!dialogContext.mounted) {
                          return;
                        }

                        setDialogState(() {
                          saving = false;
                        });

                        ScaffoldMessenger.of(
                          dialogContext,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                          ),
                        );
                      } catch (e) {
                        if (!dialogContext.mounted) {
                          return;
                        }

                        setDialogState(() {
                          saving = false;
                        });

                        ScaffoldMessenger.of(
                          dialogContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to save notification.',
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
    } finally {
      titleController.dispose();
      messageController.dispose();
    }

    // =========================================================
    // REFRESH AFTER DIALOG IS COMPLETELY CLOSED
    // =========================================================

    if (saved == true && mounted) {
      await _loadAll();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Notification updated successfully.'
                : 'Notification sent successfully.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // DELETE NOTIFICATION
  // =========================================================

  Future<void> _deleteNotification(num id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Notification',
          ),
          content: const Text(
            'Are you sure you want to permanently delete this notification?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('Delete'),
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
        '/api/admin/notifications/$id',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification deleted successfully.',
          ),
        ),
      );

      await _loadAll();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete notification.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // NOTIFICATION CARD
  // =========================================================

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final id = asNum(item['id']);

    final title = asString(
      item['title'],
      'Notification',
    );

    final message = asString(
      item['message'],
      'No message',
    );

    final recipientRole = asString(
      item['recipient_role'],
      '',
    );

    final rawDate = asString(
      item['created_at'],
    );

    String date = '';

    if (rawDate.isNotEmpty) {
      date = rawDate
          .replaceFirst('T', ' ')
          .split('.')
          .first;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final small =
                constraints.maxWidth < 650;

            // =======================================================
            // SMALL / MOBILE
            // =======================================================

            if (small) {
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
                            scheme.primary
                                .withOpacity(0.1),
                        child: Icon(
                          Icons
                              .notifications_active_outlined,
                          color: scheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      if (recipientRole.isNotEmpty)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(20),
                            color: scheme
                                .secondaryContainer,
                          ),
                          child: Text(
                            recipientRole,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                              color: scheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme
                          .textTheme
                          .bodyMedium
                          ?.color,
                    ),
                  ),

                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme
                            .textTheme
                            .bodySmall
                            ?.color,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                        onPressed: () =>
                            _openNotificationDialog(item),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _deleteNotification(id),
                      ),
                    ],
                  ),
                ],
              );
            }

            // =======================================================
            // DESKTOP
            // =======================================================

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      scheme.primary
                          .withOpacity(0.1),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: scheme.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          if (recipientRole.isNotEmpty)
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(20),
                                color: scheme
                                    .secondaryContainer,
                              ),
                              child: Text(
                                recipientRole,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: scheme
                                      .onSecondaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        message,
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme
                              .textTheme
                              .bodyMedium
                              ?.color,
                        ),
                      ),

                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  onPressed: () =>
                      _openNotificationDialog(item),
                ),

                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () =>
                      _deleteNotification(id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final padding =
        Responsive.pagePadding(context);

    // =======================================================
    // LOADING
    // =======================================================

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // =======================================================
    // ERROR
    // =======================================================

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),

              const SizedBox(height: 12),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _loadAll,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // =======================================================
    // NORMAL PAGE
    //
    // IMPORTANT:
    // EVEN WHEN DATABASE IS EMPTY,
    // HEADER + SEND BUTTON MUST REMAIN VISIBLE.
    // =======================================================

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =====================================================
                // HEADER
                // =====================================================

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final small =
                        constraints.maxWidth < 650;

                    if (small) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Broadcasts',
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
                            'Send announcements to members, trainers, or individual accounts.',
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),

                          const SizedBox(height: 16),

                          AppButton(
                            label: 'Send Notice',
                            icon:
                                Icons.send_outlined,
                            onPressed: () =>
                                _openNotificationDialog(),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notification Broadcasts',
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
                                'Send announcements to members, trainers, or individual accounts.',
                                style: theme
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        AppButton(
                          label: 'Send Notice',
                          icon:
                              Icons.send_outlined,
                          onPressed: () =>
                              _openNotificationDialog(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // =====================================================
                // EMPTY DATABASE
                // =====================================================

                if (_notifications.isEmpty)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons
                                  .notifications_none_outlined,
                              size: 56,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'No notifications yet.',
                              style: theme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Click "Send Notice" to create your first notification.',
                              textAlign:
                                  TextAlign.center,
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 18),

                            AppButton(
                              label:
                                  'Send First Notice',
                              icon:
                                  Icons.send_outlined,
                              onPressed: () =>
                                  _openNotificationDialog(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )

                // =====================================================
                // NOTIFICATION LIST
                // =====================================================

                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _notifications.length,
                    separatorBuilder: (
                      _,
                      __,
                    ) =>
                        const SizedBox(height: 12),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return _buildNotificationCard(
                        context,
                        _notifications[index],
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