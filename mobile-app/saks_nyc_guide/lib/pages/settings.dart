import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void handleSignOut() async {
    await _googleSignIn.signOut();
  }

  Future<void> signOutCurrentUser() async {
    clearChats();
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
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
        const ListTile(
          title: Text('Clear Iterinary'),
          onTap: clearItinerary,
          dense: true,
        ),
        ListTile(
          title: const Text('Logout'),
          onTap: signOutCurrentUser,
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

void clearItinerary() async {
  final db = await openDatabase(
    join(await getDatabasesPath(), 'messages_database.db'),
  );
  await db.execute("DELETE FROM attractions");
}
