import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';

class TrainerCheatDaysPage extends StatefulWidget {
  const TrainerCheatDaysPage({super.key});

  @override
  State<TrainerCheatDaysPage> createState() => _TrainerCheatDaysPageState();
}

class _TrainerCheatDaysPageState extends State<TrainerCheatDaysPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _currentMonth = [];
  List<Map<String, dynamic>> _previousMonth = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _fetchCheatMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ALL MONITORING DATA
  // ============================================================

  Future<void> _fetchCheatMonitoring() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final results = await Future.wait<dynamic>([
        api.get('/api/trainer/cheat-days/members'),
        api.get('/api/trainer/cheat-days/current-month'),
        api.get('/api/trainer/cheat-days/previous-month'),
      ]);

      if (!mounted) return;

      final membersResponse = results[0];
      final currentResponse = results[1];
      final previousResponse = results[2];

      final members = _extractList(
        membersResponse,
        'members',
      );

      final currentMonth = _extractList(
        currentResponse,
        'cheat_days',
      );

      final previousMonth = _extractList(
        previousResponse,
        'cheat_days',
      );

      setState(() {
        _members = members;
        _currentMonth = currentMonth;
        _previousMonth = previousMonth;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load cheat-day monitoring.';
      });
    }
  }

  List<Map<String, dynamic>> _extractList(
    dynamic response,
    String key,
  ) {
    if (response is Map) {
      final value = response[key];

      if (value is List) {
        return asMapList(value);
      }
    }

    return [];
  }

  // ============================================================
  // OPEN MEMBER HISTORY
  // ============================================================

  Future<void> _openMemberHistory(
    int memberId,
    String memberName,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return TrainerMemberCheatHistoryDialog(
          memberId: memberId,
          memberName: memberName,
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

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: scheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _fetchCheatMonitoring,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCheatMonitoring,
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
                _buildHeader(theme),

                const SizedBox(height: 24),

                _buildSummary(),

                const SizedBox(height: 24),

                _buildTabs(),

                const SizedBox(height: 16),

                SizedBox(
                  height: 650,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCurrentMonth(),
                      _buildPreviousMonth(),
                      _buildMembers(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        final title = Text(
          'Cheat Day Monitoring',
          style: (isMobile
                  ? theme.textTheme.headlineSmall
                  : theme.textTheme.headlineMedium)
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );

        final description = Text(
          'Monitor cheat meals logged by your assigned members.',
          style: theme.textTheme.bodyMedium,
        );

        final refreshButton = OutlinedButton.icon(
          onPressed: _loading
              ? null
              : _fetchCheatMonitoring,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              description,
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: refreshButton,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 6),
                  description,
                ],
              ),
            ),
            const SizedBox(width: 20),
            refreshButton,
          ],
        );
      },
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final scheme = Theme.of(context).colorScheme;

    final cards = [
      _SummaryCard(
        icon: Icons.people_outline,
        title: 'Assigned Members',
        value: _members.length.toString(),
        color: scheme.primary,
      ),
      _SummaryCard(
        icon: Icons.calendar_month,
        title: 'Current Month',
        value: _currentMonth.length.toString(),
        color: scheme.secondary,
      ),
      _SummaryCard(
        icon: Icons.history,
        title: 'Previous Month',
        value: _previousMonth.length.toString(),
        color: scheme.tertiary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 10),
              cards[1],
              const SizedBox(height: 10),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Card(
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(
            icon: Icon(Icons.calendar_month),
            text: 'Current Month',
          ),
          Tab(
            icon: Icon(Icons.history),
            text: 'Previous Month',
          ),
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Assigned Members',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT MONTH
  // ============================================================

  Widget _buildCurrentMonth() {
    return _buildCheatList(
      list: _currentMonth,
      emptyMessage: 'No cheat meals logged this month.',
    );
  }

  // ============================================================
  // PREVIOUS MONTH
  // ============================================================

  Widget _buildPreviousMonth() {
    return _buildCheatList(
      list: _previousMonth,
      emptyMessage: 'No cheat meals logged for the previous month.',
    );
  }

  // ============================================================
  // MEMBERS
  // ============================================================

  Widget _buildMembers() {
    if (_members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No active members are assigned to you.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      itemCount: _members.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final member = _members[index];

        final memberId = asNum(
          member['id'],
        ).toInt();

        final name = asString(
          member['name'],
          'Member',
        );

        final email = asString(
          member['email'],
        );

        final phone = asString(
          member['phone'],
        );

        final status = asString(
          member['status'],
          'ACTIVE',
        );

        return _MemberCard(
          memberId: memberId,
          name: name,
          email: email,
          phone: phone,
          status: status,
          onTap: () {
            _openMemberHistory(
              memberId,
              name,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CHEAT LIST
  // ============================================================

  Widget _buildCheatList({
    required List<Map<String, dynamic>> list,
    required String emptyMessage,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      itemCount: list.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return _CheatCard(
          item: list[index],
        );
      },
    );
  }
}

// ============================================================================
// MEMBER CARD
// ============================================================================

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.memberId,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.onTap,
  });

  final int memberId;
  final String name;
  final String email;
  final String phone;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isActive = status.toUpperCase() == 'ACTIVE';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              final avatar = CircleAvatar(
                radius: 24,
                child: Text(
                  _initial(name),
                ),
              );

              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isActive
                              ? scheme.primary
                              : scheme.error)
                          .withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isActive
                            ? scheme.primary
                            : scheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );

              final arrow = Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: scheme.onSurfaceVariant,
              );

              if (isMobile) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(child: details),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: arrow,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 14),
                  Expanded(child: details),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6,
                    ),
                    child: arrow,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _initial(String value) {
    final name = value.trim();

    if (name.isEmpty) {
      return 'M';
    }

    return name.substring(0, 1).toUpperCase();
  }
}

