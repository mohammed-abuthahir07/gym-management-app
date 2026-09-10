import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberChallengesPage extends StatefulWidget {
  const MemberChallengesPage({super.key});

  @override
  State<MemberChallengesPage> createState() => _MemberChallengesPageState();
}

class _MemberChallengesPageState extends State<MemberChallengesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/challenges');
      List<dynamic> list = [];
      if (res is Map && res['challenges'] is List) {
        list = res['challenges'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _challenges = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load challenges.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchChallenges,
      isEmpty: _challenges.isEmpty,
      emptyMessage: 'No gym challenges currently active. Stay tuned for upcoming competitions!',
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
                        Text('Active Challenges', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Push your limits, hit milestones, and earn exclusive rewards.'),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetchChallenges,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 2);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 1.4 : 1.3,
                      ),
                      itemCount: _challenges.length,
                      itemBuilder: (context, idx) {
                        final c = _challenges[idx];
                        final title = asString(c['title'], 'Gym Challenge');
                        final desc = asString(c['description']);
                        final reward = asString(c['reward'], 'PeakForge Badge');
                        final start = asString(c['start_date']).split('T').first;
                        final end = asString(c['end_date']).split('T').first;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                    Icon(Icons.military_tech, color: scheme.primary, size: 28),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Duration: $start to $end',
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Text(
                                    desc,
                                    style: TextStyle(fontSize: 13, height: 1.4, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9)),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.card_giftcard, size: 18, color: scheme.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Reward: $reward',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: scheme.secondary, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
