import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberExercisesPage extends StatefulWidget {
  const MemberExercisesPage({super.key});

  @override
  State<MemberExercisesPage> createState() => _MemberExercisesPageState();
}

class _MemberExercisesPageState extends State<MemberExercisesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _exercises = [];
  String _searchQuery = '';
  String _selectedMuscle = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/exercises');
      List<dynamic> list = [];
      if (res is Map && res['exercises'] is List) {
        list = res['exercises'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _exercises = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load exercises library.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredExercises {
    return _exercises.where((ex) {
      final name = asString(ex['name']).toLowerCase();
      final muscle = asString(ex['muscle_group']).toLowerCase();
      final equipment = asString(ex['equipment']).toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty || name.contains(q) || muscle.contains(q) || equipment.contains(q);
      final matchesMuscle = _selectedMuscle == 'ALL' || muscle == _selectedMuscle.toLowerCase();
      return matchesQuery && matchesMuscle;
    }).toList();
  }

  Set<String> get _muscleGroups {
    final groups = <String>{'ALL'};
    for (final ex in _exercises) {
      final m = asString(ex['muscle_group']);
      if (m.isNotEmpty) groups.add(m.toUpperCase());
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);
    final filtered = _filteredExercises;

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchExercises,
      isEmpty: _exercises.isEmpty,
      emptyMessage: 'Exercise library is currently empty.',
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text('Exercise Library', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Explore proper techniques, targeting muscle groups and equipment.'),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetchExercises,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search & Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by exercise name, muscle, equipment...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Muscle Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _muscleGroups.map((group) {
                      final selected = _selectedMuscle == group;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(group),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedMuscle = group),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No exercises match your search filters.')),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: Responsive.isMobile(context) ? 1.3 : 1.05,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final ex = filtered[idx];
                          final name = asString(ex['name'], 'Exercise');
                          final muscle = asString(ex['muscle_group'], 'General');
                          final equipment = asString(ex['equipment'], 'None');
                          final instructions = asString(ex['instructions']);
                          final difficulty = asString(ex['difficulty'], 'BEGINNER');
                          final rawImg = asString(ex['image_url']);
                          final imgUrl = ApiConfig.fileUrl(rawImg);

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imgUrl.isNotEmpty)
                                  SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: NetworkImageSafe(url: imgUrl, height: 120),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge(label: difficulty),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '$muscle • $equipment',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        instructions.isNotEmpty ? instructions : 'Follow proper form and control breathing.',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}