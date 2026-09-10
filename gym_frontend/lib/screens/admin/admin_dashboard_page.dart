import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  String? _error;

  num _memberCount = 0;
  num _trainerCount = 0;
  num _planCount = 0;
  num _promotionCount = 0;
  num _challengeCount = 0;
  num _monthRevenue = 0;
  num _totalRevenue = 0;

  List<Map<String, dynamic>> _recentPlans = [];
  List<Map<String, dynamic>> _recentPromos = [];
  List<Map<String, dynamic>> _recentChallenges = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/admin/dashboard/member').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/trainer').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/plan').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/promotion').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/challenge').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/current-month-revenue').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/total-revenue').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/recent/plan').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/recent/promotion').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/dashboard/recent/challenge').catchError((_) => <String, dynamic>{}),
      ]);

      final memRes = results[0] is Map ? results[0] as Map : {};
      final trRes = results[1] is Map ? results[1] as Map : {};
      final planRes = results[2] is Map ? results[2] as Map : {};
      final promoRes = results[3] is Map ? results[3] as Map : {};
      final chalRes = results[4] is Map ? results[4] as Map : {};
      final monthRevRes = results[5] is Map ? results[5] as Map : {};
      final totRevRes = results[6] is Map ? results[6] as Map : {};
      final rPlanRes = results[7] is Map ? results[7] as Map : {};
      final rPromoRes = results[8] is Map ? results[8] as Map : {};
      final rChalRes = results[9] is Map ? results[9] as Map : {};

      setState(() {
        _memberCount = asNum(memRes['data']?['total_members'] ?? memRes['total_members']);
        _trainerCount = asNum(trRes['data']?['total_trainers'] ?? trRes['total_trainers']);
        _planCount = asNum(planRes['data']?['total_plans'] ?? planRes['total_plans']);
        _promotionCount = asNum(promoRes['data']?['total_promotions'] ?? promoRes['total_promotions']);
        _challengeCount = asNum(chalRes['data']?['total_challenges'] ?? chalRes['total_challenges']);
        _monthRevenue = asNum(monthRevRes['revenue'] ?? monthRevRes['total_revenue'] ?? monthRevRes['data']);
        _totalRevenue = asNum(totRevRes['revenue'] ?? totRevRes['total_revenue'] ?? totRevRes['data']);

        _recentPlans = asMapList(rPlanRes['data']);
        _recentPromos = asMapList(rPromoRes['data']);
        _recentChallenges = asMapList(rChalRes['data']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load admin dashboard.');
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
      onRetry: _fetchDashboard,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchDashboard,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PeakForge Command Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Real-time overview of members, coaches, revenue, and active programs.'),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Refresh Metrics',
                        onPressed: _fetchDashboard,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Metrics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 2, tablet: 3, desktop: 4);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 1.3 : 1.5,
                        children: [
                          StatCard(title: 'Active Members', value: '$_memberCount', icon: Icons.people_alt_outlined),
                          StatCard(title: 'Coaching Staff', value: '$_trainerCount', icon: Icons.sports_outlined),
                          StatCard(title: 'Tier Plans', value: '$_planCount', icon: Icons.card_membership_outlined),
                          StatCard(title: 'Campaign Offers', value: '$_promotionCount', icon: Icons.local_offer_outlined),
                          StatCard(title: 'Challenges', value: '$_challengeCount', icon: Icons.military_tech_outlined),
                          StatCard(title: 'Month Revenue', value: '₹${_monthRevenue.toStringAsFixed(0)}', icon: Icons.account_balance_wallet_outlined),
                          StatCard(title: 'All-Time Revenue', value: '₹${_totalRevenue.toStringAsFixed(0)}', icon: Icons.savings_outlined),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Recent Plans & Recent Promos
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = Responsive.isMobile(context);
                      return Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recent Plans
                          Expanded(
                            flex: isMobile ? 0 : 1,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.layers_outlined, color: scheme.primary),
                                        const SizedBox(width: 8),
                                        Text('Recent Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_recentPlans.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Text('No plans added yet.'),
                                      )
                                    else
                                      ..._recentPlans.map((p) {
                                        final name = asString(p['name']);
                                        final price = asNum(p['price']);
                                        final dur = asString(p['duration_unit']);
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('$dur plan'),
                                          trailing: Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!isMobile) const SizedBox(width: 16),
                          if (isMobile) const SizedBox(height: 16),
                          // Recent Promos
                          Expanded(
                            flex: isMobile ? 0 : 1,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.discount_outlined, color: scheme.primary),
                                        const SizedBox(width: 8),
                                        Text('Recent Deals & Offers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_recentPromos.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: Text('No promotional offers created.'),
                                      )
                                    else
                                      ..._recentPromos.map((p) {
                                        final title = asString(p['title']);
                                        final code = asString(p['code']);
                                        final discount = asNum(p['discount']);
                                        final type = asString(p['discount_type']);
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text('Code: $code'),
                                          trailing: StatusBadge(
                                            label: type == 'PERCENTAGE' ? '$discount%' : '₹$discount',
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
