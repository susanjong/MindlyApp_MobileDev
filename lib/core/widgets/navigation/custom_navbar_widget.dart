import 'package:flutter/material.dart';
import '../../../config/routes/routes.dart';

class NavBarItem {
  final IconData icon;
  final String label;
  final String route;

  const NavBarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<NavBarItem> _navItems = [
  NavBarItem(
    icon: Icons.home,
    label: 'Home',
    route: AppRoutes.home,
  ),
  NavBarItem(
    icon: Icons.note,
    label: 'Notes',
    route: AppRoutes.notes,
  ),
  NavBarItem(
    icon: Icons.list,
    label: 'Todo',
    route: AppRoutes.todo,
  ),
  NavBarItem(
    icon: Icons.calendar_today,
    label: 'Calendar',
    route: AppRoutes.calendar,
  ),
];

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return;
    onItemTapped?.call(index);

    final route = _navItems[index].route;
    Navigator.pushReplacementNamed(context, route);
  }

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
                    onTap: () => _handleNavigation(context, index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 12 : 8,
                        vertical: isSelected ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD4F1A8)
                            : Colors.transparent,
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