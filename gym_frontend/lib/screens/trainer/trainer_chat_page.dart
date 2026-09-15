import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';

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

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _messageScrollController =
      ScrollController();

  bool _conversationLoading = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ASSIGNED MEMBERS
  // ============================================================
  //
  // IMPORTANT:
  // We use /api/trainer/assigned-members here.
  //
  // Do NOT use /api/trainer/messages for the member list because
  // that may return only members who already started a chat.
  //
  // Trainer must be able to start a new conversation.
  // ============================================================

  Future<void> _fetchMembers() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/assigned-members',
      );

      final members = _extractMembers(response);

      if (!mounted) return;

      Map<String, dynamic>? selected;

      // Try to keep currently selected member.
      if (_selectedMember != null) {
        final selectedId =
            _idString(_selectedMember!['id']);

        for (final member in members) {
          if (_idString(member['id']) == selectedId) {
            selected = member;
            break;
          }
        }
      }

      // If no previous selection, select first member.
      selected ??=
          members.isNotEmpty ? members.first : null;

      setState(() {
        _members = members;
        _selectedMember = selected;
        _loading = false;
        _error = null;
      });

      // Load conversation if a member exists.
      if (selected != null) {
        await _loadConversation(
          selected,
          showLoading: true,
        );
      } else {
        if (!mounted) return;

        setState(() {
          _messages = [];
          _conversationLoading = false;
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
        _error = 'Failed to load assigned members.';
      });
    }
  }

  // ============================================================
  // EXTRACT MEMBERS
  // ============================================================

  List<Map<String, dynamic>> _extractMembers(
    dynamic response,
  ) {
    if (response is List) {
      return asMapList(response);
    }

    if (response is Map) {
      final dynamic members =
          response['members'];

      if (members is List) {
        return asMapList(members);
      }

      final dynamic data =
          response['data'];

      if (data is List) {
        return asMapList(data);
      }
    }

    return [];
  }

  // ============================================================
  // SELECT MEMBER
  // ============================================================

  Future<void> _selectMember(
    Map<String, dynamic> member,
  ) async {
    if (!mounted) return;

    setState(() {
      _selectedMember = member;
      _messages = [];
    });

    await _loadConversation(
      member,
      showLoading: true,
    );
  }

  // ============================================================
  // LOAD CONVERSATION
  // ============================================================

  Future<void> _loadConversation(
    Map<String, dynamic> member, {
    bool showLoading = false,
  }) async {
    final memberId = member['id'];

    if (memberId == null) {
      if (!mounted) return;

      setState(() {
        _conversationLoading = false;
        _messages = [];
      });

      return;
    }

    if (!mounted) return;

    if (showLoading) {
      setState(() {
        _conversationLoading = true;
      });
    }

    try {
      final api = context.read<ApiService>();

      final response = await api.get(
        '/api/trainer/messages/$memberId',
      );

      final messages =
          _extractMessages(response);

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _conversationLoading = false;
      });

      await _markUnreadMessagesAsRead(
        messages,
      );

      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _conversationLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _conversationLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load conversation.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EXTRACT MESSAGES
  // ============================================================

  List<Map<String, dynamic>> _extractMessages(
    dynamic response,
  ) {
    if (response is List) {
      return asMapList(response);
    }

    if (response is Map) {
      final dynamic messages =
          response['messages'];

      if (messages is List) {
        return asMapList(messages);
      }

      final dynamic conversation =
          response['conversation'];

      if (conversation is List) {
        return asMapList(conversation);
      }

      final dynamic data =
          response['data'];

      if (data is List) {
        return asMapList(data);
      }
    }

    return [];
  }

  // ============================================================
  // MARK UNREAD MESSAGES AS READ
  // ============================================================

  Future<void> _markUnreadMessagesAsRead(
    List<Map<String, dynamic>> messages,
  ) async {
    final api = context.read<ApiService>();

    for (final message in messages) {
      final senderRole = asString(
        message['sender_role'],
      ).toUpperCase();

      final messageId = message['id'];

      if (messageId == null) {
        continue;
      }

      final isRead =
          _isMessageRead(message);

      if (senderRole == 'MEMBER' &&
          !isRead) {
        try {
          await api.put(
            '/api/trainer/messages/$messageId/read',
          );
        } catch (_) {
          // Ignore read-status failure.
        }
      }
    }
  }

  // ============================================================
  // READ CHECK
  // ============================================================

  bool _isMessageRead(
    Map<String, dynamic> message,
  ) {
    final value =
        message['is_read'];

    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    final text = value
        .toString()
        .trim()
        .toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'read';
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    final selectedMember =
        _selectedMember;

    if (text.isEmpty ||
        selectedMember == null ||
        _sending) {
      return;
    }

    final memberId =
        selectedMember['id'];

    if (memberId == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _sending = true;
    });

    try {
      final api =
          context.read<ApiService>();

      await api.post(
        '/api/trainer/messages/$memberId',
        body: {
          'message': text,
        },
      );

      if (!mounted) return;

      _messageController.clear();

      await _loadConversation(
        selectedMember,
        showLoading: false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to send message.',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });
    }
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!_messageScrollController
            .hasClients) {
          return;
        }

        _messageScrollController.animateTo(
          _messageScrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  // ============================================================
  // ID HELPER
  // ============================================================

  String _idString(dynamic value) {
    return value?.toString() ?? '';
  }

  // ============================================================
  // BUILD
  // ============================================================
  //
  // IMPORTANT:
  // NO AsyncStateView around the whole page.
  //
  // Even when there are zero members, the page itself remains
  // visible.
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final padding =
        Responsive.pagePadding(
      context,
    );

    return RefreshIndicator(
      onRefresh: _fetchMembers,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              children: [
                // ======================================================
                // ERROR
                // ======================================================

                if (_error != null) ...[
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .error_outline,
                            color:
                                theme
                                    .colorScheme
                                    .error,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              _error!,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _fetchMembers,
                            icon:
                                const Icon(
                              Icons.refresh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],

                // ======================================================
                // LOADING
                // ======================================================

                if (_loading)
                  const Padding(
                    padding:
                        EdgeInsets.all(40),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),

                // ======================================================
                // EMPTY ASSIGNED MEMBERS
                // ======================================================

                if (!_loading &&
                    _error == null &&
                    _members.isEmpty)
                  _buildNoMembersState(
                    theme,
                  ),

                // ======================================================
                // CHAT UI
                // ======================================================

                if (!_loading &&
                    _members.isNotEmpty)
                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      final isMobile =
                          constraints.maxWidth <
                              750;

                      return isMobile
                          ? _buildMobileLayout(
                              theme,
                            )
                          : _buildDesktopLayout(
                              theme,
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

  // ============================================================
  // NO ASSIGNED MEMBERS
  // ============================================================

  Widget _buildNoMembersState(
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color:
                  theme.colorScheme.primary,
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              'No assigned members yet.',
              style: theme
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Admin must assign members to you before you can start a conversation.',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 18,
            ),
            OutlinedButton.icon(
              onPressed:
                  _fetchMembers,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Refresh',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout(
    ThemeData theme,
  ) {
    return SizedBox(
      height: 680,
      child: Card(
        clipBehavior:
            Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 290,
              child:
                  _buildMemberSidebar(
                theme,
              ),
            ),
            const VerticalDivider(
              width: 1,
            ),
            Expanded(
              child:
                  _buildConversationArea(
                theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout(
    ThemeData theme,
  ) {
    return Column(
      children: [
        _buildMobileMemberSelector(
          theme,
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 650,
          child: Card(
            clipBehavior:
                Clip.antiAlias,
            child:
                _buildConversationArea(
              theme,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE MEMBER SELECTOR
  // ============================================================

  Widget _buildMobileMemberSelector(
    ThemeData theme,
  ) {
    final scheme =
        theme.colorScheme;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  scheme.primary
                      .withOpacity(0.10),
              child: Icon(
                Icons.people,
                color:
                    scheme.primary,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<
                        Map<String,
                            dynamic>>(
                  isExpanded:
                      true,
                  value:
                      _selectedMember,
                  hint:
                      const Text(
                    'Select member',
                  ),
                  items:
                      _members.map(
                    (member) {
                      final name =
                          asString(
                        member[
                            'name'],
                        'Member',
                      );

                      return DropdownMenuItem<
                          Map<String,
                              dynamic>>(
                        value:
                            member,
                        child:
                            Text(
                          name,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (member) {
                    if (member !=
                        null) {
                      _selectMember(
                        member,
                      );
                    }
                  },
                ),
              ),
            ),
            IconButton(
              tooltip:
                  'Refresh',
              onPressed:
                  _loading
                      ? null
                      : _fetchMembers,
              icon:
                  const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEMBER SIDEBAR
  // ============================================================

  Widget _buildMemberSidebar(
    ThemeData theme,
  ) {
    final scheme =
        theme.colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.all(16),
          color: scheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Assigned Members',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip:
                    'Refresh',
                icon:
                    const Icon(
                  Icons.refresh,
                  size: 20,
                ),
                onPressed:
                    _loading
                        ? null
                        : _fetchMembers,
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
        ),
        Expanded(
          child:
              _members.isEmpty
                  ? const Center(
                      child: Text(
                        'No assigned members.',
                        textAlign:
                            TextAlign
                                .center,
                      ),
                    )
                  : ListView.separated(
                      itemCount:
                          _members.length,
                      separatorBuilder:
                          (
                        _,
                        __,
                      ) =>
                              const Divider(
                        height: 1,
                      ),
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return _buildMemberTile(
                          theme,
                          _members[
                              index],
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ============================================================
  // MEMBER TILE
  // ============================================================

  Widget _buildMemberTile(
    ThemeData theme,
    Map<String, dynamic> member,
  ) {
    final scheme =
        theme.colorScheme;

    final isSelected =
        _selectedMember !=
                null &&
            _idString(
                  _selectedMember![
                      'id'],
                ) ==
                _idString(
                  member['id'],
                );

    final name =
        asString(
      member['name'],
      'Member',
    );

    final email =
        asString(
      member['email'],
      '',
    );

    return Material(
      color: isSelected
          ? scheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: () =>
            _selectMember(
          member,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    scheme.primary
                        .withOpacity(
                  0.12,
                ),
                child: Text(
                  name.isNotEmpty
                      ? name[0]
                          .toUpperCase()
                      : 'M',
                  style:
                      TextStyle(
                    color:
                        scheme.primary,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                        fontSize: 14,
                      ),
                    ),
                    if (email
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONVERSATION AREA
  // ============================================================

  Widget _buildConversationArea(
    ThemeData theme,
  ) {
    if (_selectedMember ==
        null) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(24),
          child: Text(
            'Select a member to start chatting.',
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildConversationHeader(
          theme,
        ),
        const Divider(
          height: 1,
        ),
        Expanded(
          child:
              _buildMessagesArea(
            theme,
          ),
        ),
        const Divider(
          height: 1,
        ),
        _buildMessageInput(
          theme,
        ),
      ],
    );
  }

  // ============================================================
  // CONVERSATION HEADER
  // ============================================================

  Widget _buildConversationHeader(
    ThemeData theme,
  ) {
    final scheme =
        theme.colorScheme;

    final name =
        asString(
      _selectedMember!['name'],
      'Member',
    );

    final email =
        asString(
      _selectedMember!['email'],
      '',
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      color: scheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                scheme.primary,
            child:
                const Icon(
              Icons.person,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (email
                    .isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip:
                'Refresh conversation',
            onPressed:
                _conversationLoading
                    ? null
                    : () =>
                        _loadConversation(
                      _selectedMember!,
                      showLoading:
                          true,
                    ),
            icon:
                _conversationLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGES AREA
  // ============================================================

  Widget _buildMessagesArea(
    ThemeData theme,
  ) {
    if (_conversationLoading &&
        _messages.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(24),
          child: Text(
            'No messages yet.\nSend the first message to this member.',
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      controller:
          _messageScrollController,
      padding:
          const EdgeInsets.all(16),
      itemCount:
          _messages.length,
      itemBuilder:
          (
        context,
        index,
      ) {
        return _buildMessageBubble(
          theme,
          _messages[index],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble(
    ThemeData theme,
    Map<String, dynamic> message,
  ) {
    final scheme =
        theme.colorScheme;

    final text =
        asString(
      message['message'],
      '',
    );

    final senderRole =
        asString(
      message['sender_role'],
    ).toUpperCase();

    final isTrainer =
        senderRole == 'TRAINER';

    final time =
        _formatMessageTime(
      message['created_at'],
    );

    return Align(
      alignment: isTrainer
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.symmetric(
          vertical: 4,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints:
            const BoxConstraints(
          maxWidth: 420,
        ),
        decoration:
            BoxDecoration(
          color: isTrainer
              ? scheme.primary
              : scheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(
              14,
            ),
            topRight:
                const Radius.circular(
              14,
            ),
            bottomLeft:
                Radius.circular(
              isTrainer
                  ? 14
                  : 3,
            ),
            bottomRight:
                Radius.circular(
              isTrainer
                  ? 3
                  : 14,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isTrainer
                  ? CrossAxisAlignment
                      .end
                  : CrossAxisAlignment
                      .start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isTrainer
                    ? Colors.white
                    : scheme
                        .onSurface,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            if (time.isNotEmpty) ...[
              const SizedBox(
                height: 5,
              ),
              Text(
                time,
                style:
                    TextStyle(
                  color: isTrainer
                      ? Colors
                          .white70
                      : theme
                          .textTheme
                          .bodySmall
                          ?.color,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE INPUT
  // ============================================================

  Widget _buildMessageInput(
    ThemeData theme,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller:
                    _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction
                        .newline,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Type your message to member...',
                  border:
                      OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            SizedBox(
              height: 48,
              width: 48,
              child:
                  IconButton.filled(
                tooltip:
                    'Send',
                onPressed:
                    _sending
                        ? null
                        : _sendMessage,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME FORMATTER
  // ============================================================

  String _formatMessageTime(dynamic value) {
  if (value == null) {
    return '';
  }

  final raw = value.toString().trim();

  if (raw.isEmpty) {
    return '';
  }

  try {
    // Parse the backend timestamp.
    //
    // Example:
    // 2026-09-15T08:23:00.000Z
    //
    // The "Z" means UTC.
    final dateTime = DateTime.parse(raw);

    // Convert UTC time to the device's local timezone.
    final localTime = dateTime.toLocal();

    // Return HH:mm
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  } catch (_) {
    // Fallback for values that are already plain time strings.
    if (raw.contains(':')) {
      final parts = raw.split(':');

      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }

    return raw;
  }
}
}