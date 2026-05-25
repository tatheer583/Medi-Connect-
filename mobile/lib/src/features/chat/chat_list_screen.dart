import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconnect_mobile/src/routing/app_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.separated(
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chats = [
            {'name': 'Dr. Ahmed Raza', 'lastMsg': 'Please share your latest BP readings.', 'time': '10:30 AM', 'unread': '2'},
            {'name': 'Dr. Sarah Khan', 'lastMsg': 'The report looks normal. No need to worry.', 'time': 'Yesterday', 'unread': '0'},
            {'name': 'Dr. Usman Ali', 'lastMsg': 'How are you feeling today?', 'time': 'Monday', 'unread': '0'},
          ];
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat['lastMsg']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                if (chat['unread'] != '0')
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: Text(chat['unread']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
              ],
            ),
            onTap: () => context.pushNamed(AppRoute.chatRoom.name, extra: chat['name']),
          );
        },
      ),
    );
  }
}
