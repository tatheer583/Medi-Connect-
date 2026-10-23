import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';
import 'package:mediconnect_mobile/src/services/auth_service.dart';
import 'package:mediconnect_mobile/src/services/database_service.dart';
import 'package:mediconnect_mobile/src/shared/widgets/empty_state.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  List<Map<String, String>> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _loading = true);
    final userId = ref.read(authServiceProvider).userId;
    if (userId == null || userId.isEmpty) {
      // Show nothing instead of fake conversations.
      if (!mounted) return;
      setState(() {_chats = []; _loading = false;});
      return;
    }
    try {
      final chats = await DatabaseService().getConversations(userId);
      if (!mounted) return;
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No Conversations Yet',
                  subtitle:
                      'Messages with your doctor or patients will appear here after you start a chat.',
                )
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.separated(
                    itemCount: _chats.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(chat['name'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () => context.pushNamed(
                          AppRoute.chatRoom.name,
                          extra: {
                            'name': chat['name'] ?? 'User',
                            'id': chat['id'] ?? '',
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
