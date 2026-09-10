import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.get('/api/admin/notifications'),
        api.get('/api/admin/members').catchError((_) => <String, dynamic>{}),
        api.get('/api/admin/trainers').catchError((_) => <String, dynamic>{}),
      ]);

      final notifRes = results[0];
      final memRes = results[1] as Map<String, dynamic>;
      final trRes = results[2] as Map<String, dynamic>;

      List<dynamic> notifList = [];
      if (notifRes is Map && notifRes['notifications'] is List) {
        notifList = notifRes['notifications'];
      } else if (notifRes is List) {
        notifList = notifRes;
      }

      setState(() {
        _notifications = asMapList(notifList);
        _members = asMapList(memRes['members']);
        _trainers = asMapList(trRes['trainers']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load notifications history.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSendDialog() async {
    String targetType = 'ALL_MEMBERS';
    num? specificId;
    final titleCtrl = TextEditingController(text: 'Gym Announcement');
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool sending = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Dispatch Gym Broadcast'),
              content: SizedBox(
                width: 460,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: targetType,
                          decoration: const InputDecoration(labelText: 'Target Audience *'),
                          items: const [
                            DropdownMenuItem(value: 'ALL_MEMBERS', child: Text('All Members Broadcast')),
                            DropdownMenuItem(value: 'ALL_TRAINERS', child: Text('All Trainers Broadcast')),
                            DropdownMenuItem(value: 'SPECIFIC_MEMBER', child: Text('Specific Member')),
                            DropdownMenuItem(value: 'SPECIFIC_TRAINER', child: Text('Specific Trainer')),
                          ],
                          onChanged: (v) {
                            setDialogState(() {
                              targetType = v ?? 'ALL_MEMBERS';
                              specificId = null;
                              if (targetType == 'SPECIFIC_MEMBER' && _members.isNotEmpty) {
                                specificId = _members.first['id'];
                              } else if (targetType == 'SPECIFIC_TRAINER' && _trainers.isNotEmpty) {
                                specificId = _trainers.first['id'];
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (targetType == 'SPECIFIC_MEMBER') ...[
                          DropdownButtonFormField<num>(
                            value: specificId,
                            decoration: const InputDecoration(labelText: 'Select Member *'),
                            items: _members.map((m) {
                              return DropdownMenuItem<num>(value: m['id'], child: Text(asString(m['name'])));
                            }).toList(),
                            onChanged: (v) => setDialogState(() => specificId = v),
                          ),
                          const SizedBox(height: 12),
                        ] else if (targetType == 'SPECIFIC_TRAINER') ...[
                          DropdownButtonFormField<num>(
                            value: specificId,
                            decoration: const InputDecoration(labelText: 'Select Trainer *'),
                            items: _trainers.map((t) {
                              return DropdownMenuItem<num>(value: t['id'], child: Text(asString(t['name'])));
                            }).toList(),
                            onChanged: (v) => setDialogState(() => specificId = v),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(labelText: 'Notice Title *'),
                          validator: (v) => Validators.requiredField(v, label: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: msgCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Notification Message *'),
                          validator: (v) => Validators.requiredField(v, label: 'Message'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                AppButton(
                  loading: sending,
                  label: 'Send Notification',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => sending = true);

                    final api = context.read<ApiService>();
                    final body = {
                      'title': titleCtrl.text.trim(),
                      'message': msgCtrl.text.trim(),
                    };

                    try {
                      switch (targetType) {
                        case 'ALL_MEMBERS':
                          await api.post('/api/admin/notifications/members', body: body);
                        case 'ALL_TRAINERS':
                          await api.post('/api/admin/notifications/trainers', body: body);
                        case 'SPECIFIC_MEMBER':
                          await api.post('/api/admin/notifications/member/$specificId', body: body);
                        case 'SPECIFIC_TRAINER':
                          await api.post('/api/admin/notifications/trainer/$specificId', body: body);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadAll();
                    } on ApiException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    } finally {
                      if (dialogCtx.mounted) setDialogState(() => sending = false);
                    }
                  },
                ),
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
      onRetry: _loadAll,
      isEmpty: _notifications.isEmpty,
      emptyMessage: 'No push notifications recorded in logs.',
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
                        Text('Notification Broadcasts', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Send announcements to all members, coaches, or individual accounts.'),
                      ],
                    ),
                    AppButton(
                      label: 'Send Notice',
                      icon: Icons.send_outlined,
                      onPressed: _openSendDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final item = _notifications[idx];
                    final title = asString(item['title'], 'Notice');
                    final msg = asString(item['message']);
                    final role = asString(item['recipient_role'], 'ALL');
                    final date = asString(item['created_at']).split('T').first;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.notifications_active_outlined, color: scheme.primary),
                        ),
                        title: Row(
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            StatusBadge(label: role),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(msg),
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                          ],
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
