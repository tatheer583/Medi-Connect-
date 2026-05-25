import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String otherUserName;
  const ChatRoomScreen({super.key, required this.otherUserName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello, how are you feeling today?', 'isMe': false},
    {'text': 'I am feeling better, but still have some headache.', 'isMe': true},
    {'text': 'Please share your latest BP readings.', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.blue)),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({'text': _messageController.text, 'isMe': true});
                    _messageController.clear();
                  });
                }
              },
              icon: const Icon(Icons.send, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
