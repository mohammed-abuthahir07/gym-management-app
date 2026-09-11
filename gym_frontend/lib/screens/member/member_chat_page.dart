import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class MemberChatPage extends StatefulWidget {
  const MemberChatPage({super.key});

  @override
  State<MemberChatPage> createState() => _MemberChatPageState();
}

class _MemberChatPageState extends State<MemberChatPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _trainer;
  List<Map<String, dynamic>> _messages = [];
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Converts UTC timestamp string from API to local Indian Standard Time (IST)
  String _formatIndianTime(String rawTime) {
    if (rawTime.isEmpty) return '';
    try {
      final DateTime parsedUtc = DateTime.parse(rawTime);
      final DateTime localTime = parsedUtc.toLocal(); // Converts to device local timezone (IST)
      
      int hour = localTime.hour;
      final int minute = localTime.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      final String minuteStr = minute.toString().padLeft(2, '0');
      return '$hour:$minuteStr $period';
    } catch (_) {
      // Fallback if parsing fails
      return rawTime.contains('T') ? rawTime.split('T').last.split('.').first : rawTime;
    }
  }

  Future<void> _loadConversation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    try {
      final trainerRes = await api.get('/api/member/messages/trainer') as Map<String, dynamic>;
      if (trainerRes['trainer'] is Map) {
        final trainerData = Map<String, dynamic>.from(trainerRes['trainer'] as Map);
        _trainer = trainerData;
        final trainerId = trainerData['id'];

        final msgRes = await api.get('/api/member/messages/$trainerId') as Map<String, dynamic>;
        setState(() {
          _messages = asMapList(msgRes['messages']);
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Unable to connect to trainer conversation.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _trainer == null || _sending) return;

    setState(() => _sending = true);
    final trainerId = _trainer!['id'];

    try {
      final api = context.read<ApiService>();
      await api.post('/api/member/messages/$trainerId', body: {'message': text});
      _messageCtrl.clear();
      
      // Reload messages
      final msgRes = await api.get('/api/member/messages/$trainerId') as Map<String, dynamic>;
      setState(() {
        _messages = asMapList(msgRes['messages']);
      });
      _scrollToBottom();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _loadConversation,
      isEmpty: _trainer == null,
      emptyMessage: 'No assigned trainer currently found. Please contact administration to assign your personal coach.',
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: SizedBox(
              height: screenHeight * 0.78,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Trainer header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: scheme.surfaceContainerHighest.withOpacity(0.5),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: scheme.primary,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asString(_trainer?['name'], 'Assigned Trainer'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  asString(_trainer?['email']),
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh Chat',
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadConversation,
                          ),
                        ],
                      ),
                    ),

                    // Message history
                    Expanded(
                      child: _messages.isEmpty
                          ? const Center(child: Text('Start a conversation with your personal trainer.'))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, idx) {
                                final msg = _messages[idx];
                                final text = asString(msg['message']);
                                final senderRole = asString(msg['sender_role']);
                                final isMe = senderRole == 'MEMBER';
                                
                                final rawTime = asString(msg['created_at']);
                                final time = _formatIndianTime(rawTime);

                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    constraints: const BoxConstraints(maxWidth: 420),
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
                                          style: TextStyle(
                                            color: isMe ? Colors.white : scheme.onSurface,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            color: isMe ? Colors.white70 : theme.textTheme.bodySmall?.color,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const Divider(height: 1),

                    // Send field
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Type your message to coach...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _sending ? null : _sendMessage,
                            icon: _sending
                                ? const SizedBox(
                                    width: 18, 
                                    height: 18, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send),
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
      ),
    );
  }
}