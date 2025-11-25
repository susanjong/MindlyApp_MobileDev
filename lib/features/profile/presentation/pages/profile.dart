import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../../../core/widgets/dialog/succes_popup.dart';
import '../../data/models/profile_model.dart';
import 'edit_bioprofile.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool _notificationsEnabled = true;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
  }

  void _initializeUserProfile() {
    _userProfile = UserProfile(
      name: 'Susan Jong',
      email: 'susanjong5@gmail.com',
      bio: 'Smile in front of your assignments',
      imageUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileCard(
                profile: _userProfile,
                onEdit: _navigateToEditProfile,
              ),
              const SizedBox(height: 24),
              _buildPreferenceSection(),
              const SizedBox(height: 24),
              _buildSupportSection(),
              const SizedBox(height: 24),
              _buildSecuritySection(),
              const SizedBox(height: 24),
              _buildDangerZoneSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
      ),
      title: Text(
        'Account Profile',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPreferenceSection() {
    return _SettingSection(
      title: 'PREFERENCE',
      items: [
        SettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive push notifications for reminders and updates',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeThumbColor: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _SettingSection(
      title: 'SUPPORT',
      items: [
        SettingItem(
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          subtitle: 'Get answers to common questions',
          trailing: _buildButton('View'),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.helpFaq);
          },
        ),
        SettingItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          trailing: _buildButton('Info'),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.aboutUs);
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _SettingSection(
      title: 'SECURITY',
      items: [
        SettingItem(
          icon: Icons.lock_outline,
          title: 'Reset Password',
          subtitle: 'Change your account password',
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _SettingSection(
      title: 'DANGER ZONE',
      items: [
        SettingItem(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          iconColor: const Color(0xFFFF6B6B),
          onTap: () => _showLogoutDialog(context),
        ),
        SettingItem(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently remove your account data',
          iconColor: const Color(0xFFFF6B6B),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildButton(String label) {
    return Container(
      width: 88.81,
      height: 24,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF000000)),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.24,
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile() {}

  // reset password dialog
  void _showResetDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Reset Password',
      message: 'Are you sure you want to \nreset your password ?',
      cancelText: 'Cancel',
      confirmText: 'Reset',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        // close confirmation dialog
        Navigator.of(context).pop();

        // show success dialog and auto navigate after 2 seconds
        SuccessDialog.showWithNavigation(
          context: context,
          title: 'Success !',
          message: 'Your password has been\nsuccessfully reset.',
          routeName: AppRoutes.resetPassword,
          useReplacement: false,
        );
      },
    );
  }

  // logout dialog
  void _showLogoutDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to \nlogout this account?',
      cancelText: 'Cancel',
      confirmText: 'Logout',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        // close confirmation dialog
        Navigator.of(context).pop();

        // show success dialog and auto navigate to sign in after 2 seconds
        SuccessDialog.showWithNavigation(
          context: context,
          title: 'Success !',
          message: 'Your account was\nsuccessfully logout.',
          routeName: AppRoutes.signIn,
          useReplacement: true,
        );
      },
    );
  }

  // delete account dialog
  void _showDeleteAccountDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Delete Account',
      message: 'This action cannot be undone.\nAre you sure?',
      cancelText: 'Cancel',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        // close confirmation dialog
        Navigator.of(context).pop();

        // show success dialog and auto navigate after 2 seconds
        SuccessDialog.showWithNavigation(
          context: context,
          title: 'Success !',
          message: 'Your account has been\nsuccessfully deleted.',
          routeName: AppRoutes.signUp,
          useReplacement: true,
        );
      },
    );
  }
}

// profile card widget
class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF000000), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(profile.imageUrl),
            backgroundColor: const Color(0xFFE0E0E0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF3C527E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            splashRadius: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditAccountInformationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// setting section widget
class _SettingSection extends StatelessWidget {
  final String title;
  final List<SettingItem> items;

  const _SettingSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF000000), width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFF999191),
              indent: 25,
              endIndent: 25,
            ),
            itemBuilder: (context, index) {
              return _SettingItemWidget(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}

//  setting item widget
class _SettingItemWidget extends StatelessWidget {
  final SettingItem item;

  const _SettingItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              height: 35,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: const ShapeDecoration(
                      color: Color(0x7FC4C4C4),
                      shape: OvalBorder(),
                    ),
                  ),
                  Icon(
                    item.icon,
                    color: item.iconColor ?? const Color(0xFF1A1A1A),
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.iconColor ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 12),
              item.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

//setting item model
class SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });
}