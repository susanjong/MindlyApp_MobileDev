import 'package:flutter/material.dart';
import 'dart:math' as math;

class FabActionModel {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  FabActionModel({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}

class GlobalExpandableFab extends StatefulWidget {
  final List<FabActionModel> actions;

  const GlobalExpandableFab({
    super.key,
    required this.actions,
  });

  @override
  State<GlobalExpandableFab> createState() => _GlobalExpandableFabState();
}

class _GlobalExpandableFabState extends State<GlobalExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  // Warna Konsisten
  static const Color _primaryColor = Color(0xFFD732A8); // Pink Button
  static const Color _secondaryColor = Color(0xFFFBAE38); // Kuning/Orange Icon
  static const Color _subtlePurpleWhite = Color(0xFFFAF8FC); // Background button kecil

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
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

  void _onActionTap(VoidCallback action) {
    _toggle();
    // Delay sedikit agar animasi menutup terlihat sebelum aksi dijalankan
    Future.delayed(const Duration(milliseconds: 200), () {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi background putih berdasarkan jumlah action
    // 60 (base) + (jumlah action * 60) + padding extra
    final double maxBackgroundHeight = 70.0 + (widget.actions.length * 60.0);

    return SizedBox(
      width: 70,
      // Tinggi container dinamis agar tidak memotong tombol
      height: maxBackgroundHeight + 20,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Background Putih yang Memanjang (Pill Shape)
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final height = 60.0 + ((maxBackgroundHeight - 60.0) * _expandAnimation.value);

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

          // 2. Generate Action Buttons secara Dinamis
          ...List.generate(widget.actions.length, (index) {
            // Kita reverse indexnya agar item pertama di list muncul paling bawah (dekat FAB utama)
            // Atau normal order agar item pertama paling atas.
            // Di sini saya buat item pertama di list = tombol paling bawah (di atas FAB utama).

            final action = widget.actions[index];

            // Perhitungan posisi
            // Jarak tombol pertama dari bawah = 75
            // Jarak antar tombol = 60
            final double bottomOffset = 75.0 + (index * 60.0);

            // Interval animasi agar muncul berurutan (staggered)
            // Tombol bawah muncul duluan
            final double start = 0.0 + (index * 0.1);
            final double end = 1.0;

            return _buildActionButton(
              intervalStart: start.clamp(0.0, 0.8),
              intervalEnd: end,
              bottomOffset: bottomOffset,
              icon: action.icon,
              tooltip: action.tooltip,
              onTap: () => _onActionTap(action.onTap),
            );
          }),

          // 3. Main FAB Button (Pink Besar)
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
                      angle: _expandAnimation.value * math.pi / 4, // Rotasi jadi 'X'
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
    required double intervalEnd,
    required double bottomOffset,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: bottomOffset * _expandAnimation.value,
          child: Transform.scale(
            scale: animation.value,
            child: Opacity(
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