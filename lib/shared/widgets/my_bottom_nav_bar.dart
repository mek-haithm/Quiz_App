import 'package:flutter/material.dart';
import 'package:quiz_app/shared/constants/colors.dart';

class MyBottomNavbar extends StatefulWidget {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyBottomNavbar({
    super.key,
    required this.screens,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _MyBottomNavbarState createState() => _MyBottomNavbarState();
}

class _MyBottomNavbarState extends State<MyBottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.screens[widget.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: widget.items,
        currentIndex: widget.selectedIndex,
        selectedItemColor: kMainColor,
        onTap: widget.onItemTapped,
      ),
    );
  }
}
