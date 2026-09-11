import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberNotificationsPage extends StatefulWidget {
  const MemberNotificationsPage({super.key});

  @override
  State<MemberNotificationsPage> createState() => _MemberNotificationsPageState();
}

class _MemberNotificationsPageState extends State<MemberNotificationsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final res = await api.get('/api/member/notifications');
      List<dynamic> list = [];
      if (res is Map && res['notifications'] is List) {
        list = res['notifications'];
      } else if (res is List) {
        list = res;
      }
      setState(() {
        _notifications = asMapList(list);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load notifications.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(num id) async {
    try {
      final api = context.read<ApiService>();
      await api.put('/api/member/notifications/$id/read');
      setState(() {
        for (final n in _notifications) {
          if (asNum(n['id']) == id) {
            n['is_read'] = 1;
          }
        }
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchNotifications,
      isEmpty: _notifications.isEmpty,
      emptyMessage: 'No notifications received yet.',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
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
                          Text(
                            'Notifications & Alerts',
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Announcements from management and updates from your trainer.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetchNotifications,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = _notifications[i];
                    final id = asNum(item['id']);
                    final title = asString(item['title'], 'Gym Notice');
                    final msg = asString(item['message']);
                    final isRead = asNum(item['is_read']) == 1;
                    
                    final rawDate = asString(item['created_at']);
                    final date = rawDate.contains('T') ? rawDate.split('T').first : rawDate;

                    return Card(
                      color: isRead ? null : scheme.primaryContainer.withOpacity(0.15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isRead ? scheme.surfaceContainerHighest : scheme.primary,
                          child: Icon(
                            isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: isRead ? scheme.onSurface : Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                              const SizedBox(height: 6),
                              Text(date, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                            ],
                          ),
                        ),
                        trailing: isRead
                            ? null
                            : TextButton(
                                onPressed: () => _markAsRead(id),
                                child: const Text('Mark Read'),
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