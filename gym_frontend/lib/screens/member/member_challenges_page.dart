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
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/member/challenges',
      );

      List<dynamic> list = [];

      if (response is Map) {
        final challenges = response['challenges'];

        if (challenges is List) {
          list = challenges;
        }
      } else if (response is List) {
        list = response;
      }

      if (!mounted) return;

      setState(() {
        _challenges = asMapList(list);
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load challenges.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatDate(dynamic value) {
    final raw = asString(value);

    if (raw.isEmpty) {
      return 'N/A';
    }

    try {
      final date = DateTime.parse(raw);

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day-$month-$year';
    } catch (_) {
      if (raw.contains('T')) {
        return raw.split('T').first;
      }

      return raw;
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
      emptyMessage:
          'No gym challenges currently active. Stay tuned for upcoming competitions!',
      child: RefreshIndicator(
        onRefresh: _fetchChallenges,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    theme,
                  ),

                  const SizedBox(height: 24),

                  _buildChallengeList(
                    context,
                    scheme,
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

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Challenges',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Push your limits, hit milestones, and earn exclusive rewards.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        IconButton(
          tooltip: 'Refresh challenges',
          onPressed: _loading ? null : _fetchChallenges,
          icon: const Icon(
            Icons.refresh,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeList(
    BuildContext context,
    ColorScheme scheme,
  ) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < _challenges.length; index++) ...[
            _buildChallengeCard(
              context,
              _challenges[index],
            ),
            if (index != _challenges.length - 1)
              const SizedBox(height: 16),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _challenges.map((challenge) {
            return SizedBox(
              width: cardWidth,
              child: _buildChallengeCard(
                context,
                challenge,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    Map<String, dynamic> challenge,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final title = asString(
      challenge['title'],
      'Gym Challenge',
    );

    final description = asString(
      challenge['description'],
      'Complete this challenge and reach your fitness milestone.',
    );

    final reward = asString(
      challenge['reward'],
      'PeakForge Badge',
    );

    final startDate = _formatDate(
      challenge['start_date'],
    );

    final endDate = _formatDate(
      challenge['end_date'],
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------------
            // TITLE ROW
            // ------------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.military_tech_outlined,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------------------
            // DURATION
            // ------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenge Duration',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '$startDate  →  $endDate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ------------------------------------------------------------
            // DESCRIPTION
            // ------------------------------------------------------------
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 18),

            Divider(
              height: 1,
              color: scheme.outlineVariant,
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------------
            // REWARD
            // ------------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.card_giftcard_outlined,
                  size: 19,
                  color: scheme.primary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reward',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        reward,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}