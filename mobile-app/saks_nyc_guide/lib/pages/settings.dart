import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
      children: const <Widget>[
        ListTile(
          title: Text('Info'),
          dense: true,
        ),
        ListTile(
          title: Text('Clear Chats'),
          onTap: clearChats,
          dense: true,
        ),
        ListTile(
          title: Text('Logout'),
          dense: true,
        ),
      ],
    )));
  }
}

void clearChats() async {
  final db = await openDatabase(
    join(await getDatabasesPath(), 'messages_database.db'),
  );
  await db.execute("DELETE FROM messages");
}
