import 'package:flutter/material.dart';

import '../pages/maps.dart';
import '../pages/itinerary.dart';
import '../pages/chatbot.dart';
import '../pages/settings.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPageNumber = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageNumber = index;
    });
  }

  void _incrementCounter() {
    // setState(() {
    // // This call to setState tells the Flutter framework that something has
    // // changed in this State, which causes it to rerun the build method below
    // // so that the display can reflect the updated values. If we changed
    // // _counter without calling setState(), then the build method would not be
    // // called again, and so nothing would appear to happen.
    // _counter++;
    // });
  }
  final _pageOptions = [
    const MapsPage(),
    const ItineraryPage(),
    const ChatBotPage(),
    const SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: _pageOptions[_selectedPageNumber],
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              label: 'Itinerary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedPageNumber,
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ));
  }
}