// ============================================================================
// CHEAT CARD
// ============================================================================

class _CheatCard extends StatelessWidget {
  const _CheatCard({
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final memberName = asString(
      item['member_name'],
      'Member',
    );

    final memberEmail = asString(
      item['member_email'],
    );

    final foodName = asString(
      item['food_name'],
      'Cheat Meal',
    );

    final quantity = asString(
      item['quantity'],
    );

    final calories = asNum(
      item['calories'],
    );

    final date = _formatDate(
      item['cheat_date'],
    );

    final notes = asString(
      item['notes'],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _foodIcon(scheme),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          foodName,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _InfoLine(
                    icon: Icons.person_outline,
                    text: memberName,
                  ),

                  if (memberEmail.isNotEmpty)
                    _InfoLine(
                      icon: Icons.email_outlined,
                      text: memberEmail,
                    ),

                  _InfoLine(
                    icon: Icons.calendar_today_outlined,
                    text: date,
                  ),

                  if (quantity.isNotEmpty)
                    _InfoLine(
                      icon: Icons.restaurant_outlined,
                      text: 'Quantity: $quantity',
                    ),

                  _InfoLine(
                    icon: Icons.local_fire_department_outlined,
                    text: '$calories kcal',
                    important: true,
                  ),

                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Note: $notes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _foodIcon(scheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '$memberName — $foodName',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            date,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 14,
                        runSpacing: 7,
                        children: [
                          if (memberEmail.isNotEmpty)
                            Text(
                              memberEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (quantity.isNotEmpty)
                            Text(
                              'Portion: $quantity',
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            '$calories kcal',
                            style: TextStyle(
                              color: scheme.error,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          'Note: $notes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _foodIcon(ColorScheme scheme) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: scheme.error.withValues(
        alpha: 0.10,
      ),
      child: Icon(
        Icons.fastfood,
        color: scheme.error,
      ),
    );
  }

  String _formatDate(dynamic value) {
    final raw = asString(value);

    if (raw.isEmpty) {
      return 'Date unavailable';
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
}

// ============================================================================
// INFO LINE
// ============================================================================

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
    this.important = false,
  });

  final IconData icon;
  final String text;
  final bool important;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: important
                ? scheme.error
                : scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                color: important
                    ? scheme.error
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: important
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUMMARY CARD
// ============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(
                alpha: 0.12,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MEMBER CHEAT HISTORY DIALOG
// ============================================================================

class TrainerMemberCheatHistoryDialog extends StatefulWidget {
  const TrainerMemberCheatHistoryDialog({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  final int memberId;
  final String memberName;

  @override
  State<TrainerMemberCheatHistoryDialog> createState() =>
      _TrainerMemberCheatHistoryDialogState();
}

class _TrainerMemberCheatHistoryDialogState
    extends State<TrainerMemberCheatHistoryDialog> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();

    _fetchHistory();
  }

  // ============================================================
  // FETCH MEMBER HISTORY
  // ============================================================

  Future<void> _fetchHistory() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/cheat-days/members/${widget.memberId}',
      );

      if (!mounted) return;

      final records = _extractRecords(response);

      setState(() {
        _records = records;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to fetch member cheat activities.';
      });
    }
  }

  List<Map<String, dynamic>> _extractRecords(
    dynamic response,
  ) {
    if (response is Map) {
      final value = response['cheat_days'];

      if (value is List) {
        return asMapList(value);
      }
    }

    return [];
  }

  // ============================================================
  // OPEN DETAIL
  // ============================================================

  Future<void> _openDetails(int cheatId) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return TrainerCheatDetailDialog(
          memberId: widget.memberId,
          cheatId: cheatId,
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${widget.memberName} - Cheat History',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        height: 500,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : _fetchHistory,
          child: const Text('Refresh'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return const Center(
        child: Text(
          'This member has no cheat-day records.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _records.length,
      separatorBuilder: (_, __) {
        return const Divider(
          height: 20,
        );
      },
      itemBuilder: (context, index) {
        final item = _records[index];

        final cheatId = asNum(
          item['id'],
        ).toInt();

        final food = asString(
          item['food_name'],
          'Cheat Meal',
        );

        final date = _formatDate(
          item['cheat_date'],
        );

        final quantity = asString(
          item['quantity'],
        );

        final calories = asNum(
          item['calories'],
        );

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            child: Icon(Icons.fastfood),
          ),
          title: Text(
            food,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '$date • $calories kcal'
            '${quantity.isNotEmpty ? ' • $quantity' : ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 15,
          ),
          onTap: () {
            _openDetails(cheatId);
          },
        );
      },
    );
  }

  String _formatDate(dynamic value) {
    final raw = asString(value);

    if (raw.isEmpty) {
      return 'Date unavailable';
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
}

// ============================================================================
// CHEAT DETAIL DIALOG
// ============================================================================

class TrainerCheatDetailDialog extends StatefulWidget {
  const TrainerCheatDetailDialog({
    super.key,
    required this.memberId,
    required this.cheatId,
  });

  final int memberId;
  final int cheatId;

  @override
  State<TrainerCheatDetailDialog> createState() =>
      _TrainerCheatDetailDialogState();
}

class _TrainerCheatDetailDialogState
    extends State<TrainerCheatDetailDialog> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _cheatDay;

  @override
  void initState() {
    super.initState();

    _fetchDetails();
  }

  // ============================================================
  // FETCH DETAIL
  // ============================================================

  Future<void> _fetchDetails() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/cheat-days/members/'
        '${widget.memberId}/${widget.cheatId}',
      );

      if (!mounted) return;

      if (response is Map &&
          response['cheat_day'] is Map) {
        final data = Map<String, dynamic>.from(
          response['cheat_day'] as Map,
        );

        setState(() {
          _cheatDay = data;
          _loading = false;
        });
      } else {
        setState(() {
          _cheatDay = null;
          _loading = false;
          _error = 'Cheat activity not found.';
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to fetch cheat activity.';
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Cheat Activity Details',
      ),
      content: SizedBox(
        width: 500,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : _fetchDetails,
          child: const Text('Refresh'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _fetchDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = _cheatDay;

    if (data == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Cheat activity not found.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final food = asString(
      data['food_name'],
      'Cheat Meal',
    );

    final date = _formatDate(
      data['cheat_date'],
    );

    final quantity = asString(
      data['quantity'],
    );

    final calories = asNum(
      data['calories'],
    );

    final notes = asString(
      data['notes'],
    );

    final createdAt = asString(
      data['created_at'],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 450,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(
              icon: Icons.fastfood,
              label: 'Food',
              value: food,
            ),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: date,
            ),
            _DetailRow(
              icon: Icons.restaurant,
              label: 'Quantity',
              value: quantity.isEmpty
                  ? 'Not provided'
                  : quantity,
            ),
            _DetailRow(
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '$calories kcal',
            ),
            _DetailRow(
              icon: Icons.notes,
              label: 'Notes',
              value: notes.isEmpty
                  ? 'No notes'
                  : notes,
            ),
            if (createdAt.isNotEmpty)
              _DetailRow(
                icon: Icons.access_time,
                label: 'Created',
                value: _formatDateTime(
                  createdAt,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    final raw = asString(value);

    if (raw.isEmpty) {
      return 'Date unavailable';
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

  String _formatDateTime(String value) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    try {
      final date = DateTime.parse(value);

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day-$month-$year $hour:$minute';
    } catch (_) {
      return value
          .replaceFirst('T', ' ')
          .split('.')
          .first;
    }
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}