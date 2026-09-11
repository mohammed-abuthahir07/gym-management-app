import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class PublicTrainersPage extends StatefulWidget {
  const PublicTrainersPage({super.key});

  @override
  State<PublicTrainersPage> createState() => _PublicTrainersPageState();
}

class _PublicTrainersPageState extends State<PublicTrainersPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _fetchTrainers();
  }

  Future<void> _fetchTrainers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/trainers', auth: false);
      List<dynamic> list = [];
      if (res is List) {
        list = res;
      } else if (res is Map) {
        if (res['trainers'] is List) {
          list = res['trainers'];
        } else if (res['data'] is List) {
          list = res['data'];
        }
      }
      setState(() {
        _trainers = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Unable to load trainers. Please try again.');
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
      onRetry: _fetchTrainers,
      isEmpty: _trainers.isEmpty,
      emptyMessage: 'No certified trainers listed at the moment.',
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
                  'Meet Our Certified Trainers',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guiding your technique, formulating diet regimens, and keeping your motivation at its peak.',
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
                        childAspectRatio: Responsive.isMobile(context) ? 1.15 : 1.05,
                      ),
                      itemCount: _trainers.length,
                      itemBuilder: (context, index) {
                        final trainer = _trainers[index];
                        final name = asString(trainer['name'], 'Certified Coach');
                        final email = asString(trainer['email']);
                        final phone = asString(trainer['phone']);
                        final status = asString(trainer['status'], 'ACTIVE');

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Centered Avatar
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                                  child: Icon(Icons.person, color: scheme.primary, size: 34),
                                ),
                                const SizedBox(height: 12),
                                
                                // Centered Name
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                
                                // Centered Status Badge
                                StatusBadge(label: status, positive: status == 'ACTIVE'),
                                
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                
                                // Centered Email Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.email_outlined, size: 16, color: scheme.primary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        email.isNotEmpty ? email : 'trainer@peakforge.gym',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Centered Phone Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone_outlined, size: 16, color: scheme.primary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        phone.isNotEmpty ? phone : 'Contact via gym desk',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}