import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedTopAppBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onExpandTap;
  final double scrollOffset;
  final bool showExpandButton;

  const AnimatedTopAppBar({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
    this.onExpandTap,
    this.scrollOffset = 0,
    this.showExpandButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung progress animasi berdasarkan scroll (0 = normal, 1 = mini)
    final progress = (scrollOffset / 100).clamp(0.0, 1.0);

    // Ukuran logo
    final logoSize = 30.0 - (8.0 * progress); // 30 -> 22
    final logoWidth = 32.36 - (10.0 * progress); // 32.36 -> 22.36

    // Ukuran text
    final textSize = 30.0 - (12.0 * progress); // 30 -> 18

    // Opacity untuk icon kanan
    final iconsOpacity = 1.0 - progress;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: progress > 0.5
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              // Logo dan Text - akan ke tengah saat scroll
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: logoWidth,
                    height: logoSize,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/Mindly_logo.svg',
                        width: logoWidth,
                        height: logoSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: logoSize,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: GoogleFonts.poppins(
                      fontSize: textSize,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF004455),
                      letterSpacing: -0.5,
                    ),
                    child: const Text('Mindly'),
                  ),
                ],
              ),

              // Icons kanan - akan hilang saat scroll atau diganti dengan expand button
              if (progress < 0.5)
                Opacity(
                  opacity: iconsOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showExpandButton)
                        IconButton(
                          icon: const Icon(
                            Icons.expand_more,
                            color: Color(0xFF1A1A1A),
                            size: 26,
                          ),
                          onPressed: iconsOpacity > 0.3 ? onExpandTap : null,
                        )
                      else ...[
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF1A1A1A),
                            size: 26,
                          ),
                          onPressed: iconsOpacity > 0.3 ? onProfileTap : null,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_outlined,
                            color: Color(0xFF1A1A1A),
                            size: 26,
                          ),
                          onPressed: iconsOpacity > 0.3 ? onNotificationTap : null,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}