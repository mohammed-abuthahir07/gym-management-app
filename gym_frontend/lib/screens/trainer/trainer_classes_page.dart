import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerClassesPage extends StatefulWidget {
  const TrainerClassesPage({super.key});

  @override
  State<TrainerClassesPage> createState() => _TrainerClassesPageState();
}

class _TrainerClassesPageState extends State<TrainerClassesPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  // ============================================================
  // GET ALL CLASS SCHEDULES
  // GET /api/trainer/class-schedules
  // ============================================================

  Future<void> _fetchClasses() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/class-schedules',
      );

      List<dynamic> list = [];

      if (response is Map) {
        final res = Map<String, dynamic>.from(response);

        if (res['classes'] is List) {
          list = res['classes'] as List;
        }
      } else if (response is List) {
        list = response;
      }

      if (!mounted) return;

      setState(() {
        _classes = asMapList(list);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load trainer class schedules.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // CREATE / EDIT CLASS
  // ============================================================

  Future<void> _openClassDialog([
    Map<String, dynamic>? item,
  ]) async {
    if (!mounted) return;

    final bool isEditing = item != null;

    final titleController = TextEditingController(
      text: isEditing
          ? asString(item['title'])
          : '',
    );

    final dateController = TextEditingController(
      text: isEditing
          ? _formatDate(asString(item['class_date']))
          : _defaultDate(),
    );

    final startController = TextEditingController(
      text: isEditing
          ? _formatTime(asString(item['start_time']))
          : '07:00:00',
    );

    final endController = TextEditingController(
      text: isEditing
          ? _formatTime(asString(item['end_time']))
          : '08:00:00',
    );

    final capacityController = TextEditingController(
      text: isEditing
          ? asString(item['capacity'])
          : '20',
    );

    final formKey = GlobalKey<FormState>();

    bool saving = false;
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
                        ? Icons.edit_calendar_outlined
                        : Icons.calendar_month_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Edit Class Schedule'
                          : 'Create Class Schedule',
                    ),
                  ),
                ],
              ),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ------------------------------------------------
                        // TITLE
                        // ------------------------------------------------

                        TextFormField(
                          controller: titleController,
                          enabled: !saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Class Title *',
                            hintText: 'Example: Morning HIIT',
                            prefixIcon:
                                Icon(Icons.title_outlined),
                          ),
                          validator: (value) {
                            final title =
                                value?.trim() ?? '';

                            if (title.isEmpty) {
                              return 'Title is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------------
                        // DATE
                        // ------------------------------------------------

                        TextFormField(
                          controller: dateController,
                          enabled: !saving,
                          keyboardType:
                              TextInputType.datetime,
                          textInputAction:
                              TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon:
                                Icon(Icons.date_range_outlined),
                          ),
                          validator: (value) {
                            return _validateDate(value);
                          },
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------------
                        // START / END TIME
                        // ------------------------------------------------

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller:
                                    startController,
                                enabled: !saving,
                                keyboardType:
                                    TextInputType.datetime,
                                textInputAction:
                                    TextInputAction.next,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'Start Time *',
                                  hintText:
                                      'HH:MM:SS',
                                  prefixIcon:
                                      Icon(
                                    Icons
                                        .access_time_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  return _validateTime(
                                    value,
                                    label: 'Start time',
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: TextFormField(
                                controller:
                                    endController,
                                enabled: !saving,
                                keyboardType:
                                    TextInputType.datetime,
                                textInputAction:
                                    TextInputAction.next,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'End Time *',
                                  hintText:
                                      'HH:MM:SS',
                                  prefixIcon:
                                      Icon(
                                    Icons
                                        .access_time_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  final error =
                                      _validateTime(
                                    value,
                                    label: 'End time',
                                  );

                                  if (error != null) {
                                    return error;
                                  }

                                  final start =
                                      _timeToSeconds(
                                    startController.text
                                        .trim(),
                                  );

                                  final end =
                                      _timeToSeconds(
                                    endController.text
                                        .trim(),
                                  );

                                  if (start != null &&
                                      end != null &&
                                      end <= start) {
                                    return 'End time must be after start time';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------------
                        // CAPACITY
                        // ------------------------------------------------

                        TextFormField(
                          controller:
                              capacityController,
                          enabled: !saving,
                          keyboardType:
                              TextInputType.number,
                          textInputAction:
                              TextInputAction.done,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Capacity *',
                            hintText:
                                'Example: 20',
                            prefixIcon:
                                Icon(
                              Icons
                                  .groups_outlined,
                            ),
                          ),
                          validator: (value) {
                            final text =
                                value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Capacity is required';
                            }

                            final capacity =
                                int.tryParse(text);

                            if (capacity == null) {
                              return 'Capacity must be a valid number';
                            }

                            if (capacity <= 0) {
                              return 'Capacity must be greater than 0';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actionsPadding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16,
              ),

              actions: [
                // --------------------------------------------------------
                // CANCEL
                // --------------------------------------------------------

                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(
                            dialogContext,
                          ).pop();
                        },
                  child: const Text('Cancel'),
                ),

                const SizedBox(width: 8),

                // --------------------------------------------------------
                // SAVE
                // --------------------------------------------------------

                AppButton(
                  label: isEditing
                      ? 'Save Changes'
                      : 'Schedule Class',
                  icon: isEditing
                      ? Icons.save_outlined
                      : Icons.add_task_outlined,
                  loading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          // Validate form
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          final title =
                              titleController.text.trim();

                          final classDate =
                              dateController.text.trim();

                          final startTime =
                              startController.text.trim();

                          final endTime =
                              endController.text.trim();

                          final capacity =
                              int.tryParse(
                            capacityController.text
                                .trim(),
                          );

                          // This should never be null
                          // because validator already checked.
                          if (capacity == null ||
                              capacity <= 0) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final api =
                                context.read<ApiService>();

                            final body = {
                              'title': title,
                              'class_date': classDate,
                              'start_time': startTime,
                              'end_time': endTime,
                              'capacity': capacity,
                            };

                            // ------------------------------------------------
                            // EDIT
                            // PUT /api/trainer/class-schedules/:id
                            // ------------------------------------------------

                            if (isEditing) {
                              final classId =
                                  asNum(item['id']);

                              await api.put(
                                '/api/trainer/class-schedules/$classId',
                                body: body,
                              );
                            }

                            // ------------------------------------------------
                            // CREATE
                            // POST /api/trainer/class-schedules
                            // ------------------------------------------------

                            else {
                              await api.post(
                                '/api/trainer/class-schedules',
                                body: body,
                              );
                            }

                            savedSuccessfully = true;

                            // Close dialog only after API succeeds.
                            if (dialogContext.mounted) {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            }
                          } on ApiException catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            _showDialogError(
                              dialogContext,
                              e.message,
                            );
                          } catch (_) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            _showDialogError(
                              dialogContext,
                              'Failed to save class schedule.',
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

    // --------------------------------------------------------------
    // Dispose controllers AFTER dialog is completely closed.
    // --------------------------------------------------------------

    titleController.dispose();
    dateController.dispose();
    startController.dispose();
    endController.dispose();
    capacityController.dispose();

    // --------------------------------------------------------------
    // Refresh ONLY after dialog has closed successfully.
    // --------------------------------------------------------------

    if (savedSuccessfully && mounted) {
      _showMessage(
        isEditing
            ? 'Class schedule updated successfully.'
            : 'Class schedule created successfully.',
      );

      await _fetchClasses();
    }
  }

  // ============================================================
  // DELETE CLASS
  // DELETE /api/trainer/class-schedules/:id
  // ============================================================

  Future<void> _deleteClass(num id) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Class Schedule',
          ),
          content: const Text(
            'Are you sure you want to delete this scheduled class?',
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
        '/api/trainer/class-schedules/$id',
      );

      if (!mounted) return;

      _showMessage(
        'Class schedule deleted successfully.',
      );

      await _fetchClasses();
    } on ApiException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        error: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete class schedule.',
        error: true,
      );
    }
  }

  // ============================================================
  // DATE VALIDATION
  // ============================================================

  String? _validateDate(String? value) {
    final date = value?.trim() ?? '';

    if (date.isEmpty) {
      return 'Date is required';
    }

    final regex = RegExp(
      r'^\d{4}-\d{2}-\d{2}$',
    );

    if (!regex.hasMatch(date)) {
      return 'Use date format YYYY-MM-DD';
    }

    final parts = date.split('-');

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null ||
        month == null ||
        day == null) {
      return 'Enter a valid date';
    }

    try {
      final parsed = DateTime(
        year,
        month,
        day,
      );

      if (parsed.year != year ||
          parsed.month != month ||
          parsed.day != day) {
        return 'Enter a valid date';
      }
    } catch (_) {
      return 'Enter a valid date';
    }

    return null;
  }

  // ============================================================
  // TIME VALIDATION
  // ============================================================

  String? _validateTime(
    String? value, {
    required String label,
  }) {
    final time = value?.trim() ?? '';

    if (time.isEmpty) {
      return '$label is required';
    }

    final regex = RegExp(
      r'^\d{2}:\d{2}:\d{2}$',
    );

    if (!regex.hasMatch(time)) {
      return '$label must be HH:MM:SS';
    }

    final parts = time.split(':');

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = int.tryParse(parts[2]);

    if (hour == null ||
        minute == null ||
        second == null) {
      return 'Enter a valid $label';
    }

    if (hour < 0 || hour > 23) {
      return 'Hour must be between 00 and 23';
    }

    if (minute < 0 || minute > 59) {
      return 'Minute must be between 00 and 59';
    }

    if (second < 0 || second > 59) {
      return 'Second must be between 00 and 59';
    }

    return null;
  }

  // ============================================================
  // TIME TO SECONDS
  // ============================================================

  int? _timeToSeconds(String value) {
    final parts = value.split(':');

    if (parts.length != 3) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = int.tryParse(parts[2]);

    if (hour == null ||
        minute == null ||
        second == null) {
      return null;
    }

    return (hour * 3600) +
        (minute * 60) +
        second;
  }

  // ============================================================
  // DEFAULT DATE
  // ============================================================

  String _defaultDate() {
    final date = DateTime.now().add(
      const Duration(days: 1),
    );

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // FORMAT DATE FROM API
  // ============================================================

  String _formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    return value.split('T').first;
  }

  // ============================================================
  // FORMAT TIME FROM API
  // ============================================================

  String _formatTime(String value) {
    if (value.isEmpty) {
      return '';
    }

    // If API already returns HH:MM:SS
    if (value.length >= 8) {
      return value.substring(0, 8);
    }

    return value;
  }

  // ============================================================
  // DIALOG ERROR
  // ============================================================

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
  // GENERAL MESSAGE
  // ============================================================

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
          backgroundColor:
              error ? Colors.red : null,
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

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchClasses,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchClasses,
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
                  // HEADER
                  // ======================================================

                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final isMobile =
                          constraints.maxWidth < 650;

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Classes Schedule',
                              style: theme.textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Manage group training sessions, timeslots, and participant capacity.',
                              style: theme.textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width:
                                  double.infinity,
                              child: AppButton(
                                label: 'Add Class',
                                icon: Icons.add,
                                onPressed:
                                    () =>
                                        _openClassDialog(),
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
                                  'Group Classes Schedule',
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
                                  'Manage group training sessions, timeslots, and participant capacity.',
                                  style: theme
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          SizedBox(
                            width: 145,
                            child: AppButton(
                              label: 'Add Class',
                              icon: Icons.add,
                              onPressed:
                                  () =>
                                      _openClassDialog(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // EMPTY STATE
                  // ======================================================

                  if (_classes.isEmpty)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 50,
                          horizontal: 24,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons
                                    .calendar_month_outlined,
                                size: 52,
                                color: scheme
                                    .primary
                                    .withValues(
                                  alpha: 0.6,
                                ),
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              Text(
                                'No group classes scheduled yet.',
                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                textAlign:
                                    TextAlign.center,
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                'Create your first class schedule using the Add Class button.',
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

                  // ======================================================
                  // CLASS LIST
                  // ======================================================

                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _classes.length,
                      separatorBuilder:
                          (_, _) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        final classItem =
                            _classes[index];

                        final id =
                            asNum(
                          classItem['id'],
                        );

                        final title =
                            asString(
                          classItem['title'],
                          'Group Training',
                        );

                        final date =
                            _formatDate(
                          asString(
                            classItem[
                                'class_date'],
                          ),
                        );

                        final start =
                            _formatTime(
                          asString(
                            classItem[
                                'start_time'],
                          ),
                        );

                        final end =
                            _formatTime(
                          asString(
                            classItem[
                                'end_time'],
                          ),
                        );

                        final capacity =
                            asNum(
                          classItem[
                              'capacity'],
                        );

                        return _ClassCard(
                          title: title,
                          date: date,
                          startTime: start,
                          endTime: end,
                          capacity: capacity,
                          onEdit: () =>
                              _openClassDialog(
                            classItem,
                          ),
                          onDelete: () =>
                              _deleteClass(id),
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
}

// ====================================================================
// CLASS CARD
// ====================================================================

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final num capacity;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isMobile =
                constraints.maxWidth < 600;

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            scheme.primary
                                .withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons
                              .calendar_month_outlined,
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
                              height: 6,
                            ),

                            Text(
                              date,
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              '$startTime - $endTime',
                              style: theme
                                  .textTheme
                                  .bodyMedium,
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              'Max Capacity: $capacity',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color:
                                    scheme.primary,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                        ),
                        label:
                            const Text('Edit'),
                      ),

                      const SizedBox(width: 8),

                      OutlinedButton.icon(
                        onPressed: onDelete,
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.red,
                        ),
                        icon: const Icon(
                          Icons
                              .delete_outline,
                          size: 18,
                        ),
                        label:
                            const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              );
            }

            // ------------------------------------------------------------
            // DESKTOP / WINDOWS
            // ------------------------------------------------------------

            return Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      scheme.primary
                          .withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons
                        .calendar_month_outlined,
                    color:
                        scheme.primary,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
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

                      Text(
                        'Date: $date',
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Time: $startTime - $endTime',
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Max Capacity: $capacity',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                              scheme.primary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                IconButton(
                  tooltip: 'Edit class',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                IconButton(
                  tooltip: 'Delete class',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}