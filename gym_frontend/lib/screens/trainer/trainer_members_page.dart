import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerMembersPage extends StatefulWidget {
  const TrainerMembersPage({super.key});

  @override
  State<TrainerMembersPage> createState() => _TrainerMembersPageState();
}

class _TrainerMembersPageState extends State<TrainerMembersPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchAssignedMembers();
      }
    });
  }

  // ============================================================
  // FETCH ASSIGNED MEMBERS
  // ============================================================

  Future<void> _fetchAssignedMembers() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/trainer/assigned-members');
      
      if (!mounted) return;

      List<dynamic> list = [];
      if (res is Map && res['members'] is List) {
        list = res['members'] as List;
      } else if (res is List) {
        list = res;
      }

      setState(() {
        _members = asMapList(list);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load assigned members list.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ============================================================
  // SHOW MEMBER DETAIL DIALOG (ALIGNED & POLISHED)
  // ============================================================

  Future<void> _showMemberDetail(num memberId) async {
    final api = context.read<ApiService>();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;

        return FutureBuilder<dynamic>(
          future: api.get('/api/trainer/assigned-members/$memberId'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return AlertDialog(
                title: const Text('Member Profile'),
                content: const Text('Failed to load member profile details.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            final data = snapshot.data is Map
                ? Map<String, dynamic>.from(snapshot.data as Map)
                : <String, dynamic>{};
            
            final m = data['member'] is Map
                ? Map<String, dynamic>.from(data['member'] as Map)
                : data;

            final name = asString(m['name'], 'Trainee');
            final email = asString(m['email']);
            final phone = asString(m['phone']);
            final goal = asString(m['fitness_goal']);
            final age = asNum(m['age']);
            final height = asNum(m['height']);
            final weight = asNum(m['weight']);
            final medical = asString(m['medical_notes']);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '$name Profile',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header User Info Row with proper wrapping
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: scheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'M',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                if (phone.isNotEmpty)
                                  Text(
                                    phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      
                      // Fitness Goal Section
                      Text(
                        'Fitness Goal',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.isNotEmpty ? goal : 'General conditioning',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Metrics Row (Age, Height, Weight)
                      Row(
                        children: [
                          Expanded(
                            child: _MetricBox(
                              label: 'Age',
                              value: age > 0 ? '$age yrs' : 'N/A',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricBox(
                              label: 'Height',
                              value: height > 0 ? '$height cm' : 'N/A',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricBox(
                              label: 'Weight',
                              value: weight > 0 ? '$weight kg' : 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Medical Notes Section
                      Text(
                        'Medical Notes',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medical.isNotEmpty
                            ? medical
                            : 'No recorded medical issues or injuries.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchAssignedMembers,
      isEmpty: _members.isEmpty,
      emptyMessage: 'No members are currently assigned to your coaching roster.',
      child: RefreshIndicator(
        onRefresh: _fetchAssignedMembers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Members',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Manage trainees assigned to you by gym administration.',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchAssignedMembers,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Members List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final m = _members[idx];
                      final id = asNum(m['id']);
                      final name = asString(m['name'], 'Member');
                      final email = asString(m['email']);
                      final phone = asString(m['phone']);
                      final goal = asString(m['fitness_goal']);
                      final status = asString(m['status'], 'ACTIVE');

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  scheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: scheme.primary),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: status,
                                  positive: status == 'ACTIVE',
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$email • $phone',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (goal.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Goal: $goal',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _showMemberDetail(id),
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('View Profile'),
                            ),
                          ),
                        ),
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
// HELPER WIDGET FOR DIALOG METRICS
// ======================================================================

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}