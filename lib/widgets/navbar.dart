
import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';
import 'package:notesapp/widgets/custom_navbar_widget.dart';

class NavbarRoot extends StatefulWidget {
  const NavbarRoot({super.key});

  @override
  State<NavbarRoot> createState() => _NavbarRootState();
}

class _NavbarRootState extends State<NavbarRoot> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const NotesPage(),
    const Center(child: Text('Todo Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Calendar Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
