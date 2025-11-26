import 'package:flutter/material.dart';
import 'dart:math' as math;

class NotesExpandableFab extends StatefulWidget {
  final VoidCallback? onAddNoteTap;
  final VoidCallback? onAddCategoryTap;

  const NotesExpandableFab({
    super.key,
    this.onAddNoteTap,
    this.onAddCategoryTap,
  });

  @override
  State<NotesExpandableFab> createState() => _NotesExpandableFabState();
}

class _NotesExpandableFabState extends State<NotesExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  // Warna sesuai instruksi
  static const Color _primaryColor = Color(0xFFD732A8); // Pink Button
  static const Color _secondaryColor = Color(0xFFFBAE38); // Kuning/Orange
  static const Color _subtlePurpleWhite = Color(0xFFFAF8FC); // Putih keunguan tipis

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onActionTap(VoidCallback? action) {
    _toggle();
    Future.delayed(const Duration(milliseconds: 150), () {
      action?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background container panjang
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final height = 60.0 + (130.0 * _expandAnimation.value);

              return Positioned(
                bottom: 0,
                child: Opacity(
                  opacity: _expandAnimation.value == 0 ? 0 : 1,
                  child: Container(
                    width: 60,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _primaryColor.withValues(alpha:0.1 * _expandAnimation.value),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1 * _expandAnimation.value),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Add Note Button (Posisi Bawah)
          _buildActionButton(
            intervalStart: 0.3,
            bottomOffset: 75,
            icon: Icons.edit_outlined,
            tooltip: 'Add Note',
            onTap: () => _onActionTap(widget.onAddNoteTap),
          ),

          // Add Category Button (Posisi Atas)
          _buildActionButton(
            intervalStart: 0.6,
            bottomOffset: 135,
            icon: Icons.folder,
            tooltip: 'Add Category',
            onTap: () => _onActionTap(widget.onAddCategoryTap),
          ),

          // Main FAB Button
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha:0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _expandAnimation.value * math.pi / 4,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required double intervalStart,
    required double bottomOffset,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(intervalStart, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: bottomOffset * _expandAnimation.value,
          child: Transform.scale(
            // Scale boleh > 1.0 untuk efek 'bounce'
            scale: animation.value,
            child: Opacity(
              // FIX: Clamp value agar Opacity tidak pernah > 1.0 atau < 0.0
              // Ini mencegah crash saat animasi 'overshoot'
              opacity: animation.value.clamp(0.0, 1.0),
              child: Tooltip(
                message: tooltip,
                child: GestureDetector(
                  onTap: _expandAnimation.value > 0.8 ? onTap : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _subtlePurpleWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: _secondaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}