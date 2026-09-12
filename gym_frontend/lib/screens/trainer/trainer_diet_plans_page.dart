import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerDietPlansPage extends StatefulWidget {
  const TrainerDietPlansPage({super.key});

  @override
  State<TrainerDietPlansPage> createState() =>
      _TrainerDietPlansPageState();
}

class _TrainerDietPlansPageState
    extends State<TrainerDietPlansPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _dietPlans = [];
  List<Map<String, dynamic>> _members = [];

  static const List<String> _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  // Backend currently supports only these meal types.
  static const List<String> _mealTypes = [
    'BREAKFAST',
    'LUNCH',
    'DINNER',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAll();
      }
    });
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadAll() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();

    try {
      final results = await Future.wait<dynamic>([
        api.get('/api/trainer/diet-plans'),
        api.get('/api/trainer/assigned-members'),
      ]);

      if (!mounted) return;

      // ----------------------------------------------------------
      // DIET PLANS
      // ----------------------------------------------------------

      final dietResponse = results[0];

      List<dynamic> dietList = [];

      if (dietResponse is Map) {
        final map = Map<String, dynamic>.from(dietResponse);

        if (map['diet_plans'] is List) {
          dietList = map['diet_plans'] as List;
        } else if (map['data'] is List) {
          dietList = map['data'] as List;
        }
      } else if (dietResponse is List) {
        dietList = dietResponse;
      }

      // ----------------------------------------------------------
      // MEMBERS
      // ----------------------------------------------------------

      final memberResponse = results[1];

      List<dynamic> memberList = [];

      if (memberResponse is Map) {
        final map = Map<String, dynamic>.from(memberResponse);

        if (map['members'] is List) {
          memberList = map['members'] as List;
        } else if (map['data'] is List) {
          memberList = map['data'] as List;
        }
      } else if (memberResponse is List) {
        memberList = memberResponse;
      }

      setState(() {
        _dietPlans = asMapList(dietList);
        _members = asMapList(memberList);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load trainer diet plans.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // OPEN CREATE / EDIT DIALOG
  // ============================================================

  Future<void> _openDietDialog([
    Map<String, dynamic>? item,
  ]) async {
    if (!mounted) return;

    final bool isEditing = item != null;

    // ----------------------------------------------------------
    // CREATE REQUIRES ASSIGNED MEMBER
    // ----------------------------------------------------------

    if (!isEditing && _members.isEmpty) {
      _showMessage(
        'No assigned members available to receive diet targets.',
        error: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // SELECTED MEMBER
    // ----------------------------------------------------------

    num? selectedMemberId;

    if (isEditing) {
      selectedMemberId = asNum(item?['member_id']);
    } else {
      final firstId = _members.first['id'];

      if (firstId is num) {
        selectedMemberId = firstId;
      } else {
        selectedMemberId = num.tryParse('$firstId');
      }
    }

    // ----------------------------------------------------------
    // SELECTED DAY
    // ----------------------------------------------------------

    String selectedDay = _days.first;

    if (isEditing) {
      final existingDay = asString(item?['diet_day']);

      if (_days.contains(existingDay)) {
        selectedDay = existingDay;
      }
    }

    // ----------------------------------------------------------
    // SELECTED MEAL
    // ----------------------------------------------------------

    String selectedMeal = _mealTypes.first;

    if (isEditing) {
      final existingMeal = asString(item?['meal_type']);

      if (_mealTypes.contains(existingMeal)) {
        selectedMeal = existingMeal;
      }
    }

    // ----------------------------------------------------------
    // CONTROLLERS
    // ----------------------------------------------------------

    final foodController = TextEditingController(
      text: isEditing
          ? asString(item?['food_name'])
          : '',
    );

    final caloriesController = TextEditingController(
      text: isEditing
          ? asString(item?['calories'])
          : '350',
    );

    final proteinController = TextEditingController(
      text: isEditing
          ? asString(item?['protein'])
          : '25',
    );

    final notesController = TextEditingController(
      text: isEditing
          ? asString(item?['notes'])
          : '',
    );

    final formKey = GlobalKey<FormState>();

    bool savedSuccessfully = false;

    // ==========================================================
    // DIALOG
    // ==========================================================

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final scheme =
                Theme.of(context).colorScheme;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing
                        ? Icons.edit_outlined
                        : Icons.restaurant_outlined,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Edit Diet Plan'
                          : 'Assign Diet Plan',
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ------------------------------------------------
                        // ERROR
                        // ------------------------------------------------

                        if (dialogError != null) ...[
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 20,
                                  color:
                                      scheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dialogError!,
                                    style: TextStyle(
                                      color:
                                          scheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ------------------------------------------------
                        // MEMBER
                        // ------------------------------------------------

                        if (!isEditing) ...[
                          DropdownButtonFormField<num>(
                            initialValue:
                                selectedMemberId,
                            isExpanded: true,
                            decoration:
                                const InputDecoration(
                              labelText: 'Trainee *',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                            items: _members.map((member) {
                              final rawId =
                                  member['id'];

                              final id = rawId is num
                                  ? rawId
                                  : num.tryParse(
                                      '$rawId',
                                    );

                              return DropdownMenuItem<num>(
                                value: id,
                                child: Text(
                                  asString(
                                    member['name'],
                                    'Trainee',
                                  ),
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
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a trainee';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ------------------------------------------------
                        // DAY
                        // ------------------------------------------------

                        DropdownButtonFormField<String>(
                          initialValue: selectedDay,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText: 'Day of Week *',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          items: _days.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(
                                _formatEnum(day),
                              ),
                            );
                          }).toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedDay =
                                        value ??
                                            _days.first;
                                  });
                                },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please select a day';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ------------------------------------------------
                        // MEAL
                        // ------------------------------------------------

                        DropdownButtonFormField<String>(
                          initialValue: selectedMeal,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(
                            labelText: 'Meal Timing *',
                            prefixIcon: Icon(
                              Icons.restaurant_outlined,
                            ),
                          ),
                          items: _mealTypes.map((meal) {
                            return DropdownMenuItem<String>(
                              value: meal,
                              child: Text(
                                _formatEnum(meal),
                              ),
                            );
                          }).toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedMeal =
                                        value ??
                                            _mealTypes.first;
                                  });
                                },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please select a meal timing';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ------------------------------------------------
                        // FOOD
                        // ------------------------------------------------

                        TextFormField(
                          controller: foodController,
                          enabled: !saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Food / Meal Item *',
                            prefixIcon: Icon(
                              Icons.fastfood_outlined,
                            ),
                          ),
                          validator: (value) {
                            return Validators.requiredField(
                              value,
                              label: 'Food item',
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ------------------------------------------------
                        // CALORIES + PROTEIN
                        // ------------------------------------------------

                        LayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            final isSmall =
                                constraints.maxWidth <
                                    380;

                            final caloriesField =
                                TextFormField(
                              controller:
                                  caloriesController,
                              enabled: !saving,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: false,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Calories (kcal) *',
                                prefixIcon: Icon(
                                  Icons
                                      .local_fire_department_outlined,
                                ),
                              ),
                              validator: (value) {
                                return Validators
                                    .positiveNumber(
                                  value,
                                  label: 'Calories',
                                );
                              },
                            );

                            final proteinField =
                                TextFormField(
                              controller:
                                  proteinController,
                              enabled: !saving,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: false,
                              ),
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Protein (g) *',
                                prefixIcon: Icon(
                                  Icons
                                      .fitness_center_outlined,
                                ),
                              ),
                              validator: (value) {
                                return Validators
                                    .positiveNumber(
                                  value,
                                  label: 'Protein',
                                );
                              },
                            );

                            if (isSmall) {
                              return Column(
                                children: [
                                  caloriesField,
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  proteinField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child:
                                      caloriesField,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child:
                                      proteinField,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // ------------------------------------------------
                        // NOTES
                        // ------------------------------------------------

                        TextFormField(
                          controller: notesController,
                          enabled: !saving,
                          minLines: 2,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Dietary Notes (Optional)',
                            prefixIcon: Icon(
                              Icons.notes_outlined,
                            ),
                            alignLabelWithHint: true,
                          ),
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

                AppButton(
                  label: isEditing
                      ? 'Update Plan'
                      : 'Assign Diet',
                  icon: isEditing
                      ? Icons.save_outlined
                      : Icons.add,
                  loading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          // ------------------------------------------
                          // VALIDATE
                          // ------------------------------------------

                          if (!formKey
                              .currentState!
                              .validate()) {
                            return;
                          }

                          if (!isEditing &&
                              selectedMemberId ==
                                  null) {
                            setDialogState(() {
                              dialogError =
                                  'Please select a trainee.';
                            });
                            return;
                          }

                          // ------------------------------------------
                          // PARSE NUMBERS
                          // ------------------------------------------

                         final calories = num.tryParse(
                            caloriesController.text.trim(),
                          );

                          final protein = num.tryParse(
                            proteinController.text.trim(),
                          );

                          if (calories == null || protein == null) {
                            setDialogState(() {
                              saving = false;
                              dialogError =
                                  'Calories and protein must be valid numbers.';
                            });
                            return;
                          }
                          // ------------------------------------------
                          // START SAVING
                          // ------------------------------------------

                          setDialogState(() {
                            saving = true;
                            dialogError = null;
                          });

                          try {
                            final api =
                                context.read<
                                    ApiService>();

                            final body =
                                <String, dynamic>{
                              if (!isEditing)
                                'member_id':
                                    selectedMemberId,

                              'diet_day':
                                  selectedDay,

                              'meal_type':
                                  selectedMeal,

                              'food_name':
                                  foodController
                                      .text
                                      .trim(),

                              'calories':
                                  calories,

                              'protein':
                                  protein,

                              'notes':
                                  notesController
                                      .text
                                      .trim(),
                            };

                            // ----------------------------------------
                            // CREATE
                            // ----------------------------------------

                            if (!isEditing) {
                              await api.post(
                                '/api/trainer/diet-plans',
                                body: body,
                              );
                            }

                            // ----------------------------------------
                            // UPDATE
                            // ----------------------------------------

                            else {
                              await api.put(
                                '/api/trainer/diet-plans/${item['id']}',
                                body: body,
                              );
                            }

                            savedSuccessfully = true;

                            // Close dialog first.
                            if (dialogContext
                                .mounted) {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            }
                          } on ApiException catch (
                            e) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                              dialogError =
                                  e.message;
                            });
                          } catch (_) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                              dialogError =
                                  'Failed to save diet plan.';
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );

    // ==========================================================
    // DISPOSE CONTROLLERS
    // ==========================================================

    foodController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    notesController.dispose();

    // ==========================================================
    // REFRESH AFTER DIALOG CLOSE
    // ==========================================================

    if (savedSuccessfully && mounted) {
      _showMessage(
        isEditing
            ? 'Diet plan updated successfully.'
            : 'Diet plan assigned successfully.',
      );

      await _loadAll();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteDiet(num id) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme =
            Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text(
            'Delete Diet Plan',
          ),
          content: const Text(
            'Are you sure you want to remove this diet plan?',
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
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor:
                    scheme.onError,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final api =
          context.read<ApiService>();

      await api.delete(
        '/api/trainer/diet-plans/$id',
      );

      if (!mounted) return;

      _showMessage(
        'Diet plan deleted successfully.',
      );

      await _loadAll();
    } on ApiException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message,
        error: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete diet plan.',
        error: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    final scheme =
        Theme.of(context).colorScheme;

    final messenger =
        ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error ? scheme.error : null,
        ),
      );
  }

  // ============================================================
  // FORMAT ENUM
  // ============================================================

  String _formatEnum(String value) {
    return value
        .toLowerCase()
        .split('_')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return word[0].toUpperCase() +
              word.substring(1);
        })
        .join(' ');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final padding =
        Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _loadAll,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _loadAll,
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
                  _PageHeader(
                    onAssign:
                        () => _openDietDialog(),
                  ),

                  const SizedBox(height: 22),

                  _SummaryRow(
                    totalPlans:
                        _dietPlans.length,
                    assignedMembers:
                        _members.length,
                  ),

                  const SizedBox(height: 22),

                  if (_dietPlans.isEmpty)
                    _EmptyDietState(
                      onAssign:
                          _members.isEmpty
                              ? null
                              : () =>
                                  _openDietDialog(),
                    )
                  else
                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final columns =
                            Responsive.gridCount(
                          context,
                          mobile: 1,
                          tablet: 2,
                          desktop: 2,
                        );

                        /*
                         * IMPORTANT FIX:
                         *
                         * The previous card height was:
                         * mobile = 230
                         * desktop = 215
                         *
                         * That was too small when notes/actions
                         * were present and caused:
                         *
                         * BOTTOM OVERFLOWED BY 9 PIXELS
                         *
                         * We now give the card enough vertical
                         * space.
                         */

                        final cardHeight =
                            Responsive.isMobile(
                              context,
                            )
                                ? 285.0
                                : 250.0;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              _dietPlans.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                columns,
                            crossAxisSpacing:
                                14,
                            mainAxisSpacing:
                                14,
                            mainAxisExtent:
                                cardHeight,
                          ),
                          itemBuilder:
                              (context, index) {
                            final diet =
                                _dietPlans[index];

                            final id =
                                asNum(
                              diet['id'],
                            );

                            return _DietPlanCard(
                              item: diet,
                              onEdit: () =>
                                  _openDietDialog(
                                diet,
                              ),
                              onDelete: () =>
                                  _deleteDiet(id),
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
}

// ======================================================================
// PAGE HEADER
// ======================================================================

class _PageHeader
    extends StatelessWidget {
  const _PageHeader({
    required this.onAssign,
  });

  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final isMobile =
        Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Diet & Nutrition Plans',
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
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
            'Prescribe macro goals and nutritious meals to assigned trainees.',
            maxLines: 3,
            overflow:
                TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Assign Diet',
              icon: Icons.add,
              onPressed: onAssign,
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
                CrossAxisAlignment.start,
            children: [
              Text(
                'Diet & Nutrition Plans',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
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
                'Prescribe macro goals and nutritious meals to assigned trainees.',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        SizedBox(
          width: 145,
          child: AppButton(
            label: 'Assign Diet',
            icon: Icons.add,
            onPressed: onAssign,
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// SUMMARY
// ======================================================================

class _SummaryRow
    extends StatelessWidget {
  const _SummaryRow({
    required this.totalPlans,
    required this.assignedMembers,
  });

  final int totalPlans;
  final int assignedMembers;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryChip(
          icon:
              Icons.restaurant_menu_outlined,
          label:
              '$totalPlans Diet Plans',
          color:
              scheme.primary,
        ),
        _SummaryChip(
          icon:
              Icons.groups_outlined,
          label:
              '$assignedMembers Assigned Trainees',
          color:
              scheme.secondary,
        ),
      ],
    );
  }
}

// ======================================================================
// SUMMARY CHIP
// ======================================================================

class _SummaryChip
    extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color:
                  scheme.onSurface,
              fontWeight:
                  FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// EMPTY STATE
// ======================================================================

class _EmptyDietState
    extends StatelessWidget {
  const _EmptyDietState({
    required this.onAssign,
  });

  final VoidCallback? onAssign;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    BoxDecoration(
                  color:
                      scheme.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .restaurant_menu_outlined,
                  color:
                      scheme.primary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'No diet plans registered yet.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Assign a meal plan to one of your trainees.',
                textAlign:
                    TextAlign.center,
              ),

              if (onAssign != null) ...[
                const SizedBox(height: 16),
                AppButton(
                  label:
                      'Assign Diet',
                  icon: Icons.add,
                  onPressed:
                      onAssign,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// DIET PLAN CARD
// ======================================================================

class _DietPlanCard
    extends StatelessWidget {
  const _DietPlanCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final scheme =
        theme.colorScheme;

    final memberName =
        asString(
      item['member_name'],
      'Trainee',
    );

    final day =
        asString(
      item['diet_day'],
      'MONDAY',
    );

    final meal =
        asString(
      item['meal_type'],
      'BREAKFAST',
    );

    final food =
        asString(
      item['food_name'],
      'Meal',
    );

    final calories =
        asNum(
      item['calories'],
    );

    final protein =
        asNum(
      item['protein'],
    );

    final notes =
        asString(
      item['notes'],
    );

    return Card(
      clipBehavior:
          Clip.antiAlias,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
        side: BorderSide(
          color:
              scheme.outlineVariant
                  .withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        scheme.primary
                            .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    Icons.restaurant_outlined,
                    color:
                        scheme.primary,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.isNotEmpty
                            ? food
                            : 'Meal',
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

                      const SizedBox(height: 3),

                      Text(
                        _formatEnum(meal),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                              scheme.secondary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: StatusBadge(
                    label:
                        _formatEnum(day),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(
              height: 1,
              color:
                  scheme.outlineVariant
                      .withValues(
                alpha: 0.35,
              ),
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // TRAINEE
            // ==========================================================

            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 17,
                  color:
                      scheme.primary,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    memberName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==========================================================
            // MACROS
            // ==========================================================

            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                _InfoChip(
                  icon: Icons
                      .local_fire_department_outlined,
                  text:
                      '$calories kcal',
                ),
                _InfoChip(
                  icon: Icons
                      .fitness_center_outlined,
                  text:
                      '$protein g protein',
                ),
              ],
            ),

            // ==========================================================
            // NOTES
            // ==========================================================

            if (notes.isNotEmpty) ...[
              const SizedBox(height: 9),

              Text(
                notes,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  fontStyle:
                      FontStyle.italic,
                ),
              ),
            ],

            const Spacer(),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        onEdit,
                    icon: const Icon(
                      Icons
                          .edit_outlined,
                      size: 17,
                    ),
                    label:
                        const Text(
                      'Edit',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip:
                      'Delete',
                  onPressed:
                      onDelete,
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
                    size: 21,
                  ),
                  color:
                      scheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatEnum(
    String value,
  ) {
    return value
        .toLowerCase()
        .split('_')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return word[0].toUpperCase() +
              word.substring(1);
        })
        .join(' ');
  }
}

// ======================================================================
// INFO CHIP
// ======================================================================

class _InfoChip
    extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            scheme
                .surfaceContainerHighest
                .withValues(
          alpha: 0.55,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color:
                scheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}