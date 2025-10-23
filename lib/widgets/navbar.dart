import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';
import 'package:notesapp/presentation/screen/todolist/awaltodo.dart';
/*import 'package:notesapp/presentation/screen/calendar/awalcalendar.dart'; */

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Fungsi untuk mendapatkan halaman berdasarkan index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const NotesPage();
      case 2:
        return const TodoListPage();
      //case 3:
      //  return const AwalCalendar();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 64.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _getPage(selectedIndex), // ✅ Halaman utama ditampilkan di body Scaffold
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        onItemTapped(index);
                        // Navigasi langsung ke halaman dengan animasi fade
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                CustomNavBar(selectedIndex: index, onItemTapped: onItemTapped),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 8,
                          vertical: isSelected ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD4F1A8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected ? Colors.black : Colors.grey[700],
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

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
