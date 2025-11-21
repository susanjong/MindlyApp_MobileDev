// FILE: lib/widgets/notes_tab_bar.dart

import 'package:flutter/material.dart';

class NotesTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const NotesTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 16),
      child: Row(
        children: [
          _buildTab('All Notes', 0),
          const SizedBox(width: 14),
          _buildTab('Categories', 1),
          const SizedBox(width: 14),
          _buildTab('Favorite', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = selectedIndex == index;
    final borderColor = isSelected
        ? const Color(0xFF004455)
        : const Color(0xB2C4C4C4);

    return GestureDetector(
      onTap: () => onTabSelected(index), // ✅ Panggil callback
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004455) : Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFC4C4C4),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.28,
            ),
          ),
        ),
      ),
    );
  }
}