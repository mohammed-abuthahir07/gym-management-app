import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  bool _loading = true;
  String? _error;

  num _monthRevenue = 0;
  num _yearRevenue = 0;
  num _totalRevenue = 0;
  num _monthCheckins = 0;
  num _yearCheckins = 0;
  num _monthUnpaid = 0;

  num _joinedMonthMembers = 0;
  num _joinedMonthTrainers = 0;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/admin/report/current-month-revenue').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/report/current-year-revenue').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/report/total-revenue').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/report/current-month-checkins').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/report/current-year-checkins').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/report/current-month-unpaid').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/analytics/member').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/analytics/trainer').catchError((_) => <String, dynamic>{}),
      ]);

      final mRev = results[0] is Map ? results[0] as Map : {};
      final yRev = results[1] is Map ? results[1] as Map : {};
      final tRev = results[2] is Map ? results[2] as Map : {};
      final mChk = results[3] is Map ? results[3] as Map : {};
      final yChk = results[4] is Map ? results[4] as Map : {};
      final mUnp = results[5] is Map ? results[5] as Map : {};
      final memAn = results[6] is Map ? results[6] as Map : {};
      final trAn = results[7] is Map ? results[7] as Map : {};

      setState(() {
        _monthRevenue = asNum(mRev['revenue'] ?? mRev['total_revenue'] ?? mRev['data']);
        _yearRevenue = asNum(yRev['revenue'] ?? yRev['total_revenue'] ?? yRev['data']);
        _totalRevenue = asNum(tRev['revenue'] ?? tRev['total_revenue'] ?? tRev['data']);
        _monthCheckins = asNum(mChk['checkins'] ?? mChk['total_checkins'] ?? mChk['data']?['total_checkins'] ?? mChk['data']);
        _yearCheckins = asNum(yChk['checkins'] ?? yChk['total_checkins'] ?? yChk['data']?['total_checkins'] ?? yChk['data']);
        _monthUnpaid = asNum(mUnp['unpaid'] ?? mUnp['total_unpaid'] ?? mUnp['data']?['total_unpaid'] ?? mUnp['data']);

        _joinedMonthMembers = asNum(memAn['data']?['current_month_joined']);
        _joinedMonthTrainers = asNum(trAn['data']?['current_month_joined']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load business reports.');
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
      onRetry: _fetchReports,
      isEmpty: false,
      emptyMessage: '',
      child: RefreshIndicator(
        onRefresh: _fetchReports,
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
                          Text('Financial & Attendance Reports', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Comprehensive revenue analytics, gym footfall, and monthly dues.'),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _fetchReports,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Financial Cards
                  Text('Revenue Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 1, tablet: 3, desktop: 3);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 2.0 : 1.6,
                        children: [
                          StatCard(
                            title: 'Current Month Revenue',
                            value: '₹${_monthRevenue.toStringAsFixed(0)}',
                            icon: Icons.calendar_view_month,
                          ),
                          StatCard(
                            title: 'Current Year Revenue',
                            value: '₹${_yearRevenue.toStringAsFixed(0)}',
                            icon: Icons.calendar_today,
                          ),
                          StatCard(
                            title: 'All-Time Revenue',
                            value: '₹${_totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.account_balance,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Attendance & Inactive Logs
                  Text('Gym Footfall & Outstanding Dues', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = Responsive.gridCount(context, mobile: 1, tablet: 3, desktop: 3);
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 2.0 : 1.6,
                        children: [
                          StatCard(
                            title: 'Month Attendance Check-Ins',
                            value: '$_monthCheckins Visits',
                            icon: Icons.how_to_reg,
                          ),
                          StatCard(
                            title: 'Year Attendance Check-Ins',
                            value: '$_yearCheckins Visits',
                            icon: Icons.badge,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.money_off_csred_outlined, color: scheme.error),
                                  const SizedBox(height: 12),
                                  const Text('Unpaid Dues This Month'),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_monthUnpaid Accounts',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Growth summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: scheme.primary, size: 36),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('New Registrations This Month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  '$_joinedMonthMembers new members joined • $_joinedMonthTrainers new trainers onboarded',
                                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
