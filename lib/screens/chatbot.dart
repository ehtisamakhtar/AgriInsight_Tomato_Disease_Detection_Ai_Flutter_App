import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotAgriAi extends StatefulWidget {
  const ChatBotAgriAi({super.key});

  @override
  State<ChatBotAgriAi> createState() => _ChatBotAgriAiState();
}

class _ChatBotAgriAiState extends State<ChatBotAgriAi> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  static const String apiKey = 'AIzaSyCV00lrUZh-GirEe6WUS_aNZpg6zTOMbmQ';
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';


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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final prompt = '''
You are an expert in agriculture and crop disease detection,especially tomato diseases.
Provide short max 10-15 lines,concise, practical answers about plants, .
If the user asks anything unrelated, reply:"I only assist with plant-related topics."

User: $message
''';

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botText = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add(ChatMessage(text: botText, isUser: false));
          _isTyping = false;
        });
      } else {
        print('Gemini error: ${response.body}');
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error: ${response.statusCode}',
            isUser: false,
          ));
          _isTyping = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Gemini API Error: $e',
          isUser: false,
        ));
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Care Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about tomato or plant issues...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(child: Icon(Icons.eco)),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.green[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ),
        if (isUser)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
      ],
    );
  }
}
