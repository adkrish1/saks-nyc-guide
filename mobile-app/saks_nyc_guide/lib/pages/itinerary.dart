import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/database_util.dart';

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
    Colors.deepOrange,
    Colors.pink
  ];
  Future<void> createDB() async {
    database = MyDatabaseUtils.createDB();
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
        setState(() {
          items = attractionList;
        });
      });
    });
  }

  Icon _itemIcon(Map<String, dynamic> item) {
    if (item['categories'].contains("Museums") ||
        item['categories'].contains('Historical')) {
      return const Icon(Icons.history_edu_outlined, size: 36);
    }
    return const Icon(Icons.restaurant_menu_outlined, size: 36);
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
                    leading: _itemIcon(item),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(item['name'],
                                overflow: TextOverflow.ellipsis)),
                        Text(
                          item['price'] == "--" ? "" : item['price'].contains("No") ? "" : item['price'].toString(),
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
                        // Text('Categories: ${item['categories']}'),
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
