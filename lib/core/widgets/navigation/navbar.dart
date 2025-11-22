import 'package:flutter/material.dart';
import '../../../features/home/presentation/pages/home.dart';
import '../../../features/notes/presentation/pages/notes_main_page.dart';
import '../../../features/to_do_list/presentation/pages/mainTodo.dart';

class NavbarRoot extends StatefulWidget {
  const NavbarRoot({super.key});

  @override
  State<NavbarRoot> createState() => _NavbarRootState();
}

class _NavbarRootState extends State<NavbarRoot> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const NotesMainPage(),
    const MainTodoScreen(),
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
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped, // sekarang wajib ada
          ),
        ),
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped; // diubah jadi non-nullable
  final bool autoNavigate;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped, // wajib diisi
    this.autoNavigate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),

                    onTap: () => onItemTapped?.call(index),

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
    );
  }
}

// Models navbar item
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
