import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<String> tabs;

  const NoteTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.tabs = const ['All Notes', 'Categories', 'Favorites'],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == tabs.length - 1 ? 0 : 6,
              ),
              child: _TabItem(
                label: tabs[index],
                isSelected: selectedIndex == index,
                onTap: () => onTabSelected(index),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _selectedColor = Color(0xFF5784EB);

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? _selectedColor : Colors.white,
            border: Border.all(
              color: isSelected
                  ? _selectedColor
                  : const Color(0xFFD9D9D9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF9E9E9E),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}