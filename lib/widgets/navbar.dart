import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';
import 'package:notesapp/presentation/screen/todolist/awaltodo.dart';
import 'package:notesapp/presentation/screen/calendar/awalcalendar.dart';

// ================== CUSTOM NAVBAR ==================
class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;
  final bool autoNavigate;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
    this.autoNavigate = true,
  });

  // Fungsi untuk navigasi ke halaman berdasarkan index
  void _navigateToPage(BuildContext context, int index) {
    if (selectedIndex == index || !autoNavigate) {
      onItemTapped?.call(index);
      return;
    }

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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _navItems.length,
              (index) {
            final isSelected = selectedIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => _navigateToPage(context, index),
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      // FIXED: Semua container punya ukuran yang SAMA
                      constraints: BoxConstraints(
                        minWidth: isSelected ? 100 : 46,
                        maxWidth: isSelected ? 120 : 46,
                        minHeight: 46,
                        maxHeight: 46,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 14 : 0,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4F1A8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _navItems[index].icon,
                            color: Colors.black,
                            size: 22,
                          ),
                          // Animasi smooth untuk text
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 8 : 0,
                          ),
                          if (isSelected)
                            Flexible(
                              child: Text(
                                _navItems[index].label,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================== NAVBAR ITEMS ==================
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
  NavBarItem(icon: Icons.list, label: 'Todo'),
  NavBarItem(icon: Icons.calendar_today, label: 'Calendar'),
];