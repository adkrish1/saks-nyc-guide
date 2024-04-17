import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

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

	@override
	void initState() {
		super.initState();
		_loadMessages();
	}

	void _addMessage(types.Message message) {
		setState(() {
			_messages.insert(0, message);
		});
	}

	void _handleSendPressed(types.PartialText message) {
		final textMessage = types.TextMessage(
			author: _user,
			createdAt: DateTime.now().millisecondsSinceEpoch,
			id: const Uuid().v4(),
			text: message.text,
		);

		_addMessage(textMessage);
	}

	void _loadMessages() async {
		final response = await rootBundle.loadString('assets/messages.json');
		final messages = (jsonDecode(response) as List)
			.map((e) => types.Message.fromJson(e as Map<String, dynamic>))
			.toList();

		setState(() {
			_messages = messages;
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
