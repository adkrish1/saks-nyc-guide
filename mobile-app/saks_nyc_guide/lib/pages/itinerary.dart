import 'package:flutter/material.dart';

class Itinerary extends StatefulWidget {
  const Itinerary({Key? key}) : super(key: key);

  @override
  ItineraryState createState() => ItineraryState();
}

class ItineraryState extends State<Itinerary> {
  final List<Map<String, dynamic>> items = [
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant A',
      'address': '123 Main St',
      'rating': 4.5,
      'phone': '555-1234',
      'categories': 'Italian, Pizza',
      'color': Colors.blue,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant B',
      'address': '456 Elm St',
      'rating': 4.2,
      'phone': '555-5678',
      'categories': 'Mexican',
      'color': Colors.green,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant C',
      'address': '789 Oak St',
      'rating': 4.0,
      'phone': '555-9876',
      'categories': 'Chinese',
      'color': Colors.red,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant D',
      'address': '321 Pine St',
      'rating': 4.7,
      'phone': '555-5432',
      'categories': 'American',
      'color': Colors.orange,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant E',
      'address': '654 Maple St',
      'rating': 4.3,
      'phone': '555-6789',
      'categories': 'Japanese, Sushi',
      'color': Colors.purple,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant F',
      'address': '987 Cedar St',
      'rating': 4.6,
      'phone': '555-3456',
      'categories': 'Indian',
      'color': Colors.teal,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant G',
      'address': '159 Walnut St',
      'rating': 4.1,
      'phone': '555-8765',
      'categories': 'Thai',
      'color': Colors.deepPurple,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant H',
      'address': '753 Elmwood St',
      'rating': 4.4,
      'phone': '555-4321',
      'categories': 'Mediterranean',
      'color': Colors.lightBlue,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant I',
      'address': '246 Birch St',
      'rating': 4.8,
      'phone': '555-2109',
      'categories': 'Seafood',
      'color': Colors.amber,
    },
    {
      'icon': Icons.restaurant_sharp,
      'name': 'Restaurant J',
      'address': '369 Pineapple St',
      'rating': 4.9,
      'phone': '555-7890',
      'categories': 'Greek',
      'color': Colors.pink,
    },
  ];

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
                  color: item['color'], // Unique color for each card
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
                        Text(item['name']),
                        Text(
                          item['rating'].toString(),
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
