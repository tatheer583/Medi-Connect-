import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/shimmer_loader.dart';
import 'package:mediconnect_mobile/src/theme/app_theme.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String otherUserName;
  final String otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.otherUserName,
    this.otherUserId = 'unknown',
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  RealtimeSubscription? _subscription;

  late String _chatId;
  late String _myId;
  late String _myName;

  @override
  void initState() {
    super.initState();
    final userState = ref.read(authServiceProvider);
    _myId = userState.userId ?? 'me';
    _myName = userState.email?.split('@').first ?? 'User';

    // Chat ID is deterministic — sorted user IDs joined
    final ids = [_myId, widget.otherUserId]..sort();
    _chatId = ids.join('_');

    _loadMessages();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _subscription?.close();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final docs = await DatabaseService().getChatMessages(_chatId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(docs.map((d) => {...d.data, '\$id': d.$id}));
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribeRealtime() {
    _subscription = DatabaseService().subscribeToChatMessages(
      _chatId,
      (event) {
        if (!mounted) return;
        final payload = event.payload;
        if (event.events.any((e) => e.contains('create'))) {
          setState(() {
            _messages.add(payload);
          });
          _scrollToBottom();

          // Mark as read if received
          if (payload['senderId'] != _myId) {
            DatabaseService().markMessageRead(payload['\$id'] ?? '');
          }
        }
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    _ctrl.clear();
    setState(() => _sending = true);

    try {
      await DatabaseService().sendMessage(
        senderId: _myId,
        receiverId: widget.otherUserId,
        senderName: _myName,
        text: text,
        chatId: _chatId,
      );
    } catch (_) {
      // Realtime will handle adding to list
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                widget.otherUserName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text('Online',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                        children: [ShimmerCard(), ShimmerCard(), ShimmerCard()]),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 64,
                                color: AppColors.textHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text('Start the conversation',
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isMe = msg['senderId'] == _myId;
                          final read = msg['read'] as bool? ?? false;
                          return _ChatBubble(
                            text: msg['text'] as String? ?? '',
                            time: _formatTime(msg['createdAt'] as String?),
                            isMe: isMe,
                            read: read,
                          );
                        },
                      ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                        GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientBlue,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool read;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.read,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded,
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe ? AppColors.gradientBlue : null,
                  color: isMe ? null : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.textHint)),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      read
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 12,
                      color: read ? AppColors.primary : AppColors.textHint,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
