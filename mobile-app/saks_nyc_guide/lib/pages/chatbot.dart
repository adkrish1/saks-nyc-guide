import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:saks_nyc_guide/utils/messages_util.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatBotPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  dynamic database;

  Future<void> createDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'messages_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE messages(id STRING PRIMARY KEY, messageText TEXT, createdAt INTEGER, author STRING)',
        );
      },
      version: 1,
    );
  }

  @override
  void initState() {
    super.initState();
    createDB().then((value) => _loadMessages());
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    await database.then((d) {
      d.insert(
          "messages",
          ChatMessage(
                  author: textMessage.author,
                  createdAt: textMessage.createdAt,
                  id: textMessage.id,
                  messageText: textMessage.text)
              .toMap());
    });

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    await database.then((d) {
      d.query('messages').then((messagesMap) {
        for (final {
              'id': id as String,
              'author': author as String,
              'messageText': messageText as String,
              'createdAt': createdAt as int?,
            } in messagesMap) {
          final message = types.TextMessage(
            author: types.User(id: author),
            createdAt: createdAt as int,
            id: id,
            text: messageText,
          );
          setState(() {
            _messages.insert(0, message);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          theme: const DefaultChatTheme(
            seenIcon: Text(
              'read',
              style: TextStyle(
                fontSize: 10.0,
              ),
            ),
          ),
        ),
      );
}
