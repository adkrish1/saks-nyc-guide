import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDatabaseUtils {
  static Future<dynamic> createDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'messages_database.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE messages(id STRING PRIMARY KEY, messageText TEXT, createdAt INTEGER, author STRING)');
        await db.execute(
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
}
