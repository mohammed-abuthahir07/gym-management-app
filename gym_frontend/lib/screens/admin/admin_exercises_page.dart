import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminExercisesPage extends StatefulWidget {
  const AdminExercisesPage({super.key});

  @override
  State<AdminExercisesPage> createState() => _AdminExercisesPageState();
}

class _AdminExercisesPageState extends State<AdminExercisesPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _exercises = [];

  static const List<String> _difficulties = [
    'BEGINNER',
    'INTERMEDIATE',
    'DIFFICULT',
  ];

  static const List<String> _statuses = [
    'ACTIVE',
    'INACTIVE',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  // ============================================================
  // GET ALL EXERCISES
  // GET /api/admin/exercises
  // ============================================================

  Future<void> _fetchExercises() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/exercises',
      );

      List<dynamic> exercises = [];

      if (response is Map) {
        if (response['exercises'] is List) {
          exercises = response['exercises'] as List;
        }
      } else if (response is List) {
        exercises = response;
      }

      if (!mounted) return;

      setState(() {
        _exercises = asMapList(exercises);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load exercises.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // GET SINGLE EXERCISE
  // GET /api/admin/exercises/:id
  // ============================================================

  Future<Map<String, dynamic>?> _getExercise(
    dynamic id,
  ) async {
    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/admin/exercises/$id',
      );

      if (response is Map &&
          response['exercise'] is Map) {
        return Map<String, dynamic>.from(
          response['exercise'] as Map,
        );
      }

      return null;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }

      return null;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load exercise.',
            ),
          ),
        );
      }

      return null;
    }
  }

  // ============================================================
  // CREATE / EDIT EXERCISE
  // POST /api/admin/exercises
  // PUT /api/admin/exercises/:id
  // ============================================================

  Future<void> _openExerciseDialog([
    Map<String, dynamic>? existingExercise,
  ]) async {
    final bool isEditing = existingExercise != null;

    Map<String, dynamic>? exercise = existingExercise;

    // ------------------------------------------------------------
    // If editing, fetch the latest record using GET /:id
    // ------------------------------------------------------------

    if (isEditing) {
      final id = existingExercise['id'];

      final latest = await _getExercise(id);

      if (latest != null) {
        exercise = latest;
      } else {
        return;
      }
    }

    final nameController = TextEditingController(
      text: isEditing
          ? asString(exercise?['name'])
          : '',
    );

    final muscleController = TextEditingController(
      text: isEditing
          ? asString(exercise?['muscle_group'])
          : '',
    );

    final equipmentController = TextEditingController(
      text: isEditing
          ? asString(exercise?['equipment'])
          : '',
    );

    final instructionsController = TextEditingController(
      text: isEditing
          ? asString(exercise?['instructions'])
          : '',
    );

    final imageController = TextEditingController(
      text: isEditing
          ? asString(exercise?['image_url'])
          : '',
    );

    final videoController = TextEditingController(
      text: isEditing
          ? asString(exercise?['video_url'])
          : '',
    );

    String difficulty = isEditing
        ? asString(
            exercise?['difficulty'],
            'BEGINNER',
          )
        : 'BEGINNER';

    String status = isEditing
        ? asString(
            exercise?['status'],
            'ACTIVE',
          )
        : 'ACTIVE';

    if (!_difficulties.contains(difficulty)) {
      difficulty = 'BEGINNER';
    }

    if (!_statuses.contains(status)) {
      status = 'ACTIVE';
    }

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool saving = false;

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
                      ? 'Edit Exercise'
                      : 'Add Exercise',
                ),

                content: SizedBox(
                  width: dialogWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ==========================================
                            // NAME
                            // ==========================================

                            TextFormField(
                              controller: nameController,
                              enabled: !saving,
                              textInputAction:
                                  TextInputAction.next,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Exercise Name *',
                                hintText:
                                    'Example: Bench Press',
                                border:
                                    OutlineInputBorder(),
                              ),
                              validator: (value) {
                                return Validators.requiredField(
                                  value,
                                  label:
                                      'Exercise name',
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // MUSCLE GROUP
                            // ==========================================

                            TextFormField(
                              controller: muscleController,
                              enabled: !saving,
                              textInputAction:
                                  TextInputAction.next,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Muscle Group',
                                hintText:
                                    'Example: Chest',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // EQUIPMENT
                            // ==========================================

                            TextFormField(
                              controller:
                                  equipmentController,
                              enabled: !saving,
                              textInputAction:
                                  TextInputAction.next,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Equipment',
                                hintText:
                                    'Example: Barbell',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // DIFFICULTY
                            // ==========================================

                            DropdownButtonFormField<String>(
                              value: difficulty,
                              isExpanded: true,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Difficulty *',
                                border:
                                    OutlineInputBorder(),
                              ),
                              items:
                                  _difficulties.map(
                                (value) {
                                  return DropdownMenuItem<
                                      String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged: saving
                                  ? null
                                  : (value) {
                                      if (value ==
                                          null) {
                                        return;
                                      }

                                      setDialogState(
                                        () {
                                          difficulty =
                                              value;
                                        },
                                      );
                                    },
                            ),

                            // ==========================================
                            // STATUS
                            // ==========================================

                            if (isEditing) ...[
                              const SizedBox(height: 14),

                              DropdownButtonFormField<String>(
                                value: status,
                                isExpanded: true,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      'Status *',
                                  border:
                                      OutlineInputBorder(),
                                ),
                                items:
                                    _statuses.map(
                                  (value) {
                                    return DropdownMenuItem<
                                        String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: saving
                                    ? null
                                    : (value) {
                                        if (value ==
                                            null) {
                                          return;
                                        }

                                        setDialogState(
                                          () {
                                            status =
                                                value;
                                          },
                                        );
                                      },
                              ),
                            ],

                            const SizedBox(height: 14),

                            // ==========================================
                            // INSTRUCTIONS
                            // ==========================================

                            TextFormField(
                              controller:
                                  instructionsController,
                              enabled: !saving,
                              maxLines: 4,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Instructions',
                                hintText:
                                    'Explain how to perform the exercise',
                                border:
                                    OutlineInputBorder(),
                                alignLabelWithHint:
                                    true,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // IMAGE URL
                            // ==========================================

                            TextFormField(
                              controller:
                                  imageController,
                              enabled: !saving,
                              keyboardType:
                                  TextInputType.url,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Image URL',
                                hintText:
                                    'https://example.com/image.jpg',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // VIDEO URL
                            // ==========================================

                            TextFormField(
                              controller:
                                  videoController,
                              enabled: !saving,
                              keyboardType:
                                  TextInputType.url,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Video URL',
                                hintText:
                                    'https://example.com/video.mp4',
                                border:
                                    OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ======================================================
                // ACTIONS
                // ======================================================

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

                              // ========================================
                              // REQUEST BODY
                              // ========================================

                              final body =
                                  <String, dynamic>{
                                'name':
                                    nameController
                                        .text
                                        .trim(),

                                'muscle_group':
                                    muscleController
                                        .text
                                        .trim(),

                                'equipment':
                                    equipmentController
                                        .text
                                        .trim(),

                                'instructions':
                                    instructionsController
                                        .text
                                        .trim(),

                                'image_url':
                                    imageController
                                        .text
                                        .trim(),

                                'video_url':
                                    videoController
                                        .text
                                        .trim(),

                                'difficulty':
                                    difficulty,
                              };

                              // ========================================
                              // UPDATE
                              // PUT /api/admin/exercises/:id
                              // ========================================

                              if (isEditing) {
                                body['status'] =
                                    status;

                                final id =
                                    exercise?['id'];

                                await api.put(
                                  '/api/admin/exercises/$id',
                                  body: body,
                                );
                              }

                              // ========================================
                              // CREATE
                              // POST /api/admin/exercises
                              // ========================================

                              else {
                                await api.post(
                                  '/api/admin/exercises',
                                  body: body,
                                );
                              }

                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              Navigator.of(
                                dialogContext,
                              ).pop();

                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Exercise updated successfully'
                                        : 'Exercise created successfully',
                                  ),
                                ),
                              );

                              await _fetchExercises();
                            } on ApiException catch (e) {
                              if (!dialogContext
                                  .mounted) {
                                return;
                              }

                              setDialogState(() {
                                saving = false;
                              });

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

                              setDialogState(() {
                                saving = false;
                              });

                              ScaffoldMessenger.of(
                                dialogContext,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Something went wrong. Please try again.',
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
                        : Icon(
                            isEditing
                                ? Icons.save
                                : Icons.add,
                          ),
                    label: Text(
                      saving
                          ? 'Saving...'
                          : isEditing
                              ? 'Save Changes'
                              : 'Create Exercise',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      muscleController.dispose();
      equipmentController.dispose();
      instructionsController.dispose();
      imageController.dispose();
      videoController.dispose();
    }
  }

  // ============================================================
  // DELETE
  // DELETE /api/admin/exercises/:id
  // ============================================================

  Future<void> _deleteExercise(
    dynamic id,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Exercise'),
          content: const Text(
            'Are you sure you want to permanently delete this exercise?',
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
              style: FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
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

    if (confirmed != true) {
      return;
    }

    try {
      final api =
          context.read<ApiService>();

      await api.delete(
        '/api/admin/exercises/$id',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Exercise deleted successfully',
          ),
        ),
      );

      await _fetchExercises();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete exercise.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EXERCISE CARD
  // ============================================================

  Widget _buildExerciseCard(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final id =
        exercise['id'];

    final name = asString(
      exercise['name'],
      'Exercise',
    );

    final muscle = asString(
      exercise['muscle_group'],
    );

    final equipment = asString(
      exercise['equipment'],
    );

    final difficulty = asString(
      exercise['difficulty'],
      'BEGINNER',
    );

    final status = asString(
      exercise['status'],
      'ACTIVE',
    );

    final instructions =
        asString(
      exercise['instructions'],
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
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
                  radius: 24,
                  backgroundColor:
                      scheme.primary
                          .withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.fitness_center,
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
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      if (muscle.isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Muscle: $muscle',
                        ),
                      ],

                      if (equipment
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Equipment: $equipment',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            // ========================================================
            // BADGES
            // ========================================================

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: difficulty,
                ),
                StatusBadge(
                  label: status,
                  positive:
                      status == 'ACTIVE',
                ),
              ],
            ),

            // ========================================================
            // INSTRUCTIONS
            // ========================================================

            if (instructions
                .isNotEmpty) ...[
              const SizedBox(
                height: 14,
              ),
              const Divider(),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Instructions',
                style: theme
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                instructions,
              ),
            ],

            const SizedBox(
              height: 14,
            ),

            const Divider(),

            const SizedBox(
              height: 8,
            ),

            // ========================================================
            // ACTION BUTTONS
            // ========================================================

            Wrap(
              alignment:
                  WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _openExerciseDialog(
                      exercise,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                      const Text('Edit'),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    _deleteExercise(
                      id,
                    );
                  },
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Colors.red,
                  ),
                  icon: const Icon(
                    Icons
                        .delete_outline,
                    size: 18,
                  ),
                  label:
                      const Text(
                    'Delete',
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 48,
          horizontal: 24,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 52,
                color: theme
                    .colorScheme
                    .primary,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                'No exercises yet',
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

              const Text(
                'Your exercise database is empty.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                'Create your first exercise to add it to the gym library.',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              FilledButton.icon(
                onPressed: () {
                  _openExerciseDialog();
                },
                icon:
                    const Icon(Icons.add),
                label: const Text(
                  'Create First Exercise',
                ),
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
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final padding =
        Responsive.pagePadding(
      context,
    );

    // ==========================================================
    // LOADING
    // ==========================================================

    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                _error!,
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                height: 16,
              ),

              FilledButton.icon(
                onPressed:
                    _fetchExercises,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // NORMAL PAGE
    // IMPORTANT:
    // DO NOT USE AsyncStateView FOR EMPTY STATE HERE.
    // ==========================================================

    return RefreshIndicator(
      onRefresh: _fetchExercises,
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
                // ========================================================
                // HEADER
                // ========================================================

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
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
                            'Exercise Database',
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

                          const Text(
                            'Manage exercises available to trainers and members.',
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                AppButton(
                              label:
                                  'Add Exercise',
                              icon:
                                  Icons.add,
                              onPressed:
                                  () {
                                _openExerciseDialog();
                              },
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
                                'Exercise Database Administration',
                                style: theme
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              const Text(
                                'Manage exercises available to trainers and members.',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        AppButton(
                          label:
                              'Add Exercise',
                          icon:
                              Icons.add,
                          onPressed: () {
                            _openExerciseDialog();
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // ========================================================
                // EMPTY DATABASE
                // ========================================================

                if (_exercises.isEmpty)
                  _buildEmptyState(
                    context,
                  )

                // ========================================================
                // EXERCISE LIST
                // ========================================================

                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _exercises.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      return _buildExerciseCard(
                        context,
                        _exercises[index],
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