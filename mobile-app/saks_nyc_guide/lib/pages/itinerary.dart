import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Itinerary extends StatefulWidget {
  const Itinerary({Key? key}) : super(key: key);

  @override
  ItineraryState createState() => ItineraryState();
}

class ItineraryState extends State<Itinerary> {
  List<Map<String, dynamic>> items = [];
  dynamic database;
  final List<dynamic> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.amber,
    Colors.pink
  ];
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

  @override
  void initState() {
    super.initState();
    createDB().then((value) => _loadMessages());
  }

  void _loadMessages() async {
    await database.then((d) {
      List<Map<String, dynamic>> attractionList = [];
      d.query('attractions').then((messagesMap) {
        for (Map<String, dynamic> attraction in messagesMap) {
          attractionList.add(attraction);
        }
      });
      setState(() {
        items = attractionList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  color: colors[item['id'] % 10], // Unique color for each card
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Apply border radius
                    side: const BorderSide(
                      color: Colors.black, // Border color
                      width: 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      size: 36,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(item['name'],
                                overflow: TextOverflow.ellipsis)),
                        Text(
                          item['price'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${item['address']}'),
                        Text('Rating: ${item['rating']}'),
                        Text('Phone: ${item['phone']}'),
                        Text('Categories: ${item['categories']}'),
                      ],
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
