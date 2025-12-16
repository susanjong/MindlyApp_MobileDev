import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectionActionBar extends StatelessWidget {
  final VoidCallback onMove;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final bool isAllSelectedFavorite;

  const SelectionActionBar({
    super.key,
    required this.onMove,
    required this.onFavorite,
    required this.onDelete,
    required this.isAllSelectedFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
        top: false,
        child: SizedBox(
          height: 60, // Tinggi konten fixed, tapi diluar SafeArea
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionItem(
                icon: Icons.folder_open_outlined,
                label: 'Move to',
                onTap: onMove,
              ),
              _ActionItem(
                icon: isAllSelectedFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isAllSelectedFavorite ? Colors.red : Colors.black,
                label: 'Favorite',
                onTap: onFavorite,
              ),
              _ActionItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                iconColor: const Color(0xFFB90000),
                textColor: const Color(0xFFB90000),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        // ✅ FIX 1: Kurangi padding vertikal dari 4 jadi 2
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        // ✅ FIX 2: Bungkus dengan FittedBox agar auto-resize jika ruang sempit
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}