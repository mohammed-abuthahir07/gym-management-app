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
    _fetchAssignedMembers();
  }

  Future<void> _fetchAssignedMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/trainer/assigned-members');
      List<dynamic> list = [];
      if (res is Map && res['members'] is List) {
        list = res['members'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _members = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load assigned members list.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showMemberDetail(num memberId) async {
    final api = context.read<ApiService>();
    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
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
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              );
            }

            final data = snapshot.data as Map<String, dynamic>;
            final m = data['member'] is Map ? data['member'] as Map : data;

            final name = asString(m['name'], 'Trainee');
            final email = asString(m['email']);
            final phone = asString(m['phone']);
            final goal = asString(m['fitness_goal']);
            final age = asNum(m['age']);
            final height = asNum(m['height']);
            final weight = asNum(m['weight']);
            final medical = asString(m['medical_notes']);

            return AlertDialog(
              title: Text('$name Profile'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : 'M')),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$email • $phone'),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Fitness Goal:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(goal.isNotEmpty ? goal : 'General conditioning'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text('Age: ${age > 0 ? age : 'N/A'} yrs')),
                          Expanded(child: Text('Height: ${height > 0 ? height : 'N/A'} cm')),
                          Expanded(child: Text('Weight: ${weight > 0 ? weight : 'N/A'} kg')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Medical Notes:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(medical.isNotEmpty ? medical : 'No recorded medical issues or injuries.'),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

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
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned Members', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Manage trainees assigned to you by gym administration.'),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetchAssignedMembers,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            StatusBadge(label: status, positive: status == 'ACTIVE'),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('$email • $phone'),
                            if (goal.isNotEmpty) Text('Goal: $goal', style: TextStyle(fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _showMemberDetail(id),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('View Profile'),
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
    );
  }
}
