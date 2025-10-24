import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';
import 'package:notesapp/presentation/screen/todolist/awaltodo.dart';
import 'package:notesapp/presentation/screen/calendar/awalcalendar.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
          (index) => GestureDetector(
            onTap: () {
              if (selectedIndex != index) {
                Widget page;
                switch (index) {
                  case 0:
                    page = const HomePage();
                    break;
                  case 1:
                    page = const NotesPage();
                    break;
                  case 2:
                    page = const TodoListPage();
                    break;
                  case 3:
                    page = const CalendarPage();
                    break;
                  default:
                    page = const HomePage();
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              }
              onItemTapped(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedIndex == index ? const Color(0xFFD4F1A8) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _navItems[index].icon,
                    color: Colors.black,
                    size: 22,
                  ),
                  if (selectedIndex == index) ...[
                    const SizedBox(width: 8),
                    Text(
                      _navItems[index].label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// navbar items

class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.label,
  });
}

const List<NavBarItem> _navItems = [
  NavBarItem(icon: Icons.home, label: 'Home'),
  NavBarItem(icon: Icons.note, label: 'Notes'),
  NavBarItem(icon: Icons.list, label: 'To do list'),
  NavBarItem(icon: Icons.calendar_today, label: 'Calendar'),
];
