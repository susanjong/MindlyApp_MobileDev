import 'package:flutter/material.dart';
import 'colors.dart';
import 'dart:math' as math;

class ExpandableFab extends StatefulWidget {
  final VoidCallback? onAddNoteTap;
  final VoidCallback? onAddFolderTap;

  const ExpandableFab({
    super.key,
    this.onAddNoteTap,
    this.onAddFolderTap,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Overlay untuk menutup FAB ketika diklik di luar
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          // Container background untuk expanded buttons
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                child: Container(
                  width: 60,
                  height: 60 + (59 * 2 * _expandAnimation.value),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: const Color(0x33FF7ADF),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x4C000000),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Add Note Button
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final offset = 6.33 * _expandAnimation.value;
              return Positioned(
                bottom: 59 + offset,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: _ActionButton(
                    onPressed: () {
                      _toggle();
                      widget.onAddNoteTap?.call();
                    },
                    icon: Icons.edit_outlined,
                    tooltip: 'Add Note',
                  ),
                ),
              );
            },
          ),

          // Add Folder Button
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final offset = 61.17 * _expandAnimation.value;
              return Positioned(
                bottom: 59 + offset,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: _ActionButton(
                    onPressed: () {
                      _toggle();
                      widget.onAddFolderTap?.call();
                    },
                    icon: Icons.folder,
                    tooltip: 'Add Folder',
                  ),
                ),
              );
            },
          ),

          // Main FAB Button
          Positioned(
            bottom: 0,
            child: Container(
              width: 59,
              height: 59,
              decoration: BoxDecoration(
                color: button,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _toggle,
                  child: AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _expandAnimation.value * math.pi / 4,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.06, 0.71),
            end: Alignment(0.96, 0.68),
            colors: [
              Color(0x33AE8FFF),
              Color(0x33C69DFF),
              Color(0x33F5B6FF),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onPressed,
            child: Icon(
              icon,
              color: secondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}