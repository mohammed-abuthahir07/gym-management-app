import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerWorkoutPlansPage extends StatefulWidget {
  const TrainerWorkoutPlansPage({super.key});

  @override
  State<TrainerWorkoutPlansPage> createState() =>
      _TrainerWorkoutPlansPageState();
}

class _TrainerWorkoutPlansPageState
    extends State<TrainerWorkoutPlansPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _exercises = [];

  static const List<String> _workoutDays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

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
      // =======================================================
      // LOAD WORKOUT PLANS
      // =======================================================

      final plansRes =
          await api.get('/api/trainer/workout-plans');

      // =======================================================
      // LOAD ASSIGNED MEMBERS
      // =======================================================

      final membersRes =
          await api.get('/api/trainer/assigned-members');

      // =======================================================
      // LOAD ACTIVE EXERCISES
      // =======================================================
      //
      // IMPORTANT:
      // Trainer is READ-ONLY for exercises.
      //
      // Admin creates exercises.
      // Trainer only gets ACTIVE exercises.
      //

      final exercisesRes =
          await api.get('/api/trainer/exercises');

      // =======================================================
      // EXTRACT PLANS
      // =======================================================

      List<dynamic> planList = [];

      if (plansRes is Map) {
        if (plansRes['plans'] is List) {
          planList = plansRes['plans'];
        } else if (plansRes['data'] is List) {
          planList = plansRes['data'];
        }
      } else if (plansRes is List) {
        planList = plansRes;
      }

      // =======================================================
      // EXTRACT MEMBERS
      // =======================================================

      List<dynamic> memberList = [];

      if (membersRes is Map) {
        if (membersRes['members'] is List) {
          memberList = membersRes['members'];
        } else if (membersRes['data'] is List) {
          memberList = membersRes['data'];
        }
      } else if (membersRes is List) {
        memberList = membersRes;
      }

      // =======================================================
      // EXTRACT EXERCISES
      // =======================================================

      List<dynamic> exerciseList = [];

      if (exercisesRes is Map) {
        if (exercisesRes['exercises'] is List) {
          exerciseList = exercisesRes['exercises'];
        } else if (exercisesRes['data'] is List) {
          exerciseList = exercisesRes['data'];
        }
      } else if (exercisesRes is List) {
        exerciseList = exercisesRes;
      }

      if (!mounted) return;

      setState(() {
        _plans = asMapList(planList);
        _members = asMapList(memberList);
        _exercises = asMapList(exerciseList);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load workout plans.';
      });
    }
  }

  // =========================================================
  // CREATE WORKOUT PLAN
  // =========================================================

  Future<void> _openCreatePlanDialog() async {
    // =======================================================
    // MEMBER CHECK
    // =======================================================

    if (_members.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No assigned members found. Please ask admin to assign a member to you first.',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // EXERCISE CHECK
    // =======================================================

    if (_exercises.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active exercises are available. Please ask admin to create an active exercise first.',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // DEFAULT VALUES
    // =======================================================

    num? selectedMemberId =
        asNum(_members.first['id']);

    num? selectedExerciseId =
        asNum(_exercises.first['id']);

    String selectedDay =
        _workoutDays.first;

    final planNameCtrl =
        TextEditingController(
      text: 'Weekly Strength Plan',
    );

    final setsCtrl =
        TextEditingController(
      text: '4',
    );

    final repsCtrl =
        TextEditingController(
      text: '10',
    );

    final durationCtrl =
        TextEditingController(
      text: '15',
    );

    final notesCtrl =
        TextEditingController();

    final formKey =
        GlobalKey<FormState>();

    final bool? saved =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
            dialogCtx,
            setDialogState,
          ) {
            final screenWidth =
                MediaQuery.of(dialogCtx).size.width;

            final dialogWidth =
                screenWidth < 600
                    ? screenWidth * 0.90
                    : 500.0;

            return AlertDialog(
              title: const Text(
                'Assign Workout Plan',
              ),

              content: SizedBox(
                width: dialogWidth,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        // =================================================
                        // MEMBER
                        // =================================================

                        DropdownButtonFormField<num>(
                          value: selectedMemberId,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Assigned Member *',
                            isDense: true,
                          ),
                          items:
                              _members.map(
                            (member) {
                              final id =
                                  asNum(
                                member['id'],
                              );

                              final name =
                                  asString(
                                member['name'],
                                'Member',
                              );

                              final email =
                                  asString(
                                member['email'],
                                '',
                              );

                              return DropdownMenuItem<num>(
                                value: id,
                                child: Text(
                                  email.isEmpty
                                      ? name
                                      : '$name • $email',
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
                                  setDialogState(() {
                                    selectedMemberId =
                                        value;
                                  });
                                },
                          validator: (_) {
                            if (selectedMemberId ==
                                null) {
                              return 'Please select a member';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // PLAN NAME
                        // =================================================

                        TextFormField(
                          controller:
                              planNameCtrl,
                          enabled: !saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Plan Name *',
                            hintText:
                                'e.g. Weekly Strength Plan',
                            isDense: true,
                          ),
                          validator: (value) =>
                              Validators.requiredField(
                            value,
                            label: 'Plan name',
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // EXERCISE
                        // =================================================

                        DropdownButtonFormField<num>(
                          value:
                              selectedExerciseId,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Exercise *',
                            isDense: true,
                          ),
                          items:
                              _exercises.map(
                            (exercise) {
                              final id =
                                  asNum(
                                exercise['id'],
                              );

                              final name =
                                  asString(
                                exercise['name'],
                                'Exercise',
                              );

                              final muscleGroup =
                                  asString(
                                exercise[
                                    'muscle_group'],
                                '',
                              );

                              final label =
                                  muscleGroup.isEmpty
                                      ? name
                                      : '$name • $muscleGroup';

                              return DropdownMenuItem<num>(
                                value: id,
                                child: Text(
                                  label,
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
                                  setDialogState(() {
                                    selectedExerciseId =
                                        value;
                                  });
                                },
                          validator: (_) {
                            if (selectedExerciseId ==
                                null) {
                              return 'Please select an exercise';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // WORKOUT DAY
                        // =================================================

                        DropdownButtonFormField<String>(
                          value: selectedDay,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Workout Day *',
                            isDense: true,
                          ),
                          items:
                              _workoutDays.map(
                            (day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            },
                          ).toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedDay =
                                        value ??
                                            _workoutDays
                                                .first;
                                  });
                                },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // SETS / REPS / DURATION
                        // =================================================

                        LayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            final small =
                                constraints.maxWidth <
                                    420;

                            if (small) {
                              return Column(
                                children: [
                                  _numberField(
                                    controller:
                                        setsCtrl,
                                    label:
                                        'Sets *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  _numberField(
                                    controller:
                                        repsCtrl,
                                    label:
                                        'Reps *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  _numberField(
                                    controller:
                                        durationCtrl,
                                    label:
                                        'Duration (mins)',
                                    enabled:
                                        !saving,
                                    required:
                                        false,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        setsCtrl,
                                    label:
                                        'Sets *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        repsCtrl,
                                    label:
                                        'Reps *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        durationCtrl,
                                    label:
                                        'Mins',
                                    enabled:
                                        !saving,
                                    required:
                                        false,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // NOTES
                        // =================================================

                        TextFormField(
                          controller:
                              notesCtrl,
                          enabled: !saving,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Technique Notes',
                            hintText:
                                'Optional notes',
                            isDense: true,
                          ),
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
                            dialogCtx,
                          ).pop(false);
                        },
                  child:
                      const Text('Cancel'),
                ),

                AppButton(
                  loading: saving,
                  label: 'Assign Plan',
                  onPressed: () async {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    final sets =
                        int.tryParse(
                      setsCtrl.text.trim(),
                    );

                    final reps =
                        int.tryParse(
                      repsCtrl.text.trim(),
                    );

                    final durationText =
                        durationCtrl.text.trim();

                    final duration =
                        durationText.isEmpty
                            ? null
                            : int.tryParse(
                                durationText,
                              );

                    if (sets == null ||
                        sets <= 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid sets.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (reps == null ||
                        reps <= 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid reps.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (durationText.isNotEmpty &&
                        (duration == null ||
                            duration < 0)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid duration.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (selectedMemberId ==
                        null) {
                      return;
                    }

                    if (selectedExerciseId ==
                        null) {
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
                        'member_id':
                            selectedMemberId,
                        'plan_name':
                            planNameCtrl.text
                                .trim(),
                        'exercise_id':
                            selectedExerciseId,
                        'workout_day':
                            selectedDay,
                        'sets': sets,
                        'reps': reps,
                        'duration_minutes':
                            duration,
                        'notes':
                            notesCtrl.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : notesCtrl.text
                                    .trim(),
                      };

                      await api.post(
                        '/api/trainer/workout-plans',
                        body: body,
                      );

                      if (!dialogCtx.mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogCtx,
                      ).pop(true);
                    } on ApiException catch (e) {
                      if (!dialogCtx.mounted) {
                        return;
                      }

                      setDialogState(() {
                        saving = false;
                      });

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                              Text(e.message),
                        ),
                      );
                    } catch (_) {
                      if (!dialogCtx.mounted) {
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
                            'Failed to create workout plan.',
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

    // =======================================================
    // REFRESH AFTER DIALOG CLOSES
    // =======================================================

    if (saved == true && mounted) {
      await _loadAll();
    }

    planNameCtrl.dispose();
    setsCtrl.dispose();
    repsCtrl.dispose();
    durationCtrl.dispose();
    notesCtrl.dispose();
  }

  // =========================================================
  // NUMBER FIELD
  // =========================================================

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required bool required,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      validator: required
          ? (value) => Validators.positiveNumber(
                value,
                label: label.replaceAll('*', '').trim(),
              )
          : (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return null;
              }

              final number =
                  int.tryParse(value.trim());

              if (number == null ||
                  number < 0) {
                return 'Enter a valid number';
              }

              return null;
            },
    );
  }

  // =========================================================
  // ADD EXERCISE TO EXISTING PLAN
  // =========================================================

  Future<void> _openAddExerciseDialog(
    num planId,
  ) async {
    if (_exercises.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active exercises are available.',
          ),
        ),
      );

      return;
    }

    num? selectedExerciseId =
        asNum(_exercises.first['id']);

    String selectedDay =
        _workoutDays.first;

    final setsCtrl =
        TextEditingController(text: '3');

    final repsCtrl =
        TextEditingController(text: '12');

    final durationCtrl =
        TextEditingController(text: '10');

    final notesCtrl =
        TextEditingController();

    final formKey =
        GlobalKey<FormState>();

    final bool? saved =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
            dialogCtx,
            setDialogState,
          ) {
            final width =
                MediaQuery.of(dialogCtx).size.width;

            return AlertDialog(
              title:
                  const Text('Add Exercise'),

              content: SizedBox(
                width:
                    width < 600
                        ? width * 0.90
                        : 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        // =================================================
                        // EXERCISE
                        // =================================================

                        DropdownButtonFormField<num>(
                          value:
                              selectedExerciseId,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Exercise *',
                            isDense: true,
                          ),
                          items:
                              _exercises.map(
                            (exercise) {
                              final id =
                                  asNum(
                                exercise['id'],
                              );

                              final name =
                                  asString(
                                exercise['name'],
                                'Exercise',
                              );

                              return DropdownMenuItem<num>(
                                value: id,
                                child: Text(
                                  name,
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
                                  setDialogState(() {
                                    selectedExerciseId =
                                        value;
                                  });
                                },
                          validator: (_) {
                            if (selectedExerciseId ==
                                null) {
                              return 'Please select an exercise';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // DAY
                        // =================================================

                        DropdownButtonFormField<String>(
                          value: selectedDay,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Workout Day *',
                            isDense: true,
                          ),
                          items:
                              _workoutDays.map(
                            (day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            },
                          ).toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedDay =
                                        value ??
                                            _workoutDays
                                                .first;
                                  });
                                },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // SETS / REPS / DURATION
                        // =================================================

                        LayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            final small =
                                constraints.maxWidth <
                                    400;

                            if (small) {
                              return Column(
                                children: [
                                  _numberField(
                                    controller:
                                        setsCtrl,
                                    label:
                                        'Sets *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  _numberField(
                                    controller:
                                        repsCtrl,
                                    label:
                                        'Reps *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  _numberField(
                                    controller:
                                        durationCtrl,
                                    label:
                                        'Minutes',
                                    enabled:
                                        !saving,
                                    required:
                                        false,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        setsCtrl,
                                    label:
                                        'Sets *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        repsCtrl,
                                    label:
                                        'Reps *',
                                    enabled:
                                        !saving,
                                    required:
                                        true,
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child:
                                      _numberField(
                                    controller:
                                        durationCtrl,
                                    label:
                                        'Mins',
                                    enabled:
                                        !saving,
                                    required:
                                        false,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // NOTES
                        // =================================================

                        TextFormField(
                          controller:
                              notesCtrl,
                          enabled: !saving,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Notes',
                            isDense: true,
                          ),
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
                            dialogCtx,
                          ).pop(false);
                        },
                  child:
                      const Text('Cancel'),
                ),

                AppButton(
                  loading: saving,
                  label: 'Add Exercise',
                  onPressed: () async {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    final sets =
                        int.tryParse(
                      setsCtrl.text.trim(),
                    );

                    final reps =
                        int.tryParse(
                      repsCtrl.text.trim(),
                    );

                    final durationText =
                        durationCtrl.text.trim();

                    final duration =
                        durationText.isEmpty
                            ? null
                            : int.tryParse(
                                durationText,
                              );

                    if (sets == null ||
                        sets <= 0) {
                      return;
                    }

                    if (reps == null ||
                        reps <= 0) {
                      return;
                    }

                    if (durationText.isNotEmpty &&
                        (duration == null ||
                            duration < 0)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid duration.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (selectedExerciseId ==
                        null) {
                      return;
                    }

                    setDialogState(() {
                      saving = true;
                    });

                    try {
                      final api =
                          context.read<ApiService>();

                      await api.post(
                        '/api/trainer/workout-plans/$planId/exercises',
                        body: {
                          'exercise_id':
                              selectedExerciseId,
                          'workout_day':
                              selectedDay,
                          'sets': sets,
                          'reps': reps,
                          'duration_minutes':
                              duration,
                          'notes':
                              notesCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : notesCtrl.text
                                      .trim(),
                        },
                      );

                      if (!dialogCtx.mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogCtx,
                      ).pop(true);
                    } on ApiException catch (e) {
                      if (!dialogCtx.mounted) {
                        return;
                      }

                      setDialogState(() {
                        saving = false;
                      });

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                              Text(e.message),
                        ),
                      );
                    } catch (_) {
                      if (!dialogCtx.mounted) {
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
                            'Failed to add exercise.',
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

    if (saved == true && mounted) {
      await _loadAll();
    }

    setsCtrl.dispose();
    repsCtrl.dispose();
    durationCtrl.dispose();
    notesCtrl.dispose();
  }

  // =========================================================
  // DELETE PLAN
  // =========================================================

  Future<void> _deletePlan(
    num planId,
  ) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Workout Plan'),
          content:
              const Text(
            'Are you sure you want to permanently delete this workout plan?',
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

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      final api =
          context.read<ApiService>();

      await api.delete(
        '/api/trainer/workout-plans/$planId',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Workout plan deleted successfully.',
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete workout plan.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // PLAN CARD
  // =========================================================

  Widget _buildPlanCard(
    BuildContext context,
    Map<String, dynamic> plan,
  ) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final planId =
        asNum(plan['id']);

    final planName =
        asString(
      plan['plan_name'],
      'Workout Routine',
    );

    final memberName =
        asString(
      plan['member_name'],
      'Member',
    );

    final memberEmail =
        asString(
      plan['member_email'],
      '',
    );

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final small =
                constraints.maxWidth < 600;

            if (small) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            scheme.primary
                                .withOpacity(0.10),
                        child: Icon(
                          Icons
                              .fitness_center,
                          color:
                              scheme.primary,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Text(
                          planName,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Member: $memberName',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  if (memberEmail.isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      memberEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme
                            .textTheme
                            .bodySmall
                            ?.color,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 12,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openAddExerciseDialog(
                          planId,
                        ),
                        icon: const Icon(
                          Icons.playlist_add,
                        ),
                        label:
                            const Text(
                          'Add Exercise',
                        ),
                      ),

                      IconButton(
                        tooltip:
                            'Delete Plan',
                        icon: Icon(
                          Icons
                              .delete_outline,
                          color:
                              scheme.error,
                        ),
                        onPressed: () =>
                            _deletePlan(
                          planId,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      scheme.primary
                          .withOpacity(0.10),
                  child: Icon(
                    Icons.fitness_center,
                    color:
                        scheme.primary,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Member: $memberName',
                      ),

                      if (memberEmail
                          .isNotEmpty)
                        Text(
                          memberEmail,
                          style:
                              TextStyle(
                            fontSize: 12,
                            color: theme
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                OutlinedButton.icon(
                  onPressed: () =>
                      _openAddExerciseDialog(
                    planId,
                  ),
                  icon: const Icon(
                    Icons.playlist_add,
                  ),
                  label:
                      const Text(
                    'Add Exercise',
                  ),
                ),

                IconButton(
                  tooltip:
                      'Delete Plan',
                  icon: Icon(
                    Icons.delete_outline,
                    color:
                        scheme.error,
                  ),
                  onPressed: () =>
                      _deletePlan(
                    planId,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons
                  .fitness_center_outlined,
              size: 52,
              color:
                  theme.colorScheme.primary,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'No workout plans yet.',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Your assigned workout plans will appear here.',
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 16,
            ),

            OutlinedButton.icon(
              onPressed:
                  _openCreatePlanDialog,
              icon: const Icon(
                Icons.add,
              ),
              label:
                  const Text(
                'Create First Plan',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

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
      onRefresh: _loadAll,
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
                // =======================================================
                // HEADER
                // =======================================================

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final small =
                        constraints.maxWidth <
                            700;

                    if (small) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout Plans Management',
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
                            'Create and manage customized training schedules for your assigned members.',
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton
                                    .icon(
                              onPressed:
                                  _openCreatePlanDialog,
                              icon:
                                  const Icon(
                                Icons.add,
                              ),
                              label:
                                  const Text(
                                'Assign Plan',
                              ),
                            ),
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
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Workout Plans Management',
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
                                'Create and manage customized training schedules for your assigned members.',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        ElevatedButton.icon(
                          onPressed:
                              _openCreatePlanDialog,
                          icon:
                              const Icon(
                            Icons.add,
                          ),
                          label:
                              const Text(
                            'Assign Plan',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // =======================================================
                // ERROR
                // =======================================================

                if (_error != null) ...[
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                theme
                                    .colorScheme
                                    .error,
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
                                  _error!,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                OutlinedButton.icon(
                                  onPressed:
                                      _loadAll,
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
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),
                ],

                // =======================================================
                // LOADING
                // =======================================================

                if (_loading)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 30,
                    ),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),

                // =======================================================
                // EMPTY
                // =======================================================

                if (!_loading &&
                    _error == null &&
                    _plans.isEmpty)
                  _buildEmptyState(context),

                // =======================================================
                // PLAN LIST
                // =======================================================

                if (!_loading &&
                    _error == null &&
                    _plans.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _plans.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
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