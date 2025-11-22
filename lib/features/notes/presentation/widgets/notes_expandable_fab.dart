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

  static const Color _primaryColor = Color(0xFFD732A8);
  static const Color _secondaryColor = Color(0xFF004455);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
    action?.call();
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
          // Background container when expanded
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  height: 62 + (60 * 2 * _expandAnimation.value),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(31),
                    border: Border.all(
                      color: _primaryColor.withValues(alpha:0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Add Note Button
          _buildActionButton(
            offset: 65,
            icon: Icons.edit_outlined,
            tooltip: 'Add Note',
            onTap: () => _onActionTap(widget.onAddNoteTap),
          ),

          // Add Category Button
          _buildActionButton(
            offset: 125,
            icon: Icons.folder_outlined,
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
                        size: 30,
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
    required double offset,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: offset * _expandAnimation.value,
          child: Opacity(
            opacity: _expandAnimation.value,
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: Tooltip(
                message: tooltip,
                child: GestureDetector(
                  onTap: _expandAnimation.value > 0.5 ? onTap : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _secondaryColor.withValues(alpha:0.15),
                          _primaryColor.withValues(alpha:0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _secondaryColor.withValues(alpha:0.3),
                        width: 1,
                      ),
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