import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:saks_nyc_guide/utils/messages_util.dart';
import 'package:saks_nyc_guide/utils/iterinary_util.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatBotPage extends StatefulWidget {
  Function callback;
  ChatBotPage({super.key, required this.callback});

  @override
  State<ChatBotPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatBotPage> {
  List<types.Message> _messages = [];
  final String _moveToItinerary = "Your itinerary has been created. Click this bubble to go to the itinerary page.";
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  final _bot = const types.User(
    id: 'bot_id',
  );

  dynamic database;

  Future<void> createDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'messages_database.db'),
      onCreate: (db, version) async {
        db.execute(
            'CREATE TABLE messages(id STRING PRIMARY KEY, messageText TEXT, createdAt INTEGER, author STRING)');
        db.execute(
          '''CREATE TABLE attractions (
              id INTEGER PRIMARY KEY,
              name TEXT,
              address TEXT,
              phone TEXT,
              rating REAL,
              price TEXT,
              categories TEXT,
              latitude REAL,
              longitude REAL,
              monday TEXT,
              tuesday TEXT,
              wednesday TEXT,
              thursday TEXT,
              friday TEXT,
              saturday TEXT,
              sunday TEXT
            );
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> _fetchData(message) async {
    print("Message is: " + message);
    final Uri uri = Uri.parse(
        'https://u9rvp4d6qi.execute-api.us-east-1.amazonaws.com/beta/chatbot');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      // Add any additional headers if needed
    };
    final Map<String, dynamic> requestBody = {
      "messages": [
        {"text": message}
      ]
    };

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      // You can handle the response data here as needed
      try {
        // Parse the JSON response
        final Map<String, dynamic> parsedResponse = jsonDecode(response.body);

        // Access the value of messages.content
        final String messagesContent =
            parsedResponse['body-json']['messages'][0]['content'];

        if (parsedResponse['body-json']['isDataExist'] == true) {
          List<dynamic> attractionsData =
              parsedResponse['body-json']['data']['response']['attractions'];

          List<dynamic> restaurantData =
              parsedResponse['body-json']['data']['response']['restaurants'];

          List<Attraction> attractionList = [];

          for (var attraction in attractionsData) {
            Attraction attr = Attraction(
              name: attraction["Name"],
              address: attraction["Address"] ?? "--",
              phone: attraction["Phone"] ?? "--",
              rating: attraction["Rating"] == null
                  ? "--"
                  : attraction["Rating"].toString(),
              categories: attraction["Categories"] ?? "--",
              price: attraction["Price Range"] == null
                  ? "--"
                  : attraction['Price Range'],
              latitude: attraction["Latitude"],
              longitude: attraction["Longitude"],
              openingHours: {
                'Monday': attraction['Monday'] ?? "--",
                'Tuesday': attraction['Tuesday'] ?? "--",
                'Wednesday': attraction['Wednesday'] ?? "--",
                'Thursday': attraction['Thursday'] ?? "--",
                'Friday': attraction['Friday'] ?? "--",
                'Saturday': attraction['Saturday'] ?? "--",
                'Sunday': attraction['Sunday'] ?? "--"
              },
            );
            attractionList.add(attr);
          }

          for (var restaurant in restaurantData) {
            Attraction attr = Attraction(
              name: restaurant["Name"],
              address: restaurant["Address"] ?? "--",
              phone: restaurant["Phone"] ?? "--",
              rating: restaurant["Rating"] == null
                  ? "--"
                  : restaurant["Rating"].toString(),
              categories: restaurant["Categories"] ?? "--",
              price: restaurant["Price Range"] == null
                  ? "--"
                  : restaurant['Price Range'],
              latitude: restaurant["Latitude"],
              longitude: restaurant["Longitude"],
              openingHours: {
                'Monday': restaurant['Monday'] ?? "--",
                'Tuesday': restaurant['Tuesday'] ?? "--",
                'Wednesday': restaurant['Wednesday'] ?? "--",
                'Thursday': restaurant['Thursday'] ?? "--",
                'Friday': restaurant['Friday'] ?? "--",
                'Saturday': restaurant['Saturday'] ?? "--",
                'Sunday': restaurant['Sunday'] ?? "--"
              },
            );
            attractionList.add(attr);
          }

          for (Attraction attraction in attractionList) {
            await database.then((d) {
              d.insert("attractions", attraction.toMap());
            });
          }

          final goToItineraryMessage = types.TextMessage(
            author: _bot,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: _moveToItinerary,
          );

          setState(() {
            _messages.insert(0, goToItineraryMessage);
          });

          await database.then((d) {
            d.insert(
                "messages",
                ChatMessage(
                        author: _bot,
                        createdAt: goToItineraryMessage.createdAt,
                        id: goToItineraryMessage.id,
                        messageText: goToItineraryMessage.text)
                    .toMap());
          });
        } else {
          print(messagesContent); // Output: Please enter a valid input
          final textMessage = types.TextMessage(
            author: _bot,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: messagesContent,
          );
          setState(() {
            _messages.insert(0, textMessage);
          });

          await database.then((d) {
            d.insert(
                "messages",
                ChatMessage(
                        author: _bot,
                        createdAt: textMessage.createdAt,
                        id: textMessage.id,
                        messageText: textMessage.text)
                    .toMap());
          });
        }
      } catch (e) {
        // Handle exceptions
        print('Error: $e');
      }
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      print(response.statusCode);
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    createDB().then((value) => _loadMessages());
  }

  void _addMessage(types.Message message, String messageText) {
    setState(() {
      _messages.insert(0, message);
    });
    _fetchData(messageText);
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

    _addMessage(textMessage, message.text.toString());
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

  void _goToItineraryPage(BuildContext context, types.Message m) async {
    try {
      String message = m.toJson()["text"];
      if (message.contains(_moveToItinerary)) {
        widget.callback(1);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          textMessageOptions: const TextMessageOptions(isTextSelectable: false),
          onMessageLongPress: _goToItineraryPage,
          onMessageTap: _goToItineraryPage,
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
