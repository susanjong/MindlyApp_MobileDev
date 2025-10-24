import 'package:flutter/material.dart';
import 'package:notesapp/widgets/font_style.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const CustomTopAppBar({
    Key? key,
    this.onProfileTap,
    this.onNotificationTap,
  }) : super(key: key);

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
            // kiri: kotak hijau + Mindly
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D5F5F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/vectorlogo.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported_outlined,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mindly',
                  style: FontStyles.appTitle,
                ),
              ],
            ),

            // kanan: profil + notifikasi
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.person_outline,
                      color: Color(0xFF1A1A1A), size: 26),
                  onPressed: onProfileTap ?? () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined,
                      color: Color(0xFF1A1A1A), size: 26),
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
