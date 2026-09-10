import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerChatPage extends StatefulWidget {
  const TrainerChatPage({super.key});

  @override
  State<TrainerChatPage> createState() => _TrainerChatPageState();
}

class _TrainerChatPageState extends State<TrainerChatPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _members = [];
  Map<String, dynamic>? _selectedMember;
  List<Map<String, dynamic>> _messages = [];
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/trainer/messages');
      List<dynamic> list = [];
      if (res is Map && res['members'] is List) {
        list = res['members'];
      } else if (res is List) {
        list = res;
      }
      final parsed = asMapList(list);
      setState(() {
        _members = parsed;
        if (parsed.isNotEmpty && _selectedMember == null) {
          _selectMember(parsed.first);
        }
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load conversations.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectMember(Map<String, dynamic> m) async {
    setState(() {
      _selectedMember = m;
      _messages = [];
    });
    final api = context.read<ApiService>();
    try {
      final res = await api.get('/api/trainer/messages/${m['id']}');
      List<dynamic> list = [];
      if (res is Map && res['messages'] is List) list = res['messages'];
      setState(() {
        _messages = asMapList(list);
      });
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _selectedMember == null || _sending) return;

    setState(() => _sending = true);
    final memberId = _selectedMember!['id'];

    try {
      final api = context.read<ApiService>();
      await api.post('/api/trainer/messages/$memberId', body: {'message': text});
      _messageCtrl.clear();
      final res = await api.get('/api/trainer/messages/$memberId');
      List<dynamic> list = [];
      if (res is Map && res['messages'] is List) list = res['messages'];
      setState(() {
        _messages = asMapList(list);
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
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
      onRetry: _fetchMembers,
      isEmpty: _members.isEmpty,
      emptyMessage: 'No trainees have initiated a chat yet.',
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // Trainee list sidebar
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Trainees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20),
                                onPressed: _fetchMembers,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _members.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final m = _members[idx];
                              final isSelected = _selectedMember != null && _selectedMember!['id'] == m['id'];
                              final name = asString(m['name'], 'Trainee');

                              return ListTile(
                                selected: isSelected,
                                leading: CircleAvatar(
                                  radius: 18,
                                  child: Text(name.isNotEmpty ? name[0] : 'T'),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Text(asString(m['email']), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                onTap: () => _selectMember(m),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),

                  // Conversation Area
                  Expanded(
                    child: _selectedMember == null
                        ? const Center(child: Text('Select a trainee to view and send messages.'))
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: scheme.primary,
                                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        asString(_selectedMember!['name'], 'Trainee'),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: _messages.isEmpty
                                    ? const Center(child: Text('No messages yet in this conversation.'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _messages.length,
                                        itemBuilder: (context, i) {
                                          final msg = _messages[i];
                                          final text = asString(msg['message']);
                                          final role = asString(msg['sender_role']);
                                          final isMe = role == 'TRAINER';
                                          final time = asString(msg['created_at']).split('T').last.split('.').first;

                                          return Align(
                                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              constraints: const BoxConstraints(maxWidth: 400),
                                              decoration: BoxDecoration(
                                                color: isMe ? scheme.primary : scheme.surfaceContainerHighest,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(14),
                                                  topRight: const Radius.circular(14),
                                                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                                                  bottomRight: Radius.circular(isMe ? 2 : 14),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    text,
                                                    style: TextStyle(color: isMe ? Colors.white : scheme.onSurface, fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    time,
                                                    style: TextStyle(color: isMe ? Colors.white70 : theme.textTheme.bodySmall?.color, fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _messageCtrl,
                                        decoration: const InputDecoration(
                                          hintText: 'Type your message to trainee...',
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (_) => _sendMessage(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      onPressed: _sending ? null : _sendMessage,
                                      icon: _sending
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.send),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
