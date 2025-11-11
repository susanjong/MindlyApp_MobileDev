
import 'package:flutter/material.dart';

// Models navbar item dibuat isinya disini
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


// Isi utama dari navbar
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

   // Logic untuk perpindahan isi navbar berdasarkan indexnya dibuat permisalan
  @override
  Widget build(BuildContext context) {
    return Container(
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
