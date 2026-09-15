import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() =>
      _AdminChallengesPageState();
}

class _AdminChallengesPageState
    extends State<AdminChallengesPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  // ============================================================
  // GET ALL CHALLENGES
  // GET /api/admin/challenges
  // ============================================================

  Future<void> _fetchChallenges() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response =
          await api.get('/api/admin/challenges');

      List<dynamic> list = [];

      if (response is Map) {
        if (response['challenges'] is List) {
          list = response['challenges'] as List;
        } else if (response['data'] is List) {
          list = response['data'] as List;
        }
      } else if (response is List) {
        list = response;
      }

      if (!mounted) return;

      setState(() {
        _challenges = asMapList(list);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load challenges.';
        _loading = false;
      });
    }
  }

  // ============================================================
  // GET SINGLE CHALLENGE
  // GET /api/admin/challenges/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getChallenge(
      dynamic id) async {
    try {
      final api = context.read<ApiService>();

      final response =
          await api.get('/api/admin/challenges/$id');

      if (response is Map) {
        if (response['challenge'] is Map) {
          return Map<String, dynamic>.from(
            response['challenge'] as Map,
          );
        }

        if (response['data'] is Map) {
          return Map<String, dynamic>.from(
            response['data'] as Map,
          );
        }
      }

      return null;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }

      return null;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load challenge details.'),
          ),
        );
      }

      return null;
    }
  }

  // ============================================================
  // DATE VALIDATION
  // ============================================================

  String? _validateDate(
    String? value, {
    required String label,
  }) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$label is required';
    }

    final date = DateTime.tryParse(text);

    if (date == null) {
      return '$label must be YYYY-MM-DD';
    }

    final normalized =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    if (normalized != text) {
      return '$label must be YYYY-MM-DD';
    }

    return null;
  }

  // ============================================================
  // OPEN CREATE / EDIT DIALOG
  // ============================================================

  Future<void> _openDialog(
    [Map<String, dynamic>? item]
  ) async {
    final isEditing = item != null;

    Map<String, dynamic>? editItem = item;

    // ----------------------------------------------------------
    // When editing, get fresh data using GET /:id
    // ----------------------------------------------------------

    if (isEditing) {
      final id = item['id'];

      final freshChallenge =
          await _getChallenge(id);

      if (!mounted) return;

      if (freshChallenge == null) {
        return;
      }

      editItem = freshChallenge;
    }

    final titleCtrl = TextEditingController(
      text: isEditing
          ? asString(editItem?['title'])
          : '',
    );

    final descCtrl = TextEditingController(
      text: isEditing
          ? asString(editItem?['description'])
          : '',
    );

    final rewardCtrl = TextEditingController(
      text: isEditing
          ? asString(editItem?['reward'])
          : '',
    );

    final startCtrl = TextEditingController(
      text: isEditing
          ? _dateOnly(editItem?['start_date'])
          : _todayString(),
    );

    final endCtrl = TextEditingController(
      text: isEditing
          ? _dateOnly(editItem?['end_date'])
          : _futureDateString(30),
    );

    String status = isEditing
        ? asString(
            editItem?['status'],
            'ACTIVE',
          ).toUpperCase()
        : 'ACTIVE';

    if (status != 'ACTIVE' && status != 'INACTIVE') {
      status = 'ACTIVE';
    }

    final formKey = GlobalKey<FormState>();

    bool saving = false;

    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: !saving,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              final screenWidth =
                  MediaQuery.of(dialogContext).size.width;

              final dialogWidth =
                  screenWidth < 600
                      ? screenWidth - 32
                      : 520.0;

              return AlertDialog(
                title: Text(
                  isEditing
                      ? 'Edit Challenge'
                      : 'Create New Challenge',
                ),

                content: SizedBox(
                  width: dialogWidth,
                  child: Form(
                    key: formKey,

                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          // ------------------------------------
                          // TITLE
                          // ------------------------------------

                          TextFormField(
                            controller: titleCtrl,
                            textInputAction:
                                TextInputAction.next,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Challenge Title *',
                              hintText:
                                  'Example: 30 Day Fitness Challenge',
                              border:
                                  OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                Validators.requiredField(
                              value,
                              label: 'Title',
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------
                          // DESCRIPTION
                          // ------------------------------------

                          TextFormField(
                            controller: descCtrl,
                            textInputAction:
                                TextInputAction.next,
                            maxLines: 4,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Rules & Target Description',
                              hintText:
                                  'Describe the challenge rules and target',
                              border:
                                  OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------
                          // START DATE
                          // ------------------------------------

                          TextFormField(
                            controller: startCtrl,
                            keyboardType:
                                TextInputType.datetime,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Start Date *',
                              hintText: 'YYYY-MM-DD',
                              border:
                                  OutlineInputBorder(),
                              suffixIcon:
                                  Icon(Icons.calendar_today),
                            ),
                            validator: (value) =>
                                _validateDate(
                              value,
                              label: 'Start date',
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------
                          // END DATE
                          // ------------------------------------

                          TextFormField(
                            controller: endCtrl,
                            keyboardType:
                                TextInputType.datetime,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'End Date *',
                              hintText: 'YYYY-MM-DD',
                              border:
                                  OutlineInputBorder(),
                              suffixIcon:
                                  Icon(Icons.calendar_today),
                            ),
                            validator: (value) =>
                                _validateDate(
                              value,
                              label: 'End date',
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------
                          // REWARD
                          // ------------------------------------

                          TextFormField(
                            controller: rewardCtrl,
                            textInputAction:
                                TextInputAction.done,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Reward / Prize *',
                              hintText:
                                  'Example: Free T-shirt',
                              border:
                                  OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                Validators.requiredField(
                              value,
                              label: 'Reward',
                            ),
                          ),

                          // ------------------------------------
                          // STATUS - EDIT ONLY
                          // ------------------------------------

                          if (isEditing) ...[
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: status,
                              decoration:
                                  const InputDecoration(
                                labelText: 'Status *',
                                border:
                                    OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ACTIVE',
                                  child:
                                      Text('ACTIVE'),
                                ),
                                DropdownMenuItem(
                                  value: 'INACTIVE',
                                  child:
                                      Text('INACTIVE'),
                                ),
                              ],
                              onChanged: saving
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        status =
                                            value ??
                                                'ACTIVE';
                                      });
                                    },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                actionsPadding:
                    const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),

                actions: [
                  // ------------------------------------------
                  // CANCEL
                  // ------------------------------------------

                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            Navigator.of(
                              dialogContext,
                            ).pop(false);
                          },
                    child:
                        const Text('Cancel'),
                  ),

                  const SizedBox(width: 8),

                  // ------------------------------------------
                  // SAVE / CREATE
                  // ------------------------------------------

                  AppButton(
                    loading: saving,
                    label: isEditing
                        ? 'Save Changes'
                        : 'Create Challenge',
                    icon: isEditing
                        ? Icons.save_outlined
                        : Icons.add,
                    onPressed: saving
                        ? null
                        : () async {
                            // ------------------------------
                            // VALIDATE FORM
                            // ------------------------------

                            if (!formKey
                                .currentState!
                                .validate()) {
                              return;
                            }

                            // ------------------------------
                            // VALIDATE DATE ORDER
                            // ------------------------------

                            final start =
                                DateTime.tryParse(
                              startCtrl.text.trim(),
                            );

                            final end =
                                DateTime.tryParse(
                              endCtrl.text.trim(),
                            );

                            if (start == null ||
                                end == null) {
                              return;
                            }

                            if (!end.isAfter(start)) {
                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'End date must be after start date.',
                                  ),
                                ),
                              );
                              return;
                            }

                            // ------------------------------
                            // START SAVING
                            // ------------------------------

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final api =
                                  context.read<
                                      ApiService>();

                              // ----------------------------
                              // EXACT API BODY
                              // ----------------------------

                              final body =
                                  <String, dynamic>{
                                'title':
                                    titleCtrl.text.trim(),

                                'description':
                                    descCtrl.text.trim(),

                                'start_date':
                                    startCtrl.text.trim(),

                                'end_date':
                                    endCtrl.text.trim(),

                                'reward':
                                    rewardCtrl.text.trim(),

                                if (isEditing)
                                  'status': status,
                              };

                              // ----------------------------
                              // CREATE
                              // POST /api/admin/challenges
                              // ----------------------------

                              if (!isEditing) {
                                await api.post(
                                  '/api/admin/challenges',
                                  body: body,
                                );
                              }

                              // ----------------------------
                              // UPDATE
                              // PUT /api/admin/challenges/:id
                              // ----------------------------

                              else {
                                final challengeId =
                                    editItem?['id'];

                                await api.put(
                                  '/api/admin/challenges/$challengeId',
                                  body: body,
                                );
                              }

                              if (!dialogContext.mounted) {
                                return;
                              }

                              Navigator.of(
                                dialogContext,
                              ).pop(true);
                            } on ApiException catch (e) {
                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(e.message),
                                ),
                              );
                            } catch (_) {
                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to save challenge.',
                                  ),
                                ),
                              );
                            } finally {
                              if (dialogContext
                                  .mounted) {
                                setDialogState(() {
                                  saving = false;
                                });
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

      // --------------------------------------------------------
      // REFRESH ONLY AFTER DIALOG IS CLOSED
      // --------------------------------------------------------

      if (result == true && mounted) {
        await _fetchChallenges();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Challenge updated successfully.'
                  : 'Challenge created successfully.',
            ),
          ),
        );
      }
    } finally {
      titleCtrl.dispose();
      descCtrl.dispose();
      rewardCtrl.dispose();
      startCtrl.dispose();
      endCtrl.dispose();
    }
  }

  // ============================================================
  // DELETE
  // DELETE /api/admin/challenges/:id
  // ============================================================

  Future<void> _deleteChallenge(
    dynamic id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Challenge'),

          content: const Text(
            'Are you sure you want to permanently delete this challenge?',
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

    if (confirm != true) {
      return;
    }

    try {
      final api = context.read<ApiService>();

      await api.delete(
        '/api/admin/challenges/$id',
      );

      if (!mounted) return;

      await _fetchChallenges();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Challenge deleted successfully.'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to delete challenge.'),
        ),
      );
    }
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _todayString() {
    final now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _futureDateString(int days) {
    final date =
        DateTime.now().add(Duration(days: days));

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _dateOnly(dynamic value) {
    final text = asString(value);

    if (text.isEmpty) {
      return '';
    }

    return text.split('T').first;
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    BuildContext context,
    String status,
  ) {
    final theme = Theme.of(context);

    final isActive =
        status.toUpperCase() == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.grey.withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isActive
              ? Colors.green
              : Colors.grey,
        ),
      ),
    );
  }

  // ============================================================
  // CHALLENGE CARD
  // ============================================================

  Widget _buildChallengeCard(
    BuildContext context,
    Map<String, dynamic> challenge,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final id = challenge['id'];

    final title =
        asString(
          challenge['title'],
          'Challenge',
        );

    final description =
        asString(
          challenge['description'],
        );

    final reward =
        asString(
          challenge['reward'],
          'No reward specified',
        );

    final start =
        _dateOnly(
          challenge['start_date'],
        );

    final end =
        _dateOnly(
          challenge['end_date'],
        );

    final status =
        asString(
          challenge['status'],
          'ACTIVE',
        ).toUpperCase();

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // TOP ROW
            // --------------------------------------------------

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      scheme.primary
                          .withOpacity(0.10),
                  child: Icon(
                    Icons.military_tech,
                    color: scheme.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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

                      const SizedBox(height: 5),

                      _statusChip(
                        context,
                        status,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --------------------------------------------------
            // DESCRIPTION
            // --------------------------------------------------

            if (description.isNotEmpty) ...[
              Text(
                description,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 14),
            ],

            // --------------------------------------------------
            // INFORMATION
            // --------------------------------------------------

            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _infoItem(
                  context,
                  Icons.calendar_today_outlined,
                  '$start → $end',
                ),
                _infoItem(
                  context,
                  Icons.card_giftcard_outlined,
                  reward,
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(height: 1),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // ACTIONS
            // --------------------------------------------------

            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _openDialog(challenge),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                      const Text('Edit'),
                ),

                OutlinedButton.icon(
                  onPressed: () =>
                      _deleteChallenge(id),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                    ),
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
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);

    return Container(
      constraints:
          const BoxConstraints(
        maxWidth: 500,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color:
                theme.colorScheme.primary,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 45,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.military_tech_outlined,
                size: 52,
                color: scheme.primary
                    .withOpacity(0.65),
              ),

              const SizedBox(height: 14),

              Text(
                'No challenges created yet',
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

              const SizedBox(height: 6),

              Text(
                'Create your first gym challenge using the button above.',
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
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              Text(
                _error ??
                    'Failed to load challenges.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 14),

              FilledButton.icon(
                onPressed:
                    _fetchChallenges,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                    const Text('Retry'),
              ),
            ],
          ),
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

    return RefreshIndicator(
      onRefresh: _fetchChallenges,

      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            EdgeInsets.all(padding),

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
                // ==================================================
                // HEADER
                // ==================================================

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final isMobile =
                        constraints.maxWidth <
                            650;

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Challenges Administration',
                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            'Design gym-wide milestones and prize challenges for members.',
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
                            child: AppButton(
                              label:
                                  'New Challenge',
                              icon:
                                  Icons.add,
                              onPressed:
                                  () =>
                                      _openDialog(),
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
                                'Challenges Administration',
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
                                'Design gym-wide milestones and prize challenges for members.',
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

                        AppButton(
                          label:
                              'New Challenge',
                          icon:
                              Icons.add,
                          onPressed:
                              () =>
                                  _openDialog(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                if (_loading)
                  const Center(
                    child:
                        Padding(
                      padding:
                          EdgeInsets.all(40),
                      child:
                          CircularProgressIndicator(),
                    ),
                  )

                else if (_error != null)
                  _buildErrorState(
                    context,
                  )

                else if (_challenges.isEmpty)
                  _buildEmptyState(
                    context,
                  )

                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _challenges.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      return _buildChallengeCard(
                        context,
                        _challenges[index],
                      );
                    },
                  ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}