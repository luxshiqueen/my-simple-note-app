import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'package:myapp/data/model/note_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NotePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex != 1
          ? AppBar(
              title: const Text(
                'MySimpleNote',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: const Color.fromARGB(228, 112, 8, 101),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.note, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: const Color.fromARGB(228, 112, 8, 101),
        buttonBackgroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 197, 27, 107),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
