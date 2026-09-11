import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/plans', auth: false);
      // Response can be { success: true, data/plans: [...] } or direct list
      List<dynamic> list = [];
      if (res is List) {
        list = res;
      } else if (res is Map) {
        if (res['data'] is List) {
          list = res['data'];
        } else if (res['plans'] is List) {
          list = res['plans'];
        }
      }
      setState(() {
        _plans = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Unable to load membership plans. Please try again.');
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
      onRetry: _fetchPlans,
      isEmpty: _plans.isEmpty,
      emptyMessage: 'No membership plans currently available. Please check back soon.',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Membership Plans',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the right membership tier designed to accelerate your strength and wellness journey.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = Responsive.gridCount(context, mobile: 1, tablet: 2, desktop: 3);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: Responsive.isMobile(context) ? 1.2 : 0.82,
                      ),
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        final name = asString(plan['name'], 'Membership Plan');
                        final desc = asString(plan['description']);
                        final price = asNum(plan['price']);
                        final durationValue = asNum(plan['duration_value'], 1);
                        final durationUnit = asString(plan['duration_unit'], 'MONTH');
                        final extraFeatures = asString(plan['extra_features']);

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: scheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    StatusBadge(label: '$durationValue $durationUnit'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '₹${price.toStringAsFixed(0)}',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ $durationValue ${durationUnit.toLowerCase()}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (desc.isNotEmpty) ...[
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                const Divider(),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _PlanFeatureItem('Full Gym & Weights Access'),
                                        _PlanFeatureItem('Locker & Shower Facility'),
                                        if (extraFeatures.isNotEmpty)
                                          _PlanFeatureItem(extraFeatures, highlighted: true)
                                        else
                                          _PlanFeatureItem('Free Trainer Consultation'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanFeatureItem extends StatelessWidget {
  const _PlanFeatureItem(this.text, {this.highlighted = false});
  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: highlighted ? scheme.primary : scheme.secondary.withValues(alpha: 0.6),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
