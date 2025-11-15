import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const CustomTopAppBar({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mindly logo in here
            Row(
              children: [
                SizedBox(
                  width: 32.36,
                  height: 30,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/Mindly_logo.svg',
                      width: 32.36,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mindly',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004455),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // right: icon profile + notification
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF1A1A1A),
                    size: 26,
                  ),
                  onPressed: onProfileTap ?? () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF1A1A1A),
                    size: 26,
                  ),
                  onPressed: onNotificationTap ?? () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}