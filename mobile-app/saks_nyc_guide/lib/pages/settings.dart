import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void handleSignOut() async {
    await _googleSignIn.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
      children: <Widget>[
        const ListTile(
          title: Text('Info'),
          dense: true,
        ),
        const ListTile(
          title: Text('Clear Chats'),
          onTap: clearChats,
          dense: true,
        ),
        ListTile(
          title: const Text('Logout'),
          onTap: handleSignOut,
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
