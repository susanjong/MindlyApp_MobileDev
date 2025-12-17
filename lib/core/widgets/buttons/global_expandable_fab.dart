import 'package:flutter/material.dart';
import 'dart:math' as math;

// Model data untuk setiap aksi pada FAB
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

// Widget Floating Action Button yang dapat diekspansi (Expandable)
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

  // Konstanta Warna UI
  static const Color _primaryColor = Color(0xFFD732A8);
  static const Color _secondaryColor = Color(0xFFFBAE38);
  static const Color _subtlePurpleWhite = Color(0xFFFAF8FC);

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi dengan durasi 250ms
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // Menggunakan kurva animasi agar gerakan terasa lebih natural
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

  // Mengubah status ekspansi (buka/tutup)
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

  // Menangani tap pada tombol aksi anak
  void _onActionTap(VoidCallback action) {
    _toggle();
    // Memberikan delay sedikit agar animasi menutup terlihat sebelum aksi dijalankan
    Future.delayed(const Duration(milliseconds: 200), () {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung tinggi total background berdasarkan jumlah aksi
    final double maxBackgroundHeight = 70.0 + (widget.actions.length * 60.0);

    return SizedBox(
      width: 70,
      height: maxBackgroundHeight + 20,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Layer 1: Background Putih (Bentuk Pil)
          _buildExpandableBackground(maxBackgroundHeight),

          // Layer 2: Tombol Aksi (Anak)
          ..._buildActionButtons(),

          // Layer 3: Tombol FAB Utama (Toggle)
          _buildMainFab(),
        ],
      ),
    );
  }

  // Widget untuk background putih yang memanjang saat dibuka
  Widget _buildExpandableBackground(double maxHeight) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final height = 60.0 + ((maxHeight - 60.0) * _expandAnimation.value);

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
                  color: _primaryColor.withValues(alpha: 0.1 * _expandAnimation.value),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1 * _expandAnimation.value),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Membuat daftar tombol aksi berdasarkan list 'actions'
  List<Widget> _buildActionButtons() {
    return List.generate(widget.actions.length, (index) {
      final action = widget.actions[index];

      // Posisi vertikal tombol (75dp dari bawah sebagai base offset)
      final double bottomOffset = 75.0 + (index * 60.0);

      // Kalkulasi interval animasi untuk efek muncul berurutan (staggered)
      final double start = 0.0 + (index * 0.1);
      final double end = 1.0;

      return _buildSingleActionButton(
        intervalStart: start.clamp(0.0, 0.8),
        intervalEnd: end,
        bottomOffset: bottomOffset,
        icon: action.icon,
        tooltip: action.tooltip,
        onTap: () => _onActionTap(action.onTap),
      );
    });
  }

  // Widget tombol aksi individual
  Widget _buildSingleActionButton({
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
                  // Mencegah tap saat animasi belum selesai sepenuhnya
                  onTap: _expandAnimation.value > 0.8 ? onTap : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _subtlePurpleWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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

  // Widget FAB Utama (Tombol Tambah/Tutup)
  Widget _buildMainFab() {
    return Positioned(
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
                color: _primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _expandAnimation.value * math.pi / 4, // Rotasi 45 derajat (Plus jadi Silang)
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
    );
  }
}